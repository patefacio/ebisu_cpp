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
          'handle_value_$enumerator(buffer);\nbreak;');
      if (showCode) print(switchDispatcher.dispatchBlock);
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
default: assert(!"Enumerator not in {1, 2, 3, 4}");
}
'''));
    });

    test('SwitchDispatcher disallows string', () {
      expect(() => new SwitchDispatcher(['foo', 'bar',], null)..dispatchBlock,
          throws);
    });

    test('IfElseIfDispatcher', () {
      final dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
        'goo',
        'baz'
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);');

      if (showCode) print(dispatcher.dispatchBlock);
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

    test('IfElseIfDispatcher (d is cptr, e is string) uses e.== ', () {
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

    test('IfElseIfDispatcher (e is cptr, d is string) uses d.== ', () {
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

    test('IfElseIfDispatcher (e is cptr, d is cptr) uses strcmp ', () {
      var dispatcher = new IfElseIfDispatcher([
        'foo',
        'bar',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);')
        ..discriminatorType = dctCptr
        ..enumeratorType = dctCptr;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
char const* const& discriminator_ { discriminator };
if(strcmp(foo, discriminator_) == 0) {
  handleValuefoo(buffer);
} else if(strcmp(bar, discriminator_) == 0) {
  handleValuebar(buffer);
} else {
  assert(!"Enumerator not in {foo, bar}");
}
'''));
    });

    test('IfElseIfDispatcher (d is dctInteger, e is dctInteger) uses == ', () {
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

    test('IfElseIfDispatcher (d is int literal, e is dctInteger) uses == ', () {
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

    test('CharBinaryDispatcher with single entry', () {
      var dispatcher = new CharBinaryDispatcher([
        '125',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);\nreturn;')
        ..enumeratorType = dctStringLiteral;

      if (showCode) print(dispatcher.dispatchBlock);
      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_ { discriminator };
size_t discriminator_length_ { discriminator_.length() };
if(1 > discriminator_length_) assert(!"Enumerator not in {125}");
if(strncmp("125", &discriminator_[0], 3) == 0) {
  // Leaf node: potential hit on "125"
  if(3 == discriminator_length_) {
    // Hit on "125"
    handleValue125(buffer);
    return;
  }
  assert(!"Enumerator not in {125}");
}'''));
    });

    test('CharBinaryDispatcher with continue and logged error', () {
      var dispatcher = new CharBinaryDispatcher(['125',], (dispatcher,
          enumerator) => 'handleValue$enumerator(buffer);\ncontinue;')
        ..errorDispatcher =
        ((_) => 'std::cerr << "Bogus tag " << discriminator;')
        ..enumeratorType = dctStringLiteral;

      if (showCode) print(dispatcher.dispatchBlock);
      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_ { discriminator };
size_t discriminator_length_ { discriminator_.length() };
if(1 > discriminator_length_) std::cerr << "Bogus tag " << discriminator;
if(strncmp("125", &discriminator_[0], 3) == 0) {
  // Leaf node: potential hit on "125"
  if(3 == discriminator_length_) {
    // Hit on "125"
    handleValue125(buffer);
    continue;
  }
  std::cerr << "Bogus tag " << discriminator;
}
'''));
    });

    test('CharBinaryDispatcher many tags', () {
      var dispatcher = new CharBinaryDispatcher([
        '125',
        '32',
        '256',
        '124',
        '1258',
        '1259',
        '13',
        '2568',
      ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);\nreturn;')
        ..errorDispatcher = ((_) => 'return;')
        ..enumeratorType = dctStringLiteral;

      expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_ { discriminator };
size_t discriminator_length_ { discriminator_.length() };
if(1 > discriminator_length_) return;
if('1' == discriminator_[0]) {
  if(2 > discriminator_length_) return;

  if('2' == discriminator_[1]) {
    if(3 > discriminator_length_) return;

    if('4' == discriminator_[2]) {
      // Leaf node: potential hit on "124"
      if(3 == discriminator_length_) {
        // Hit on "124"
        handleValue124(buffer);
        return;

      }
      return;
    }

    if('5' == discriminator_[2]) {
      // Leaf node: potential hit on "125"
      if(3 == discriminator_length_) {
        // Hit on "125"
        handleValue125(buffer);
        return;

      }
      if(4 > discriminator_length_) return;

      if('8' == discriminator_[3]) {
        // Leaf node: potential hit on "1258"
        if(4 == discriminator_length_) {
          // Hit on "1258"
          handleValue1258(buffer);
          return;

        }
        return;
      }

      if('9' == discriminator_[3]) {
        // Leaf node: potential hit on "1259"
        if(4 == discriminator_length_) {
          // Hit on "1259"
          handleValue1259(buffer);
          return;

        }
        return;
      }
      return;
    }
    return;
  }

  if('3' == discriminator_[1]) {
    // Leaf node: potential hit on "13"
    if(2 == discriminator_length_) {
      // Hit on "13"
      handleValue13(buffer);
      return;

    }
    return;
  }
  return;
}
if(strncmp("256", &discriminator_[0], 3) == 0) {
  // Leaf node: potential hit on "256"
  if(3 == discriminator_length_) {
    // Hit on "256"
    handleValue256(buffer);
    return;

  }
  if(2 > discriminator_length_) return;

  if('8' == discriminator_[3]) {
    // Leaf node: potential hit on "2568"
    if(4 == discriminator_length_) {
      // Hit on "2568"
      handleValue2568(buffer);
      return;

    }
    return;
  }
  return;
}
if(strncmp("32", &discriminator_[0], 2) == 0) {
  // Leaf node: potential hit on "32"
  if(2 == discriminator_length_) {
    // Hit on "32"
    handleValue32(buffer);
    return;

  }
  return;
}
'''));
    });
  });

  test('StrlenBinaryDispatcher with continue and logged error', () {
    var dispatcher = new StrlenBinaryDispatcher([
      '1',
      '12',
      '13',
      '21',
      '22'
          '125',
    ], (dispatcher, enumerator) => 'handleValue$enumerator(buffer);\ncontinue;')
      ..errorDispatcher = ((_) => 'std::cerr << "Bogus tag " << discriminator;')
      ..enumeratorType = dctStringLiteral;

    if (showCode) print(clangFormat(dispatcher.dispatchBlock));

    expect(darkMatter(dispatcher.dispatchBlock), darkMatter('''
std::string const& discriminator_{discriminator};
size_t discriminator_length_{discriminator_.length()};
switch (discriminator_length_) {
  case 1: {
    if ('1' == discriminator_[0]) {
      // Hit on "1"
      handleValue1(buffer);
      continue;
    }

    std::cerr << "Bogus tag " << discriminator;
    break;
  }
  case 2: {
    if ('1' == discriminator_[0]) {
      if ('2' == discriminator_[1]) {
        // Hit on "12"
        handleValue12(buffer);
        continue;
      }

      if ('3' == discriminator_[1]) {
        // Hit on "13"
        handleValue13(buffer);
        continue;
      }
    }
    if (strncmp("21", &discriminator_[0], 2) == 0) {
      // Hit on "21"
      handleValue21(buffer);
      continue;
    }

    std::cerr << "Bogus tag " << discriminator;
    break;
  }
  case 5: {
    if (strncmp("22125", &discriminator_[0], 5) == 0) {
      // Hit on "22125"
      handleValue22125(buffer);
      continue;
    }

    std::cerr << "Bogus tag " << discriminator;
    break;
  }

  default:
    std::cerr << "Bogus tag " << discriminator;
}
'''));
  });

// end <main>

}
