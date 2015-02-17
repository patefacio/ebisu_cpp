library ebisu_cpp.test.test_cpp_enum;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

// custom <library test_cpp_enum>
// end <library test_cpp_enum>
main() {
// custom <main>

  final ws = new RegExp(r'\s+');

  test('basic', () {
    [true, false].forEach((bool isClass) {
      final id = 'color_${isClass}';
      final sample = enum_(id)
        ..isClass = isClass
        ..hasToCStr = true
        ..hasFromCStr = true
        ..values = ['red', 'green', 'blue'];

      final expected = '''
enum ${isClass? 'class':''} Color_$isClass {
  Red_e,
  Green_e,
  Blue_e
};
inline char const* to_c_str(Color_$isClass e) {
  switch(e) {
    case Color_$isClass::Red_e: return "Red_e";
    case Color_$isClass::Green_e: return "Green_e";
    case Color_$isClass::Blue_e: return "Blue_e";
  }
}
inline void from_c_str(char const* str, Color_$isClass &e) {
  using namespace std;
  if(0 == strcmp("Red_e", str)) { e = Color_$isClass::Red_e; return; }
  if(0 == strcmp("Green_e", str)) { e = Color_$isClass::Green_e; return; }
  if(0 == strcmp("Blue_e", str)) { e = Color_$isClass::Blue_e; return; }
  string msg { "No Color_$isClass matching:" };
  throw std::runtime_error(msg + str);
}
''';

      expect(sample.toString().replaceAll(ws, ''), expected.replaceAll(ws, ''));

      final sample_map = enum_('${id}_map')
        ..isClass = isClass
        ..hasToCStr = true
        ..hasFromCStr = true
        ..valueMap = {'red': 0xA00000, 'green': 0x009900, 'blue': 0x3333FF,};

      if (false) print(sample_map.toString());

      final sample_mask = enum_('${id}_mask')
        ..isClass = isClass
        ..values = ['red', 'green', 'blue']
        ..isMask = true;

      if (false) print(sample_mask.toString());
    });
  });
// end <main>

}
