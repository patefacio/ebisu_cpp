library ebisu_cpp.test_cpp_header;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_header');

// custom <library test_cpp_header>
// end <library test_cpp_header>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('duplicate protection', () {
    final ns = namespace(['test']);
    final headerPragmaOnce = header('pragmaonce')
      ..setAsRoot()
      ..namespace = ns
      ..usePragmaOnce = true;

    final headerIncludeGuards = header('guards')..namespace = ns;

    expect(darkMatter(headerIncludeGuards.contents).contains(darkMatter('''
#ifndef __TEST_GUARDS_HPP__
#define __TEST_GUARDS_HPP__
#endif // __TEST_GUARDS_HPP__
 ''')), true);

    expect(headerPragmaOnce.contents.contains('#pragma once'), true);
  });

// end <main>
}
