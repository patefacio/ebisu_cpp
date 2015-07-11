import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  print(enum_('gl_buffer')
      ..values = [ 'gl_color_buffer', 'gl_depth_buffer',
        'gl_accum_buffer', 'gl_stencil_buffer' ]
      ..isMask = true);

  print(enum_('region')..values = ['north', 'south', 'east', 'west']);

  print(enum_('thresholds')
      ..values = [
        enumValue('high', 100),
        enumValue('medium', 50),
        enumValue('low', 10)
      ]);

  var e = enum_('color_basic')
    ..values = ['red', 'green', 'blue'].map((c) => 'cb_$c');
  print(e);

  print(enum_('color_as_class')
      ..values = ['red', 'green', 'blue']
      ..isClass = true);


  print(enum_('color_with_base')
        ..values = ['red', 'green', 'blue']
        ..enumBase = 'std::int8_t');

  print(enum_('color')
        ..values = ['red', 'green', 'blue']
        ..enumBase = 'std::int8_t'
        ..isClass = true
        ..isStreamable = true
        );


  print(enum_('color')
        ..values = ['red', 'green', 'blue']
        ..enumBase = 'std::int8_t'
        ..isClass = true
        ..isStreamable = true
        ..hasFromCStr = true
        );

  e = enum_('color_as_class_with_base')
    ..values = ['red', 'green', 'blue'].map((c) => 'cacwb_$c')
    ..isClass = true
    ..enumBase = 'std::int8_t';
  print(e);


  e = enum_('color_hex')
    ..isClass = true
    ..hasToCStr = true
    ..hasFromCStr = true
    ..isDisplayedHex = true
    ..values = [
      enumValue('red', 0xA00000)..doc = 'Red value is red',
      enumValue('green', 0x009900)..doc = 'Green value is green',
      enumValue('blue', 0x3333FF)..doc = 'Blue value is blue',
    ];

  print(e);

  e = enum_('color')
    ..values = ['red', 'green', 'blue']
    ..isStreamable = true
    ..isMask = true;
  print(e);


  e = enum_('uses_predefined')
    ..values = [ enumValue('open', 'OPEN'), enumValue('close', 'CLOSE')]
    ..isStreamable = true;
  print(e);

}