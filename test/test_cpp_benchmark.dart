library ebisu_cpp.test_cpp_benchmark;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_benchmark');

// custom <library test_cpp_benchmark>
// end <library test_cpp_benchmark>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('simple benchmark', () {
    final bmInstallation = installation('benchmark');
    final bm = benchmarkHarness('measure_algo')
      ..doc = 'Code to benchmark algo using std::map vs google_dense_hashmap'
      ..withBenchmark('std_map', (_) => null)
      ..withBenchmark('google_dense_hashmap', (_) => null);

    bmInstallation.rootFilePath = '/tmp';
    bmInstallation.benchmarks.addAll(bm.benchmarks);
    //    bmInstallation.generate();
  });

// end <main>
}
