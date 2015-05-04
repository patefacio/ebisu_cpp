library ebisu_cpp.test_cpp_exception;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';

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
      /// Note inclusion of <stdexcept> and default ctors
      expect(darkMatter(h.contents).contains(darkMatter('''
#include <stdexcept>

namespace foo {
class Bogus_error :
  public std::runtime_error
{

public:

  /// Constructs exception object with explanatory what_arg accessible through what().
  explicit Bogus_error( const std::string& what_arg ) : std::runtime_error(what_arg) {
  }

  /// Constructs exception object with explanatory what_arg accessible through what().
  explicit Bogus_error( const char* what_arg )  : std::runtime_error(what_arg) {
  }

};
''')), true);
    });
  });

// end <main>

}
