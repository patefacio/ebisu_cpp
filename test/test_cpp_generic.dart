library ebisu_cpp.test.test_cpp_generic;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_generic');

// custom <library test_cpp_generic>
// end <library test_cpp_generic>
main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  darkSame(a, b) => expect(darkMatter(a), darkMatter(b));

  group('traits', () {
    test('using', () {
      darkSame(new Using('a', 'vector<int>'), 'using aT = vector<int>;');
      darkSame(using('a = vector<it>'), 'using aT = vector<it>;');
      darkSame(using(new Using('goo', 'vector<vector<x>>')),
          'using gooT = vector<vector<x>>;');
      darkSame(using('this_is_a_test', 'List<int>'),
          'using thisIsATestT = List<int>;');
    });
  });

// end <main>

}
