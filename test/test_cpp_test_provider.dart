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
  Logger.root.level = Level.INFO;
// custom <main>

  vectorSample() => testScenario('basics',
      given('a vector with some items', [
        when('the size is increased',
            then('the size and capacity change')),
        when('the size is reduced',
            then('the size channges but not capacity')),
        when('more capacity is reserved',
            then('the capacity changes but not the size')),
        when('less capacity is reserved',
            then('neither size nore capacity is changed')),
      ]));

  test('test_scenario', () {
    final sampleTestScenario = vectorSample();
    _logger.info(sampleTestScenario);
  });

// end <main>

}
