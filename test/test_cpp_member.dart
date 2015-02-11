library ebisu_cpp.test.test_cpp_member;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

// custom <library test_cpp_member>
// end <library test_cpp_member>
main() {
// custom <main>

  test('basic', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..static = true
      ..mutable = false
      ..init = '{"foo",1.2}, {"bar", 2.3}';
  });

  test('vref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('volatile& foo'), true);
  });

  test('cref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('const& foo'), true);
  });

  test('cvref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('const volatile& foo'), true);
  });

  test('ref fields can not have init', () {
    try {
      final m = member('foo')
        ..brief = 'This is a foo'
        ..refType = cvref
        ..descr = '''
Wee willy winkee went through the town.'''
        ..type = 'std::map<std::string, double>'
        ..mutable = false
        ..init = '{"foo",1.2}, {"bar", 2.3}';

      fail('Excpected an exception since ref fields can not have init');
    } catch (e) {}
  });

  aContainsB(String a, String b) => darkMatter(a).contains(darkMatter(b));

  memberWithAccess(access, [cppAccess = null]) => class_('c_1')
    ..members.add(member('x')
      ..type = 'std::string'
      ..access = access
      ..cppAccess = cppAccess);

  final reader = 'std::string const& x() const';
  final writer = 'void x(std::string &x)';

  [null, public, private, protected].forEach((CppAccess cppAccess) {
    group('access designation with $cppAccess', () {
      final memberName = cppAccess == public ? 'x' : 'x_';
      final selectedAccess = cppAccess == null ? private : cppAccess;
      final accessDecl = '${ev(selectedAccess)}: std::string $memberName';

      test('inaccessible contains no accessors', () {
        final definition = memberWithAccess(ia, cppAccess).definition;
        expect(aContainsB(definition, accessDecl), true);
        expect(aContainsB(definition, reader), false);
        expect(aContainsB(definition, writer), false);
      });
      test('ro gives reader no writer', () {
        final definition = memberWithAccess(ro, cppAccess).definition;

        if(false) {
          print('''
*cppAccess* $cppAccess with *access* *ro* gives:

${indentBlock(definition, '    ')}
''');
        }

        expect(aContainsB(definition, accessDecl), true);
        expect(aContainsB(definition, reader), true);
        expect(aContainsB(definition, writer), false);
      });
      test('rw gives private with reader and writer', () {
        final definition = memberWithAccess(rw, cppAccess).definition;
        expect(aContainsB(definition, accessDecl), true);
        expect(aContainsB(definition, reader), true);
        expect(aContainsB(definition, writer), true);
      });
      test('wo gives private with writer and no reader', () {
        final definition = memberWithAccess(wo, cppAccess).definition;
        expect(aContainsB(definition, accessDecl), true);
        expect(aContainsB(definition, reader), false);
        expect(aContainsB(definition, writer), true);
      });
    });
  });

  test('no access with public works', () {
    final definition = memberWithAccess(null, public).definition;
    expect(aContainsB(definition, 'public: std::string x'), true);
    expect(aContainsB(definition, reader), false);
    expect(aContainsB(definition, writer), false);
  });

// end <main>

}
