library ebisu_cpp.test.test_cpp_utils;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_utils');

// custom <library test_cpp_utils>
// end <library test_cpp_utils>
main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  final ws = new RegExp(r'\s+');
  test('namespace', () {
    final ns = namespace(['a', 'b', 'c']).wrap('this is a test');
    final expected = '''
namespace a {
namespace b {
namespace c {
  this is a test
} // namespace c
} // namespace b
} // namespace a
''';
    expect(ns.toString().replaceAll(ws, ''), expected.replaceAll(ws, ''));
  });

  test('headers', () {
    final inc = includes([
      'boost/filesystem.hpp',
      'foo.hpp',
      'bar.hpp',
      'cstring',
      'cmath',
      'iosfwd'
    ]);

    inc.add('iostream');
    inc.addAll(
        ['iostream', 'foo.hpp', 'boost/filesystem.hpp', 'boost/function.hpp']);

    expect(inc.includeEntries.where((i) => i.contains('filesystem.hpp')).length,
        1);
    expect(inc.includeEntries.contains('#include "bar.hpp"'), true);
    expect(inc.includeEntries.contains('#include <iostream>'), true);
  });

  test('code_blocks', () {
    final cb = codeBlock('foo public');
    var cbText = cb.toString();
    expect(cbText.contains('// custom <foo public>'), true);
    expect(cbText.contains('// end <foo public>'), true);

    cb.snippets.addAll(['This', 'is', 'a', 'test']);
    cbText = cb.toString();
    expect(['This\n', 'is\n', 'a\n', 'test'].every((t) => cbText.contains(t)),
        true);
  });

  test('mergeIncludes', () {
    expect((includes(['iostream', 'sstream'])
      ..mergeIncludes(includes(['stdexcept', 'iostream']))).includes,
        includes(['iostream', 'sstream', 'stdexcept']).includes);

    expect((includes(['iostream', 'sstream'])..mergeIncludes(null)).includes,
        includes(['sstream', 'iostream']).includes);
  });

  test('template', () {
    final txt = template(['int T']).decl;
    expect(['template', '<', 'int T', '>'].every((t) => txt.contains(t)), true);
  });

  test('pointer usings', () {
    expect(darkSame(usingSptr('foo_bar', 'List<Goo>'),
        'using Foo_bar_sptr_t = std::shared_ptr<List<Goo>>;'), true);
    expect(darkSame(usingUptr('foo_bar', 'List<Goo>'),
        'using Foo_bar_uptr_t = std::unique_ptr<List<Goo>>;'), true);
    expect(darkSame(usingScptr('foo_bar', 'List<Goo>'),
        'using Foo_bar_scptr_t = std::shared_ptr<List<Goo> const>;'), true);
    expect(darkSame(usingUcptr('foo_bar', 'List<Goo>'),
        'using Foo_bar_ucptr_t = std::unique_ptr<List<Goo> const>;'), true);
  });

// end <main>

}
