import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  var c = class_('foo')
    ..memberCtors = [ memberCtor([])..decls.add('int i') ]
    ..members = [
      member('t')..init = 3.14..cppAccess = public,
      member('x')..init = 0..cppAccess = public,
      member('y')..init = '"goo"'..cppAccess = public,
      member('z')..type = 'Z'..cppAccess = public..init = 'i',
    ];

  print(clangFormat(c.definition));

}