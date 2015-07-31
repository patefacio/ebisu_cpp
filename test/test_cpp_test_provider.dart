library ebisu_cpp.test_cpp_test_provider;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

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

  vectorSample() => testScenario(
      'basics',
      given('a vector with some items', [
        when('the size is increased', then('the size and capacity change')),
        when('the size is reduced', then('the size channges but not capacity')),
        when('more capacity is reserved',
            then('the capacity changes but not the size')),
        when('less capacity is reserved',
            then('neither size nore capacity is changed')),
      ]));

  test('test_scenario', () {
    final sampleTestScenario = vectorSample();
    sampleTestScenario.setAsRoot();
    expect(
        darkSame(
            br(scenarioTestText(sampleTestScenario)),
            '''
SCENARIO("basics") {
  GIVEN("a vector with some items") {
  // custom <(862084306)>
  // end <(862084306)>
    WHEN("the size is increased") {
    // custom <(107134793)>
    // end <(107134793)>
      THEN("the size and capacity change") {
      // custom <(184273324)>
      // end <(184273324)>

      }
    }
    WHEN("the size is reduced") {
    // custom <(521367897)>
    // end <(521367897)>
      THEN("the size channges but not capacity") {
      // custom <(876011019)>
      // end <(876011019)>

      }
    }
    WHEN("more capacity is reserved") {
    // custom <(841127201)>
    // end <(841127201)>
      THEN("the capacity changes but not the size") {
      // custom <(1014174369)>
      // end <(1014174369)>

      }
    }
    WHEN("less capacity is reserved") {
    // custom <(104907496)>
    // end <(104907496)>
      THEN("neither size nore capacity is changed") {
      // custom <(892845018)>
      // end <(892845018)>

      }
    }

  }
}
'''),
        true);
  });

// end <main>
}
