library ebisu_cpp.test_cpp_template;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:petitparser/dart.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
// end <additional imports>

final _logger = new Logger('test_cpp_template');

// custom <library test_cpp_template>

// end <library test_cpp_template>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('template parser ctor', () {
    var tp = new TemplateParser();

    parse(s) => print('$s => ${tp.accept(s)}');
    //parse(s) => null;

    [
      'template<>',
      ' template<>',
      'template < > ',
      '''
template <typename Foo,
typename Goo>
''',
      '''
template <typename Foo = int,
typename Goo>
''',
      '''
template <typename Foo = std::vector< int >,
typename Goo>
'''
    ].forEach((s) => parse(s));
  });

// end <main>
}
