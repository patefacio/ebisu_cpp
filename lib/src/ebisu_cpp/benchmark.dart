part of ebisu_cpp.ebisu_cpp;

/// A benchmark.
class Benchmark extends CppEntity {
  /// Names for C++ entities
  Namespace namespace;

  /// App for the benchmark
  App get benchmarkApp => _benchmarkApp;

  /// Library for the benchmark
  Lib get benchmarkLib => _benchmarkLib;

  /// The primary header for this benchmark
  Header get benchmarkHeader => _benchmarkHeader;

  /// Class object that is responsible for doing the work to be timed
  Class get benchmarkClass => _benchmarkClass;

  // custom <class Benchmark>

  Benchmark(id, this.namespace) : super(id) {
    _benchmarkClass = class_('${this.id.snake}_benchmark')
      ..bases = [base('Benchmark')];
    _benchmarkHeader = header(id)
      ..namespace = namespace
      ..classes = [_benchmarkClass];
    _benchmarkLib = lib(id)
      ..namespace = namespace
      ..headers = [_benchmarkHeader];
    _benchmarkApp = app(id)..namespace = namespace;
  }

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  String get contents => brCompact([
        '<<<< BENCHMARK($id) >>>>',
        indentBlock(brCompact([_benchmarkApp.contents, _benchmarkLib.contents]))
      ]);

  onOwnershipEstablished() {
    final cppPath = this.installation.cppPath;
    _logger.info(
        'Created namespace $namespace with owner ${owner.id} ${owner.runtimeType}');
    _benchmarkHeader.namespace = this.namespace;
    _benchmarkLib.namespace = this.namespace;
    _benchmarkApp.namespace = this.namespace;
    _benchmarkApp
      ..setBenchmarkFilePathFromRoot(cppPath)
      ..includes.add(_benchmarkHeader.includeFilePath);
  }

  // end <class Benchmark>

  App _benchmarkApp;
  Lib _benchmarkLib;
  Header _benchmarkHeader;
  Class _benchmarkClass;
}

/// Represents a single benchmark concept containing one or more actual
/// benchmarks to run timings for.
///
/// The concept of having a single [Benchmark] in a [BenchmarkHarness]
/// might useful to have timings on a piece of code that, over time, should
/// remain stable or improve.
///
/// The concept of having mutliple [Benchmark]s in a [BenchmarkHarness] is
/// to enable comparison. History analysis is still an option as well.
class BenchmarkHarness extends CppEntity {
  /// Collection of all bookmarks owned by the harness
  List<Benchmark> get benchmarks => _benchmarks;

  /// Class responsible for running the various benchmarks through their paces
  Class get harnessClass => _harnessClass;

  // custom <class BenchmarkHarness>

  BenchmarkHarness(id) : super(id) {
    _harnessClass = class_('${this.id.snake}_benchmark_harness');
  }

  Iterable<Entity> get children => concat([benchmarks]);

  withBenchmark(id, updater(Benchmark benchmark)) {
    final bmId = addPrefixToId('bm', id);
    Benchmark bm =
        _benchmarks.firstWhere((bm) => bm.id == bmId, orElse: () => null);
    if (bm == null) {
      bm = new Benchmark(id, namespace(['benchmarks', this.id, id]));
      _benchmarks.add(bm);
    }
    updater(bm);
  }

  onOwnershipEstablished() {
    for (Benchmark benchmark in _benchmarks) {
      this.installation
        ..apps.add(benchmark.benchmarkApp)
        ..libs.add(benchmark.benchmarkLib);
    }
  }

  // end <class BenchmarkHarness>

  List<Benchmark> _benchmarks = [];
  Class _harnessClass;
}

// custom <part benchmark>

BenchmarkHarness benchmarkHarness(id) => new BenchmarkHarness(id);

// end <part benchmark>
