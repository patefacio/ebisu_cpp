library ebisu_cpp.test_cpp_switch;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_switch');

// custom <library test_cpp_switch>
// end <library test_cpp_switch>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('basic switch', () {
    final s = new Switch('some_input', [
      1,
      10,
      100
    ], (caseValue) => 'std::cout << $caseValue << std::endl;');

    expect(darkMatter(s.definition), darkMatter('''
switch (some_input) {
  case 1: {
    std::cout << 1 << std::endl;
    break;
  }
  case 10: {
    std::cout << 10 << std::endl;
    break;
  }
  case 100: {
    std::cout << 100 << std::endl;
    break;
  }
  default: {
    assert(!"value not in [1, 10, 100]");
    break;
  }
}
'''));
  });

  test('basic switch via function', () {
    final s = switch_('some_input', [
      1,
      10,
      100
    ], (caseValue) => 'std::cout << $caseValue << std::endl;');
    expect(darkMatter(s.definition), darkMatter('''
switch (some_input) {
  case 1: {
    std::cout << 1 << std::endl;
    break;
  }
  case 10: {
    std::cout << 10 << std::endl;
    break;
  }
  case 100: {
    std::cout << 100 << std::endl;
    break;
  }
  default: {
    assert(!"value not in [1, 10, 100]");
    break;
  }
}
'''));
  });

  test('basic char switch', () {
    final s = new Switch('some_char_input', [
      'x',
      'y',
      'z'
    ], (caseValue) => 'std::cout << $caseValue << std::endl;')..isChar = true;
    expect(darkMatter(s.definition), darkMatter('''
switch (some_char_input) {
  // Following is for character ('x'=120)
  case 'x': {
    std::cout << x << std::endl;
    break;
  }
  // Following is for character ('y'=121)
  case 'y': {
    std::cout << y << std::endl;
    break;
  }
  // Following is for character ('z'=122)
  case 'z': {
    std::cout << z << std::endl;
    break;
  }
  default: {
    assert(!"value not in ['x', 'y', 'z']");
    break;
  }
}
'''));
  });

// end <main>

}
