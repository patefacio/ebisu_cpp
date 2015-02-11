library ebisu_cpp.test.test_cpp_class;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_class>
// end <library test_cpp_class>
main() {
// custom <main>

  group('basic', () {
    group('default methods', () {
      [
        [public, 'public:'],
        [private, 'private:'],
        [protected, 'protected:']
      ].forEach((List pair) {
        final access = pair[0];
        final tag = pair[1];

        test('defaultCtor $tag', () {
          var c = class_('c_1')
            ..withDefaultCtor((ctor) => ctor.cppAccess = access);

          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  C_1() {
  }
};
'''));
        });

        test('copyCtor $tag', () {
          final c = class_('c_1')
            ..withCopyCtor((ctor) => ctor.cppAccess = access);

          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  C_1(C_1 const& other) {
  }
};
'''));
        });

        test('dtor $tag', () {
          final c = class_('c_1')..withDtor((dtor) => dtor.cppAccess = access);

          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  ~C_1() {
  }
};
'''));
        });

        test('opEqual $tag', () {
          final c = class_('c_1')
            ..members.add(member('x')..type = 'std::string')
            ..members.add(member('y')..type = 'std::string')
            ..withOpEqual((op) => op.cppAccess = access);

          // if access is not private there should be two access sections, the
          // first is *access*, the second private. Otherwise it's all private
          final tricky = access == private ? '' : 'private:';
          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  bool operator==(C_1 const& rhs) const {
    return this == &rhs ||
      (x_ == rhs.x_ &&
      y_ == rhs.y_);
  }

  bool operator!=(C_1 const& rhs) const {
    return !(*this == rhs);
  }

$tricky
  std::string x_ {};
  std::string y_ {};

};
'''));
        });

        test('ctor defaultValue', () {
          final cls = class_('point')
            ..members = [member('x')..init = 0, member('y')..init = 0]
            ..memberCtors = [
              memberCtor([
                memberCtorParm('x')..defaultValue = '42',
                memberCtorParm('y')..defaultValue = '42'
              ])
            ];

          expect(darkMatter(cls.definition)
              .contains(darkMatter('''
(int x = 42, int y = 42)
''')), true);

        });

        test('ctor parmDecl and init', () {
          final cls = class_('point')
            ..members = [member('x')..init = 0, member('y')..init = 0]
            ..memberCtors = [
              memberCtor([
                memberCtorParm('x')..parmDecl = 'T t = 25'..init = '2*t',
                memberCtorParm('y')..defaultValue = '42'
              ])
            ];

          expect(darkMatter(cls.definition)
              .contains(darkMatter('''
(T t = 25, int y = 42) : x_{2*t}, y_{y}
''')), true);

        });


        test('opLess $tag', () {
          final c = class_('c_1')
            ..members.add(member('x')..type = 'std::string')
            ..members.add(member('y')..type = 'std::string')
            ..withOpLess((op) => op.cppAccess = access);

          // if access is not private there should be two access sections, the
          // first is *access*, the second private. Otherwise it's all private
          final tricky = access == private ? '' : 'private:';
          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  bool operator<(C_1 const& rhs) const {
    return x_ != rhs.x_? x_ < rhs.x_ : (
      y_ != rhs.y_? y_ < rhs.y_ : (
      false));
  }

$tricky
  std::string x_ {};
  std::string y_ {};
};
'''));
        });

        test('opOut $tag', () {
          final c = class_('c_1')
            ..members.add(member('x')..type = 'std::string')
            ..members.add(member('y')..type = 'std::string')
            ..withOpOut((op) => op.cppAccess = access);

          // if access is not private there should be two access sections, the
          // first is *access*, the second private. Otherwise it's all private
          final tricky = access == private ? '' : 'private:';
          expect(darkMatter(c.definition), darkMatter('''
class C_1
{
$tag
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           C_1 const& item) {
    using fcs::utils::streamers::operator<<;
    fcs::utils::Block_indenter indenter;
    char const* indent(indenter.current_indentation_text());
    out << '\\n' << indent << "C_1(" << &item << ") {";
    out << '\\n' << indent << "  x:" << item.x_;
    out << '\\n' << indent << "  y:" << item.y_;
    out << '\\n' << indent << "}\\n";
    return out;
  }

$tricky
  std::string x_ {};
  std::string y_ {};

};
'''));
        });
      });
    });

    final l = lib('lib1')
      ..namespace = namespace(['foo', 'bar'])
      ..headers = [
        header('guts')
          ..includes = ['cmath', 'boost/filesystem.hpp']
          ..classes = [
            class_('c_1')
              ..streamable = true
              ..bases = [
                base('Foo'),
                base('Bar')..access = protected,
                base('Goo')..virtual = true
              ]
              ..enums = [
                enum_('letters')
                  ..streamable = true
                  ..hasFromCStr = false
                  ..values = ['a', 'b', 'c'],
              ]
              ..enumsForward = [
                enum_('abcs')
                  ..streamable = true
                  ..values = ['a', 'b', 'c'],
              ]
              ..members = [
                member('foo_bar')
                  ..type = 'std::string'
                  ..init = '"Foo"',
                member('foo_bor')..type = 'int',
                member('foo_bur')..type = 'std::string',
                member('letters')
                  ..type = 'Letters'
                  ..init = 'C_1::B_e',
              ]
              ..getCodeBlock(clsProtected).snippets
                  .addAll(['//Sample code block stuff...'])
              ..opEqual
              ..opLess
              ..customBlocks = [clsPublic, clsPrivate]
              ..forwardPtrs = [sptr, uptr, scptr, ucptr]
          ]
      ];

    l.generate();
  });
// end <main>

}
