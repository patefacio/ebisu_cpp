import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  var c = class_('foo')
    ..isStruct = true
    ..opEqual
    ..defaultCtor.usesDefault = true
    ..copyCtor.usesDefault = true
    ..moveCtor.usesDefault = true
    ..members = [
      member('t')..init = 3.14..cppAccess = public,
      member('x')..init = 0..cppAccess = public,
      member('y')..init = '"goo"'..cppAccess = public,
      member('z')..type = 'Z'..cppAccess = public
    ];

  print(clangFormat(c.definition));

}