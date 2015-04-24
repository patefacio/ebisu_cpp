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

  vectorSample() => testScenario('basics', given('a vector with some items', [
    when('the size is increased', then('the size and capacity change')),
    when('the size is reduced', then('the size channges but not capacity')),
    when('more capacity is reserved',
        then('the capacity changes but not the size')),
    when('less capacity is reserved',
        then('neither size nore capacity is changed')),
  ]));

  test('test_scenario', () {
    final sampleTestScenario = vectorSample();
    sampleTestScenario.owner = null;
    expect(darkSame(br(scenarioTestText(sampleTestScenario)), '''
SCENARIO("basics") {
  GIVEN("a vector with some items") {
  // custom <(862084306) a vector with some items>
  // end <(862084306) a vector with some items>
    WHEN("the size is increased") {
    // custom <(107134793) the size is increased>
    // end <(107134793) the size is increased>
      THEN("the_size_and_capacity_change") {
      // custom <(184273324) the size and capacity change>
      // end <(184273324) the size and capacity change>

      }
    }
    WHEN("the size is reduced") {
    // custom <(521367897) the size is reduced>
    // end <(521367897) the size is reduced>
      THEN("the_size_channges_but_not_capacity") {
      // custom <(876011019) the size channges but not capacity>
      // end <(876011019) the size channges but not capacity>

      }
    }
    WHEN("more capacity is reserved") {
    // custom <(841127201) more capacity is reserved>
    // end <(841127201) more capacity is reserved>
      THEN("the_capacity_changes_but_not_the_size") {
      // custom <(1014174369) the capacity changes but not the size>
      // end <(1014174369) the capacity changes but not the size>

      }
    }
    WHEN("less capacity is reserved") {
    // custom <(104907496) less capacity is reserved>
    // end <(104907496) less capacity is reserved>
      THEN("neither_size_nore_capacity_is_changed") {
      // custom <(892845018) neither size nore capacity is changed>
      // end <(892845018) neither size nore capacity is changed>

      }
    }

  }
}
'''), true);
  });

// end <main>

}
