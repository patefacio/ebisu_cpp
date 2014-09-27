library ebisu_cpp.test.test_cpp_utils;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_utils>
// end <library test_cpp_utils>
main() {
// custom <main>

  test('namespace', () {
    final ns = namespace(['a','b','c']);
    print(ns.wrap('this is a test'));
  });

  test('headers', () {
    final includes = headers(
      [
        'boost/filesystem.hpp', 'foo.hpp', 'bar.hpp', 'cstring', 'cmath', 'iosfwd'
      ]);

    includes.add('iostream');
    includes.addAll(['iostream', 'foo.hpp', 'boost/filesystem.hpp', 'boost/function.hpp']);

    print("Includes:\n${includes.includes}");
  });

  test('code_blocks', () {
    final cb = codeBlock('foo public');
    print(cb);
    cb.snippets.addAll(['This','is','a','test']);
    print(cb);
  });

// end <main>

}
