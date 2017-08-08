library ebisu_cpp.test_cpp_interface;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu_cpp/ebisu_cpp.dart';
// end <additional imports>

final Logger _logger = new Logger('test_cpp_interface');

// custom <library test_cpp_interface>
// end <library test_cpp_interface>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('shared interface', () {
    final scareTactics = interface('scare_tactics')
      ..methodDecls = [
        methodDecl('void makeAudibleWarning(int intensity)')
          ..doc = 'Noise is the scariest weapon some animals have',
        'void makeVisibleWarning(int intensity)',
        methodDecl('void showWeapons()'),
      ];

    final eatingHabbits = interface('eating_habbits')
      ..methodDecls = [
        'void eatMeat(int proteinContent) const',
        'void eatVeggies()',
      ];

    Header h = header('animal')
      ..interfaces = [scareTactics, eatingHabbits]
      ..namespace = namespace(['animal'])
      ..classes = [
        class_('dog')
          ..interfaceImplementations = [
            scareTactics.createImplementation(
                cppAccess: public, isVirtual: true),
            eatingHabbits.createImplementation(
                cppAccess: protected, isVirtual: false),
          ]
      ];

    h.setAsRoot();

    //print(h.contents);
  });

// end <main>
}
