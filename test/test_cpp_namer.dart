library ebisu_cpp.test_cpp_namer;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_namer');

// custom <library test_cpp_namer>
// end <library test_cpp_namer>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('default namer', () {
    final namer = const EbisuCppNamer();
    test('nameApp', () {
      expect(namer.nameApp(idFromString('foo_bar')), 'foo_bar');
      expect(namer.nameClass(idFromString('foo_bar')), 'Foo_bar');
      expect(
          namer.nameLib(new Namespace(['a', 'b_c']), idFromString('foo_bar')),
          'a_b_c_foo_bar');
      expect(namer.nameLib(new Namespace(['a', 'b_c']), idFromString('b_c')),
          'a_b_c');
      expect(namer.nameMember(idFromString('foo_bar')), 'foo_bar');
      expect(namer.nameMemberVar(idFromString('foo_bar'), false), 'foo_bar_');
      expect(namer.nameMemberVar(idFromString('foo_bar'), true), 'foo_bar');
      expect(namer.nameMethod(idFromString('foo_bar')), 'foo_bar');
      expect(namer.nameEnum(idFromString('foo_bar')), 'Foo_bar');
      expect(namer.nameEnumConst(idFromString('foo_bar')), 'Foo_bar_e');
      expect(namer.nameStaticConst(idFromString('foo_bar')), 'FOO_BAR');
      expect(namer.nameHeader(idFromString('foo_bar')), 'foo_bar.hpp');
      expect(namer.nameImpl(idFromString('foo_bar')), 'foo_bar.cpp');
    });
  });

  group('google namer', () {
    final namer = const GoogleNamer();
    test('nameApp', () {
      expect(namer.nameApp(idFromString('foo_bar')), 'foo_bar');
      expect(namer.nameClass(idFromString('foo_bar')), 'FooBar');
      expect(
          namer.nameLib(new Namespace(['a', 'b_c']), idFromString('foo_bar')),
          'a_b_c_foo_bar');
      expect(namer.nameLib(new Namespace(['a', 'b_c']), idFromString('b_c')),
          'a_b_c');
      expect(namer.nameMember(idFromString('foo_bar')), 'foo_bar');
      expect(namer.nameMemberVar(idFromString('foo_bar'), false), 'foo_bar_');
      expect(namer.nameMemberVar(idFromString('foo_bar'), true), 'foo_bar');
      expect(namer.nameMethod(idFromString('foo_bar')), 'FooBar');
      expect(namer.nameEnum(idFromString('foo_bar')), 'FooBar');
      expect(namer.nameEnumConst(idFromString('foo_bar')), 'FOO_BAR');
      expect(namer.nameStaticConst(idFromString('foo_bar')), 'kFooBar');
      expect(namer.nameHeader(idFromString('foo_bar')), 'foo_bar.hpp');
      expect(namer.nameImpl(idFromString('foo_bar')), 'foo_bar.cc');
    });
  });

// end <main>

}
