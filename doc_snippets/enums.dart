import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  print(enum_('gl_buffer')
      ..values = [ 'gl_color_buffer', 'gl_depth_buffer',
        'gl_accum_buffer', 'gl_stencil_buffer' ]
      ..isMask = true);

  print(enum_('region')..values = ['north', 'south', 'east', 'west']);

  print(enum_('thresholds')
      ..valueMap = { 'high' : 100, 'medium' : 50, 'low' : 10 });

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


  e = enum_('color')
    ..valueMap = {'red': 0xA00000, 'green': 0x009900, 'blue': 0x3333FF}
    ..isDisplayedHex = true
    ..isStreamable = true;
  print(e);


  e = enum_('color')
    ..values = ['red', 'green', 'blue']
    ..isStreamable = true
    ..isMask = true;
  print(e);

}