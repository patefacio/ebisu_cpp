library ebisu_cpp.test.test_hdf5_support;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/hdf5_support.dart';
// end <additional imports>

// custom <library test_hdf5_support>
// end <library test_hdf5_support>
main() {
// custom <main>

  newInstallation() => installation('sample')
    ..libs = [lib('l')..headers = [header('h')..classes = [class_('c')]]];

  group('class augmentation', () {
    final installation = newInstallation();

    test('friends added', () {
      installation..decorateWith(packetTableDecorator([logGroup('c')]));

      print(installation.progeny
          .where((e) => e.id.snake == 'c')
          .map((e) => e.definition));
    });
  });

// end <main>

}
