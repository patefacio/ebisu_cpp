library ebisu_cpp.test.test_cpp_class;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_class>
// end <library test_cpp_class>
main() {
// custom <main>

  test('basic', () {
    final c = cppClass('c_1')
      ..basesPublic = ['Foo', 'Bar']
      ..enums = [
        cppEnum('letters')
        ..hasToCStr = true
        ..hasFromCStr = true
        ..values = [ 'a','b','c' ],
      ]
      ..forwardEnums = [
        cppEnum('abcs')..values = [ 'a','b','c'],
      ]
      ..forwardPtrs = [ sptr, uptr, scptr, ucptr ];

    print(c.definition);
  });
// end <main>

}
