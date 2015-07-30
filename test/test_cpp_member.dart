library ebisu_cpp.test_cpp_member;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_member');

// custom <library test_cpp_member>
// end <library test_cpp_member>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('basic', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..isStatic = true
      ..isMutable = false
      ..init = '{"foo",1.2}, {"bar", 2.3}';
  });

  test('type inference: int',
      () => expect((member('foo')..init = 3).type, 'int'));

  test('type inference: double',
      () => expect((member('foo')..init = 3.14).type, 'double'));

  test('type inference: string',
      () => expect((member('foo')..init = 'goo').type, 'std::string'));

  test(
      'type inference: List',
      () =>
          expect((member('foo')..init = [1, 2, 3]).type, 'std::vector< int >'));

  test(
      'type inference: List of lists',
      () => expect(
          (member('foo')
            ..init = [
              [1, 2, 3]
            ]).type,
          'std::vector< std::vector< int > >'));

  test('member turns non-snake id to id', () {
    final m = member('thisIsATest');
    expect(m.id, new Id('this_is_a_test'));
  });

  test('vref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..isMutable = false;
    expect(m.toString().contains('volatile& foo'), true);
  });

  test('cref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..isMutable = false;
    expect(m.toString().contains('const& foo'), true);
  });

  test('cvref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..isMutable = false;
    expect(m.toString().contains('const volatile& foo'), true);
  });

  test('ref fields can not have init', () {
    try {
      member('foo')
        ..brief = 'This is a foo'
        ..refType = cvref
        ..descr = '''
Wee willy winkee went through the town.'''
        ..type = 'std::map<std::string, double>'
        ..isMutable = false
        ..init = '{"foo",1.2}, {"bar", 2.3}';

      fail('Excpected an exception since ref fields can not have init');
    } catch (e) {}
  });

  aContainsB(String a, String b) => darkMatter(a).contains(darkMatter(b));

  memberWithAccess(access, [cppAccess = null]) =>
      class_('c_1')..members.add(member('x')
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

        _logger.info('''
*cppAccess* $cppAccess with *access* *ro* gives:

${indentBlock(definition, '    ')}
''');

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

  test('class defaultMemberAccess', () {
    /// Note the ..owner = null, this triggers the ownership walk. Normally
    /// triggered at top level installation.generate. But for testing this needs
    /// to be triggered.
    final c1 = class_('c_1')
      ..defaultMemberAccess = ro
      ..members.add(member('xy')..type = 'std::string')
      ..owner = null;
    expect(c1.members.first.access, ro);
  });

  test('member getReturnModifier', () {
    expect(
        darkSame(
            (member('message_length')
              ..type = 'int32_t'
              ..access = ro
              ..getterReturnModifier = ((member, oldValue) =>
                  'endian_convert($oldValue)')).getter,
            '''
//! getter for message_length_ (access is Ro)
int32_t message_length() const {
  return endian_convert(message_length_);
}
'''),
        true);

    expect(
        darkSame(
            (class_('class_with_special_accessor')
              ..members = [
                member('only_one')
                  ..type = 'some_struct_t'
                  ..access = ia
                  ..withCustomBlock((Member m, CodeBlock cb) {
                    cb.snippets.add('''
/// just to illustrate custom member function
${m.type} const& get_${m.type}() {
  _logger.info("badabing accessed my struct");
  return ${m.vname};
}
''');
                  }),
              ]).definition,
            '''
class Class_with_special_accessor
{

public:
  /// just to illustrate custom member function
  some_struct_t const& get_some_struct_t() {
    _logger.info("badabing accessed my struct");
    return only_one_;
  }

private:
  some_struct_t only_one_ {};

};
'''),
        true);
  });

  test('setter by ref via update', () {
    final cls = class_('c')
      ..members = [
        member('x')
          ..type = 'X'
          ..isByRef = true
          ..access = rw
      ];

    expect(darkMatter(cls.definition), darkMatter('''
class C {
 public:
  //! getter for x_ (access is Rw)
  X const& x() const { return x_; }

  //! setter for x_ (access is Access.rw)
  void x(X& x) { x_ = x; }
  //! updater for x_ (access is Access.rw)
  X& x() { return x_; }

 private:
  X x_{};
};
'''));
  });

// end <main>
}
