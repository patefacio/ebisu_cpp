library ebisu_cpp.test_cpp_union;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_union');

// custom <library test_cpp_union>
// end <library test_cpp_union>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('basic union', () {
    var u = union('basic_union')
      ..members = [
        member('x')
          ..type = 'int'
          ..hasNoInit = true,
        member('y')..type = 'double',
      ];

    u.setAsRoot();

    expect(darkMatter(u.definition), darkMatter('''
union Basic_union {
int x_;
double y_ {};
};
'''));
  });

  test('union with multiple inits throws', () {
    var u = union('basic_union')
      ..members = [member('x')..type = 'int', member('y')..type = 'double',];

    expect(() => u.setAsRoot(), throws);
  });

// end <main>
}
