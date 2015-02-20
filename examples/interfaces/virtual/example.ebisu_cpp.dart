import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  Header h = header('animal')
    ..interfaces = [
      interface('scare_tactics')
      ..methodDecls = [
        methodDecl('void makeAudibleWarning(int intensity)'),
        'void makeVisibleWarning(int intensity)',
        methodDecl('void showWeapons()'),
      ],
    ];

}