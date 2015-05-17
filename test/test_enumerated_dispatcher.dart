library ebisu_cpp.test_enumerated_dispatcher;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_enumerated_dispatcher');

// custom <library test_enumerated_dispatcher>
// end <library test_enumerated_dispatcher>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('enumerated dispatcher', () {
    test('SwitchEnumeratedDispatcher', () {
      final switchDispatcher = new SwitchEnumeratedDispatcher([
        1,
        2,
        3,
        4
      ], (EnumeratedDispatcher dispatcher, enumerant) => 'handleValue$enumerant(buffer);');

      print(switchDispatcher.dispatchBlock);
    });

  });

// end <main>

}
