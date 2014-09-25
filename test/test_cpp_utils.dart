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

// end <main>

}
