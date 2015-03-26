import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {

  var i = new Interface('alarmist')
    ..doc = 'Methods that cause alarm'
    ..methodDecls = [
      'void shoutsFireInTheater(int volume)',
      'void wontStopWithTheGlobalWarming()',
      new MethodDecl.fromDecl('void growl()')..doc = 'Scare them'
    ];

  final c = class_('foo_bar')
    ..implementedInterfaces = [ i ]
    ..getMethod('alarmist').snippets.add('// my injection');

  print(c);
}