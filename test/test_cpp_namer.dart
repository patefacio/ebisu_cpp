library ebisu_cpp.test_cpp_namer;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_namer');

// custom <library test_cpp_namer>
// end <library test_cpp_namer>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
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

  test('naming specs', () {
    //defaultCppNamer = new QtNamer();
    expect(name('c.this_is_a_class'), 'This_is_a_class');
    expect(name('m.this_is_a_member'), 'this_is_a_member');
    expect(name('M.this_is_a_method'), 'this_is_a_method');
    expect(name('e.this_is_an_enum'), 'This_is_an_enum');
    expect(name('ec.this_is_an_enum_const'), 'This_is_an_enum_const_e');
    expect(name('sc.this_is_a_static_const'), 'THIS_IS_A_STATIC_CONST');
    expect(name('tdp.this_is_a_template_decl_parm'),
        'THIS_IS_A_TEMPLATE_DECL_PARM');
    expect(name('u.this_is_a_using_type'), 'This_is_a_using_type_t');

    expect(nameFromSymbol(#c.this_is_a_class), 'This_is_a_class');
    expect(nameFromSymbol(#m.this_is_a_member), 'this_is_a_member');
    expect(nameFromSymbol(#M.this_is_a_method), 'this_is_a_method');
    expect(nameFromSymbol(#e.this_is_an_enum), 'This_is_an_enum');
    expect(
        nameFromSymbol(#ec.this_is_an_enum_const), 'This_is_an_enum_const_e');
    expect(
        nameFromSymbol(#sc.this_is_a_static_const), 'THIS_IS_A_STATIC_CONST');
    expect(nameFromSymbol(#tdp.this_is_a_template_decl_parm),
        'THIS_IS_A_TEMPLATE_DECL_PARM');
    expect(nameFromSymbol(#u.this_is_a_using_type), 'This_is_a_using_type_t');

    // Without specifier depends on defaults, which if not set names class
    expect(nameFromSymbol(#this_is_a_class), 'This_is_a_class');
  });

// end <main>
}
