library ebisu_cpp.test_cpp_default_methods;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_default_methods');

// custom <library test_cpp_default_methods>
// end <library test_cpp_default_methods>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('isNoExcept', () {
    final c1 = class_('c_1')
      ..defaultCtor.isNoExcept = true
      ..members = [member('a')..init = 1, member('b')..init = 2];

    expect(darkMatter(c1.definition), darkMatter('''
class C_1
{

public:
  C_1() noexcept(true) {
  }

private:
  int a_ { 1 };
  int b_ { 2 };

};
'''));
  });

// end <main>
}
