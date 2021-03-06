library ebisu_cpp.test_cpp_generic;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_generic');

// custom <library test_cpp_generic>
// end <library test_cpp_generic>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  group('traits', () {
    test('using', () {
      expect(darkSame(using('a', 'vector<int>'), 'using A_t = vector<int>;'),
          true);
      expect(
          darkSame(using('a = vector<it>'), 'using A_t = vector<it>;'), true);
      expect(
          darkSame(using(new UsingDirective('goo', 'vector<vector<x>>')),
              'using Goo_t = vector<vector<x>>;'),
          true);
      expect(
          darkSame(using('this_is_a_test', 'List<int>'),
              'using This_is_a_test_t = List<int>;'),
          true);
    });
  });

// end <main>
}
