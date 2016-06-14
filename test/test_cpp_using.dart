library ebisu_cpp.test_cpp_using;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_using');

// custom <library test_cpp_using>
// end <library test_cpp_using>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('basic using', () {
    final u = using('vec', 'std::vector<int>')
      ..doc = 'it is a simple using statement';

    expect(darkMatter(u.usingStatement), darkMatter('''
/** it is a simple using statement */
using Vec_t = std::vector<int>;
'''));

    expect(darkMatter(u.type), darkMatter('Vec_t'));
  });

  test('template using', () {
    final u = using('vec', 'std::vector<T>')
      ..doc = 'it is a templatized using'
      ..template = 'typename T';

    expect(darkMatter(u.usingStatement), darkMatter('''
/** it is a templatized using */
template<typename T> using Vec_t = std::vector<T>;
'''));

    expect(darkMatter(u.type), darkMatter('Vec_t'));
  });

  test('using function', () {
    expect(
        darkMatter(using('using int = int')), darkMatter('using Int_t = int;'));
    expect(darkMatter(using('vec_int', 'std::vector< int >')),
        darkMatter('using Vec_int_t = std::vector< int >;'));
    expect(
        darkMatter(
            using('vec_int', 'std::vector< T >')..template = ['typename T']),
        darkMatter(
            'template <typename T > using Vec_int_t = std::vector< T >;'));
  });

  test('using declaration', () {
    expect(darkMatter(using('foo::goo')), darkMatter('using foo::goo;'));
  });

// end <main>
}
