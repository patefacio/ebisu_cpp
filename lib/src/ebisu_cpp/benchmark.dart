part of ebisu_cpp.ebisu_cpp;

/// A single benchmark fixture with one or more functions to time.
///
/// Benchmark support is provided via
/// (benchmark)[https://github.com/google/benchmark].  Each benchmark
/// results in a single [benchmarkLib] with a single [benchmarkHeader]
/// with a single [benchmarkClass] that derives from
/// ::benchmark::Fixture. Each of these are generated *bare-bones* and
/// ready for custom code. Of course, the [Header], [Lib] and [App]
/// meta objects are available for code injection.
///
/// The generated class has the *SetUp* and
/// *TearDown* functions with protect blocks.
///
/// Each benchmark also has an [App] associated with it
/// (i.e. [benchmarkApp]). This is where the benchmark timing loops
/// and the *BENCHMARK_MAIN()* provided by the
/// (benchmark)[https://github.com/google/benchmark] exist.
///
/// For a [Benchmark] you may specify 0 or more [functions] that
/// correspond to named timing loops (i.e. pieces of code that you want to
/// benchmark). If you specify no functions a single function with the
/// name of the [Benchmark] will be used.
///
/// So, given an [Installation], this code:
///
///     installation
///     ..benchmarks.add(benchmark('simple'))
///
/// Will result in the creation of:
///
///  - .../benchmarks/bench/simple/benchmark_simple.hpp: The place to do
///    setup and teardown of your benchmark fixture.
///
///         class Benchmark_simple : public ::benchmark::Fixture {
///          public:
///           // custom <ClsPublic Benchmark_simple>
///           // end <ClsPublic Benchmark_simple>
///
///           void SetUp() {
///             // custom <benchmark_simple setup>
///             // end <benchmark_simple setup>
///           }
///
///           void TearDown() {
///             // custom <benchmark_simple teardown>
///             // end <benchmark_simple teardown>
///           }
///         };
///
///
///  - .../benchmarks/app/simple/simple.cpp: The app containing
///    *BENCHMARK_MAIN()* and the *simple* function being timed:
///
///         BENCHMARK_F(Benchmark_simple, Simple)(benchmark::State& st) {
///           // custom <simple benchmark pre while>
///           // end <simple benchmark pre while>
///
///           while (st.KeepRunning()) {
///             // custom <simple benchmark while>
///             // end <simple benchmark while>
///           }
///           // custom <simple benchmark post while>
///           // end <simple benchmark post while>
///         }
///
///         BENCHMARK_MAIN()
///
/// That *BENCHMARK_F* declaration creates a derivative of the fixture
/// with the specified method *Simple*. When the [benchmarkApp] is run the
/// *Simple* function will be benchmarked.
class Benchmark extends CppEntity {
  /// The primary header for this benchmark
  Header get benchmarkHeader => _benchmarkHeader;

  /// The primary class for this benchmark
  Class get benchmarkClass => _benchmarkClass;

  /// Library for the benchmark
  Lib get benchmarkLib => _benchmarkLib;

  /// The application associated with this benchmark
  App get benchmarkApp => _benchmarkApp;

  /// The list of functions.
  ///
  /// If not set by client will result in list of one function [ id ].
  List<Id> get functions => _functions;

  // custom <class Benchmark>

  Benchmark(id, [this._namespace]) : super(id) {
    if (_namespace == null) {
      _namespace = new Namespace(['benchmarks', 'bench', this.id]);
    }
    id = 'benchmark_${this.id.snake}';
    _benchmarkClass = class_(id)
      ..bases = [base('::benchmark::Fixture')]
      ..customBlocks = [clsPublic]
      ..withCustomBlock(clsPublic, (cb) => cb.snippets.add('''
void SetUp() {
${codeBlock('${id} setup')}
}

void TearDown() {
${codeBlock('${id} teardown')}
}

'''));

    _benchmarkHeader = header(id)
      ..namespace = _namespace
      ..customBlocks = [fcbBeginNamespace, fcbEndNamespace]
      ..includes = ['benchmark/benchmark.h']
      ..classes = [_benchmarkClass];

    _benchmarkLib = lib(id)
      ..namespace = _namespace
      ..headers = [_benchmarkHeader];

    _benchmarkApp = _makeStandAloneApp();
  }

  set functions(Iterable functions_) =>
      _functions = functions_.map((f) => makeId(f)).toList();

  Iterable<Entity> get children => [_benchmarkApp,];

  String get contents => brCompact([
        '<<<< BENCHMARK($id) >>>>',
        indentBlock(brCompact(_benchmarkLib.contents))
      ]);

  onOwnershipEstablished() {
    final cppPath = this.installation.cppPath;
    if (_functions.isEmpty) {
      _functions.add(id);
    }

    _benchmarkApp.getCodeBlock(fcbBeginNamespace).snippets.add(_benchmarkCode);
    _logger.info(
        'Created namespace $namespace with owner ${owner.id} ${owner.runtimeType}');
  }

  _makeStandAloneApp() => app(id.snake)
    ..namespace = _namespace
    ..includes.add(benchmarkHeader.includeFilePath)
    ..includes.add('benchmark/benchmark_api.h')
    ..getCodeBlock(fcbPostNamespace).snippets.add('\nBENCHMARK_MAIN()');

  get _benchmarkCode => brCompact(_functions.map((f) => '''
BENCHMARK_F(${_benchmarkClass.className}, ${f.capCamel})(benchmark::State& st) {
${customBlock('${f.id} benchmark pre while')}
  while (st.KeepRunning()) {
${customBlock('${f.id} benchmark while')}
  }
${customBlock('${f.id} benchmark post while')}
}
'''));

  // end <class Benchmark>

  /// Names for C++ entities
  Namespace _namespace;
  Header _benchmarkHeader;
  Class _benchmarkClass;
  Lib _benchmarkLib;
  App _benchmarkApp;
  List<Id> _functions = [];
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
    _benchmarkApp
      ..namespace = new Namespace(['benchmarks'])
      ..includes.add('benchmark/benchmark_api.h')
      ..customBlocks = [fcbBeginNamespace];
  }

  Iterable<Entity> get children => concat([
        [_benchmarkApp],
        benchmarks
      ]);

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
    _benchmarkApp
      ..includes
          .addAll(_benchmarks.map((bm) => bm.benchmarkHeader.includeFilePath))
      ..getCodeBlock(fcbPostNamespace).snippets.add(brCompact([
        benchmarks.map((bm) => bm._namespace.wrap(bm._benchmarkCode)),
        '\nBENCHMARK_MAIN()'
      ]));
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
