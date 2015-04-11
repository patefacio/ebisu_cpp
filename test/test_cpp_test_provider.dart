library ebisu_cpp.test.test_cpp_test_provider;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_test_provider');

// custom <library test_cpp_test_provider>

// end <library test_cpp_test_provider>
main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('scenario', () {
    _logger.info(scenario('foo_bar'));
  });

// end <main>

}
