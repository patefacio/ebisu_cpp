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

  final showCode = false;
  group('dispatcher', () {
    test('SwitchDispatcher', () {
      final switchDispatcher = new SwitchDispatcher([
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

      if (showCode) print(switchDispatcher.dispatchBlock);
    });

    test('SwitchDispatcher disallows string', () {
      expect(() => new SwitchDispatcher(['foo', 'bar',], null)
        ..dispatchBlock, throws);
    });

    test('IfElseIfDispatcher', () {
      final dispatcher = new IfElseIfDispatcher([
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
      if (showCode) print(dispatcher.dispatchBlock);
    });

    test('IfElseIfDispatcher (d is cptr, e is string) uses e.== ',
        () {
      var dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctCptr;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
char const* const& discriminator_ { discriminator };
if(foo == discriminator_) {
  handleValuefoo(buffer);
} else if(bar == discriminator_) {
  handleValuebar(buffer);
} else {
  assert(!"Enumerator not in {foo, bar}");
}
'''));
    });

    test('IfElseIfDispatcher (e is cptr, d is string) uses d.== ',
        () {
      var dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctStdString
        ..enumeratorType = dctCptr;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_ { discriminator };
if(discriminator_ == foo}) {
  handleValuefoo(buffer);
} else if(discriminator_ == bar}) {
  handleValuebar(buffer);
} else {
  assert(!"Enumerator not in {foo, bar}");
}
'''));
    });

    test('IfElseIfDispatcher (e is cptr, d is cptr) uses strcmp ',
        () {
      var dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctCptr
        ..enumeratorType = dctCptr;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
char const* const& discriminator_ { discriminator };
if(strcmp(foo, discriminator_)) {
  handleValuefoo(buffer);
} else if(strcmp(bar, discriminator_)) {
  handleValuebar(buffer);
} else {
  assert(!"Enumerator not in {foo, bar}");
}
'''));
    });

    test(
        'IfElseIfDispatcher (d is dctInteger, e is dctInteger) uses == ',
        () {
      var dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctInteger
        ..enumeratorType = dctInteger;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
int const& discriminator_ { discriminator };
if(foo == discriminator_) {
  handleValuefoo(buffer);
} else if(bar == discriminator_) {
  handleValuebar(buffer);
} else {
  assert(!"Enumerator not in {foo, bar}");
}
'''));
    });

    test(
        'IfElseIfDispatcher (d is int literal, e is dctInteger) uses == ',
        () {
      var dispatcher = new IfElseIfDispatcher([
        1,
        2,
        3
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctInteger
        ..enumeratorType = dctInteger;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
int const& discriminator_ { discriminator };
if(1 == discriminator_) {
  handleValue1(buffer);
} else if(2 == discriminator_) {
  handleValue2(buffer);
} else if(3 == discriminator_) {
  handleValue3(buffer);
} else {
  assert(!"Enumerator not in {1, 2, 3}");
}
'''));
    });
  });

// end <main>

}
