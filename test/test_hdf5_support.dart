library ebisu_cpp.test_hdf5_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/hdf5_support.dart';

// end <additional imports>

final _logger = new Logger('test_hdf5_support');

// custom <library test_hdf5_support>
// end <library test_hdf5_support>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  //Logger.root.level = Level.INFO;
  newInstallation() => installation('sample')
    ..libs = [
      lib('l')
        ..headers = [
          header('h')
            ..includes.add('foo.h')
            ..namespace = namespace([])
            ..classes = [
              class_('c')..members = [member('a')..init = 1]
            ]
        ]
    ];

  group('class augmentation', () {
    final installation = newInstallation();

    test('friends added', () {
      installation..decorateWith(packetTableDecorator([logGroup('c')]));
      //print(installation.contents);

      _logger.info(brCompact(installation.progeny
          .where((e) => e.id.snake == 'c')
          .map((e) => e.definition)));
    });
  });

// end <main>
}
