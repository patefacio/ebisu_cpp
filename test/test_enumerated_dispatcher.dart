library ebisu_cpp.test_enumerated_dispatcher;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/cookbook.dart';

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
      ], (EnumeratedDispatcher dispatcher, enumerator) =>
          'handle_value_$enumerator(buffer);');
      expect(darkMatter(switchDispatcher.dispatchBlock), darkMatter('''
switch(discriminator) {
case 1: {
  handle_value_1(buffer);
  break;
}
case 2: {
  handle_value_2(buffer);
  break;
}
case 3: {
  handle_value_3(buffer);
  break;
}
case 4: {
  handle_value_4(buffer);
  break;
}
}
'''));
    });

    test('SwitchEnumeratedDispatcher disallows string', () {
      expect(() => new SwitchEnumeratedDispatcher(['foo', 'bar',], null)
        ..dispatchBlock, throws);
    });

    test('IfElseIfEnumeratedDispatcher', () {
      final dispatcher = new IfElseIfEnumeratedDispatcher([
        'foo',
        'bar',
        'goo',
        'baz'
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);');

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_ { discriminator };
if(foo == discriminator_) {
  handleValuefoo(buffer);
} else if(bar == discriminator_) {
  handleValuebar(buffer);
} else if(goo == discriminator_) {
  handleValuegoo(buffer);
} else if(baz == discriminator_) {
  handleValuebaz(buffer);
} else {
  assert(!"Enumerator not in {foo, bar, goo, baz}");
}
'''));
    });
  });

// end <main>

}
