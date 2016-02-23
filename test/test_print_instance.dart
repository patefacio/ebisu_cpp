library ebisu_cpp.test_print_instance;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_print_instance');

// custom <library test_print_instance>

// end <library test_print_instance>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('print_instance', () {
    final a = class_('a')
      ..members = [member('m')..init = 'a.m']
      ..giveDefaultPrinterSupport();

    final b = class_('b')..members = [member('n')..init = 'b.n'];

    final c = class_('c')
      ..members = [
        member('a')..type = a.className,
        member('x')..init = "foo",
        member('y')..init = 3,
        member('z')..init = 3.14,
      ]
      ..giveDefaultPrinterSupport();

    final h = header('h')
      ..namespace = namespace(['test'])
      ..classes = [a, b, c]
      ..setAsRoot();

    //print(clangFormat(h.contents));
  });

// end <main>
}
