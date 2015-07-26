library ebisu_cpp.test_hdf5_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
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

  newInstallation() => installation('sample')
    ..libs = [
      lib('l')
        ..headers = [
          header('h')..classes = [class_('c')]
        ]
    ];

  group('class augmentation', () {
    final installation = newInstallation();

    test('friends added', () {
      installation..decorateWith(packetTableDecorator([logGroup('c')]));

      _logger.info(installation.progeny
          .where((e) => e.id.snake == 'c')
          .map((e) => e.definition));
    });
  });

// end <main>
}
