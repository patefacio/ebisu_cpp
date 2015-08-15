part of ebisu_cpp.ebisu_cpp;

/// A benchmark.
class Benchmark extends CppEntity {
  /// The primary header for this benchmark
  Header get benchmarkHeader => _benchmarkHeader;

  /// Library for the benchmark
  Lib get benchmarkLib => _benchmarkLib;

  // custom <class Benchmark>

  Benchmark(id, [this._namespace]) : super(id) {
    if (_namespace == null) {
      _namespace = new Namespace(['benchmarks', 'bench', this.id]);
    }
    _benchmarkHeader = header(id)
      ..namespace = _namespace
      ..includes = ['benchmark/benchmark.h']
      ..classes = [];
    _benchmarkLib = lib(id)
      ..namespace = _namespace
      ..headers = [_benchmarkHeader];
  }

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  String get contents => brCompact([
        '<<<< BENCHMARK($id) >>>>',
        indentBlock(brCompact(_benchmarkLib.contents))
      ]);

  onOwnershipEstablished() {
    final cppPath = this.installation.cppPath;
    _logger.info(
        'Created namespace $namespace with owner ${owner.id} ${owner.runtimeType}');
  }

  makeStandAloneApp() => app(id.snake)
    ..namespace = namespace(['benchmark'])
    ..includes.add(benchmarkHeader.includeFilePath)
    ..getCodeBlock(fcbBeginNamespace).snippets.add(_benchmarkCode);

  get _benchmarkCode => '''

static void ${id.snake}(benchmark::State& state) {
  while(state.KeepRunning()) {}
}

BENCHMARK(${id.snake});
''';

  // end <class Benchmark>

  /// Names for C++ entities
  Namespace _namespace;
  Header _benchmarkHeader;
  Lib _benchmarkLib;
}

/// Collection of one or benchmarks generated into one executable.
class BenchmarkGroup extends CppEntity {
  /// Collection of benchmarks
  List<Benchmark> get benchmarks => _benchmarks;

  /// The application containing hooks into benchmark suite
  App get benchmarkApp => _benchmarkApp;

  // custom <class BenchmarkGroup>

  BenchmarkGroup(id)
      : super(id),
        _benchmarkApp = new App(makeId(id).snake) {
    _benchmarkApp.namespace = new Namespace(['benchmarks', 'apps', this.id]);
  }

  Iterable<Entity> get children => concat([benchmarks]);

  withBenchmarkApp(updater(App app)) => updater(_benchmarkApp);

  withBenchmark(id, updater(Benchmark benchmark)) {
    final bmId = addPrefixToId('bm', id);
    Benchmark bm =
        _benchmarks.firstWhere((bm) => bm.id == bmId, orElse: () => null);
    if (bm == null) {
      bm = new Benchmark(id, namespace(['benchmarks', 'bench', this.id, id]));
      _benchmarks.add(bm);
    }
    updater(bm);
  }

  onOwnershipEstablished() {
    _benchmarkApp.includes
        .addAll(_benchmarks.map((bm) => bm.benchmarkHeader.includeFilePath));
  }

  // end <class BenchmarkGroup>

  List<Benchmark> _benchmarks = [];
  App _benchmarkApp;
}

// custom <part benchmark>

Benchmark benchmark(id) => new Benchmark(id);
BenchmarkGroup benchmarkGroup(id) => new BenchmarkGroup(id);

addBenchmarkCode(App benchmarkApp) {}

// end <part benchmark>
