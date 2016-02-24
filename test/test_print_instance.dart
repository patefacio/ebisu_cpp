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
      ..isStruct = true
      ..defaultCppAccess = public
      ..members = [member('m')..init = 'a.m']
      ..giveDefaultPrinterSupport();

    final b = class_('b')
      ..defaultCppAccess = public
      ..members = [
        member('a')..type = 'A',
        member('n')..init = 'b.n'
      ]
      ..giveDefaultPrinterSupport();

    final c = class_('c')
      ..defaultCppAccess = public
      ..members = [
        member('b')..type = b.className,
        member('x')..init = "foo",
        member('y')..init = 3,
        member('z')..init = 3.14,
      ]
      ..giveDefaultPrinterSupport();

    final h = header('h')
      ..namespace = namespace(['test'])
      ..classes = [a, b, c]
      ..setAsRoot();

    print(clangFormat(h.contents));


    print((member('a')..type = 'int'..cppAccess = public).vname);
  });

// end <main>
}
