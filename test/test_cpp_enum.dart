library ebisu_cpp.test_cpp_enum;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_enum');

// custom <library test_cpp_enum>
// end <library test_cpp_enum>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
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
    default: {
      return "Invalid Color_$isClass";
    }
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

      final mapperEnumWithHexDisplay = enum_('${id}_mapper')
        ..isClass = isClass
        ..hasToCStr = true
        ..hasFromCStr = true
        ..isDisplayedHex = true
        ..values = [
          enumValue('red', 0xA00000),
          enumValue('green', 0x009900),
          enumValue('blue', 0x3333FF)
        ];

      if (false) print(mapperEnumWithHexDisplay.toString());

      expect(darkMatter(mapperEnumWithHexDisplay.toString()), darkMatter('''
enum ${isClass? 'class':''} Color_${isClass}_mapper {
  Red_e = 0xa00000,
  Green_e = 0x009900,
  Blue_e = 0x3333ff
};

inline char const* to_c_str(Color_${isClass}_mapper e) {
  switch(e) {
    case Color_${isClass}_mapper::Red_e: return "Red_e";
    case Color_${isClass}_mapper::Green_e: return "Green_e";
    case Color_${isClass}_mapper::Blue_e: return "Blue_e";
    default: {
      return "Invalid Color_${isClass}_mapper";
    }
  }
}

inline void from_c_str(char const* str, Color_${isClass}_mapper &e) {
  using namespace std;
  if(0 == strcmp("Red_e", str)) { e = Color_${isClass}_mapper::Red_e; return; }
  if(0 == strcmp("Green_e", str)) { e = Color_${isClass}_mapper::Green_e; return; }
  if(0 == strcmp("Blue_e", str)) { e = Color_${isClass}_mapper::Blue_e; return; }
  string msg { "No Color_${isClass}_mapper matching:" };
  throw std::runtime_error(msg + str);
}
'''));

      final sample_mask = enum_('${id}_mask')
        ..isClass = isClass
        ..values = ['red', 'green', 'blue']
        ..hasBitmaskFunctions = true
        ..isMask = true;

      if (false) print(sample_mask.toString());
      expect(darkMatter(sample_mask.toString()), darkMatter('''
enum ${isClass? "class ":""}Color_${isClass}_mask {
  Red_e = 1 << 0,
  Green_e = 1 << 1,
  Blue_e = 1 << 2
};


/// Test if the Color_${isClass}_mask *bit* is set in *value* mask
inline bool test_bit(int value, Color_${isClass}_mask bit) {
  return (bit & value) == bit;
}

/// Set the Color_${isClass}_mask *bit* in *value* mask
inline void set_bit(int &value, Color_${isClass}_mask bit) {
  value |= bit;
}

/// Cllear the Color_${isClass}_mask *bit* in *value* mask
inline void clear_bit(int &value, Color_${isClass}_mask bit) {
  value &= ~bit;
}
'''));

      final sample_mask_base = enum_('${id}_mask')
        ..isClass = isClass
        ..enumBase = 'std::int8_t'
        ..isStreamable = true
        ..values = ['red', 'green', 'blue']
        ..isMask = true;

      if (false) print(sample_mask_base);

      final expectedDefinition = '''
enum ${isClass? "class ":""}Color_${isClass}_mask : std::int8_t {
  Red_e = 1 << 0,
  Green_e = 1 << 1,
  Blue_e = 1 << 2
};

inline std::string Color_${isClass}_mask_mask_to_str(std::int8_t e) {
  std::ostringstream out__;
  out__ << '(' << std::hex << int(e) << std::dec << ")[";
  if(e & std::int8_t(Color_${isClass}_mask::Red_e)) { out__ << "Color_${isClass}_mask::Red_e, ";}
  if(e & std::int8_t(Color_${isClass}_mask::Green_e)) { out__ << "Color_${isClass}_mask::Green_e, ";}
  if(e & std::int8_t(Color_${isClass}_mask::Blue_e)) { out__ << "Color_${isClass}_mask::Blue_e, ";}
  out__ << ']';
  return out__.str();
}

inline std::ostream& operator<<(std::ostream &out, Color_${isClass}_mask e) {
  return out << Color_${isClass}_mask_mask_to_str(std::int8_t(e));
}
''';
      expect(darkMatter(sample_mask_base.toString()),
          darkMatter(expectedDefinition));
    });
  });

  test('enumValue', () {
    final e = enum_('with_values')
      ..isClass = true
      ..enumBase = 'std::int8_t'
      ..isStreamable = true
      ..values = [
        enumValue('foo', 1)..doc = 'This is a foo',
        enumValue('bar', 2)..doc = 'This is a bar',
      ];

    expect(darkMatter(e.toString()), darkMatter('''
enum class With_values : std::int8_t {
  /**
   This is a foo
  */
  Foo_e = 1,
  /**
   This is a bar
  */
  Bar_e = 2
};

inline char const* to_c_str(With_values e) {
  switch(e) {
    case With_values::Foo_e: return "Foo_e";
    case With_values::Bar_e: return "Bar_e";
    default: {
      return "Invalid With_values";
    }
  }
}

inline std::ostream& operator<<(std::ostream &out, With_values e) {
  return out << to_c_str(e);
}
'''));
  });

  test('enum mask with bit assigned', () {
    final sample_mask = enum_('mask_with_green_bit_specified')
      ..isClass = true
      ..values = ['red', enumValue('green', 5), 'blue']
      ..isMask = true;

    expect(darkMatter(sample_mask.toString()), darkMatter('''
enum class Mask_with_green_bit_specified {
  Red_e = 1 << 0,
  Green_e = 1 << 5,
  Blue_e = 1 << 2
};
'''));
  });

  test('nested enum mask', () {
    final cls = class_('nesting')
      ..isStreamable = true
      ..enums = [
        enum_('mask_with_green_bit_specified')
          ..isClass = true
          ..values = ['red', enumValue('green', 5), 'blue']
          ..isMask = true
          ..isStreamable = true
      ]
      ..members = [member('n')..type = 'Mask_with_green_bit_specified']
      ..owner = null;

    expect(darkMatter(cls.definition), darkMatter(r'''
class Nesting
{

public:
  enum class Mask_with_green_bit_specified {
    Red_e = 1 << 0,
    Green_e = 1 << 5,
    Blue_e = 1 << 2
  };
  static inline std::string Mask_with_green_bit_specified_mask_to_str(int e) {
    std::ostringstream out__;
    out__ << '(' << std::hex << e << std::dec << ")[";
    if(e & int(Mask_with_green_bit_specified::Red_e)) { out__ << "Mask_with_green_bit_specified::Red_e, ";}
    if(e & int(Mask_with_green_bit_specified::Green_e)) { out__ << "Mask_with_green_bit_specified::Green_e, ";}
    if(e & int(Mask_with_green_bit_specified::Blue_e)) { out__ << "Mask_with_green_bit_specified::Blue_e, ";}
    out__ << ']';
    return out__.str();
  }

  friend inline std::ostream& operator<<(std::ostream &out, Mask_with_green_bit_specified e) {
    return out << Mask_with_green_bit_specified_mask_to_str(int(e));
  }

  friend inline
  std::ostream& operator<<(std::ostream &out,
                           Nesting const& item) {
    out << "Nesting(" << &item << ") {";
    out << "\n  n:" << item.n_;
    out << "\n}\n";
    return out;
  }

private:
  Mask_with_green_bit_specified n_ {};

};
'''));
  });

// end <main>
}
