library ebisu_cpp.test_cpp_exception;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:id/id.dart';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_exception');

// custom <library test_cpp_exception>
// end <library test_cpp_exception>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('exception class', () {
    final h = header('h')
      ..namespace = namespace(['foo'])
      ..classes = [exceptionClass('bogus_error')];

    test('basic exception', () {
      expect(darkMatter(h.contents).contains(darkMatter('''
#include <boost/exception/exception.hpp>
#include <stdexcept>

namespace foo {
class Bogus_error :
  public virtual std::runtime_error,
  public virtual boost::exception
{

};
}
''')), true);
    });

    test('exception with what', () {
      final excpClass = exceptionClass('bad_deal', 'std::runtime_error');
      excpClass.setAsRoot();
      expect(darkMatter(excpClass.definition).contains(darkMatter('''
class Bad_deal :
  public virtual std::runtime_error,
  public virtual boost::exception
{

public:

  /// Constructs exception object with explanatory what_arg accessible through what().
  explicit Bad_deal( const std::string& what_arg ) : std::runtime_error(what_arg) {
  }

  /// Constructs exception object with explanatory what_arg accessible through what().
  explicit Bad_deal( const char* what_arg )  : std::runtime_error(what_arg) {
  }

};
''')), true);
    });

  });

// end <main>
}
