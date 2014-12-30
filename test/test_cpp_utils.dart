library ebisu_cpp.test.test_cpp_utils;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_utils>
// end <library test_cpp_utils>
main() {
// custom <main>

  final ws = new RegExp(r'\s+');
  test('namespace', () {
    final ns = namespace(['a','b','c']).wrap('this is a test');
    final expected = '''
namespace a {
namespace b {
namespace c {
  this is a test
} // namespace c
} // namespace b
} // namespace a
''';
    expect(ns.toString().replaceAll(ws, ''),
        expected.replaceAll(ws, ''));
  });

  test('headers', () {
    final inc = includes(
      [
        'boost/filesystem.hpp', 'foo.hpp', 'bar.hpp', 'cstring', 'cmath', 'iosfwd'
      ]);

    inc.add('iostream');
    inc.addAll(['iostream', 'foo.hpp', 'boost/filesystem.hpp', 'boost/function.hpp']);

    expect(inc.includeEntries.where((i) => i.contains('filesystem.hpp')).length, 1);
    expect(inc.includeEntries.contains('#include "bar.hpp"'), true);
    expect(inc.includeEntries.contains('#include <iostream>'), true);
  });

  test('code_blocks', () {
    final cb = codeBlock('foo public');
    var cbText = cb.toString();
    expect(cbText.contains('// custom <foo public>'), true);
    expect(cbText.contains('// end <foo public>'), true);

    cb.snippets.addAll(['This','is','a','test']);
    cbText = cb.toString();
    expect(['This\n', 'is\n', 'a\n', 'test']
        .every((t) => cbText.contains(t)), true);
  });

  test('template', () {
    final txt = template(['int T']).decl;
    expect([ 'template','<','int T', '>']
        .every((t) => txt.contains(t)), true);
  });


// end <main>

}
