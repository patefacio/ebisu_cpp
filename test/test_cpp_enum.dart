library ebisu_cpp.test.test_cpp_enum;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_enum>
// end <library test_cpp_enum>
main() {
// custom <main>

  test('basic', () {
    [ true, false ].forEach((bool isClass) {
      final id = 'color_${isClass}';
      var sample = cppEnum(id)
        ..isClass = isClass
        ..hasToCStr = true
        ..hasFromCStr = true
        ..values = [ 'red', 'green', 'blue' ];
      print(sample);
      sample = cppEnum('${id}_map')
        ..isClass = isClass
        ..hasToCStr = true
        ..hasFromCStr = true
        ..valueMap = {
          'red' : 0xA00000,
          'green' : 0x009900,
          'blue' : 0x3333FF,
        };
      print(sample);
      sample = cppEnum('${id}_mask')
        ..isClass = isClass
        ..values = [ 'red', 'green', 'blue' ]
        ..isMask = true;
      print(sample);
    });
  });
// end <main>

}
