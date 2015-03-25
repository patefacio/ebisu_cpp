import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  var md = new Interface('alarmist')
    ..doc = 'Methods that cause alarm'
    ..methodDecls = [
      'void shoutsFireInTheater(int volume)',
      'void wontStopWithTheGlobalWarming()',
      new MethodDecl.fromDecl('void growl()')..doc = 'Scare them'
    ];
  print(md);
}