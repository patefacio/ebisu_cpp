library ebisu_cpp.test_cpp_template;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:petitparser/dart.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';
// end <additional imports>

final Logger _logger = new Logger('test_cpp_template');

// custom <library test_cpp_template>

// end <library test_cpp_template>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  group('template decorations', () {
    test('template with non-defaulted type parm', () {
      final t = template(['typename T']);
      expect(darkMatter(t), darkMatter('template< typename T >'));
    });
    test('template with defaulted type parm', () {
      final t = template(['typename T = int']);
      expect(darkMatter(t), darkMatter('template< typename T = int >'));
    });
    test('non-template without defaulted type parm', () {
      final t = template(['int size']);
      expect(darkMatter(t), darkMatter('template< int SIZE >'));
    });
    test('non-template with defaulted type parm', () {
      final t = template(['int size = 200']);
      expect(darkMatter(t), darkMatter('template< int SIZE = 200 >'));
    });

    test('templatized type parm', () {
      final t = template(['template < typename, typename > class Foo']);
      expect(darkMatter(t),
          darkMatter('template < template < typename, typename > class Foo >'));
    });
  });

  test('template parser ctor', () {
    var tp = new TemplateParser();

    //parse(s) => print('$s => ${tp.accept(s)}');
    parse(s) => null;

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
