import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:logging/logging.dart';

main() {

  Logger.root
    ..onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"))
    ..level = Level.INFO;

  final scareTactics = interface('scare_tactics')
    ..methodDecls = [
      methodDecl('void makeAudibleWarning(int intensity)'),
      'void makeVisibleWarning(int intensity)',
      methodDecl('void showWeapons()'),
    ];

  final eatingHabbits = interface('eating_habbits')
    ..methodDecls = [
      'void eatMeat(int proteinContent) const',
      'void eatVeggies()',
    ];

  Header h = header('animal')
    ..interfaces = [ scareTactics, eatingHabbits ]
    ..namespace = namespace(['animal'])
    ..classes = [
      class_('dog')
      ..interfaceImplementations = [
        scareTactics,
        new InterfaceImplementation(eatingHabbits, protected)
        ..isVirtual = false

      ]
    ];

  h.owner = null;

  print(clangFormat(h.contents));
}