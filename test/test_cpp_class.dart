library ebisu_cpp.test_cpp_class;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_class');

// custom <library test_cpp_class>
// end <library test_cpp_class>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
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

          expect(darkMatter(cls.definition).contains(darkMatter('''
(int x = 42, int y = 42)
''')), true);
        });

        test('ctor parmDecl and init', () {
          final cls = class_('point')
            ..members = [member('x')..init = 0, member('y')..init = 0]
            ..memberCtors = [
              memberCtor([
                memberCtorParm('x')
                  ..parmDecl = 'T t = 25'
                  ..init = '2*t',
                memberCtorParm('y')..defaultValue = '42'
              ])
            ];

          expect(darkMatter(cls.definition).contains(darkMatter('''
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
            ..members.add(member('zing')
              ..type = 'std::string'
              ..withCustomStreamable((cb) {
                cb.tag = null;
                cb.snippets
                    .add([r"""out << '\n' << indent << "  <zinger>";"""]);
              }))
            ..withOpOut((op) => op
              ..cppAccess = access
              ..usesIndent = true);

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
    ebisu::utils::Block_indenter indenter;
    char const* indent(indenter.current_indentation_text());
    out << indent << "C_1(" << &item << ") {";
    out << '\\n' << indent << "  x:" << item.x_;
    out << '\\n' << indent << "  y:" << item.y_;
    out << '\\n' << indent << "  <zinger>";
    out << '\\n' << indent << "}\\n";
    return out;
  }

$tricky
  std::string x_ {};
  std::string y_ {};
  std::string zing_ {};
};
'''));
        });
      });
    });

    final i = installation('i')
      ..libs = [
        lib('lib1')
          ..namespace = namespace(['foo', 'bar'])
          ..headers = [
            header('guts')
              ..includes = ['cmath', 'boost/filesystem.hpp']
              ..classes = [
                class_('c_1')
                  ..isStreamable = true
                  ..bases = [
                    base('Foo'),
                    base('Bar')..access = protected,
                    base('Goo')..isVirtual = true
                  ]
                  ..enums = [
                    enum_('letters')
                      ..isStreamable = true
                      ..hasFromCStr = false
                      ..values = ['a', 'b', 'c'],
                  ]
                  ..enumsForward = [
                    enum_('abcs')
                      ..isStreamable = true
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
          ]
      ];

    i.generate();
  });

  group('uses type query', () {
    final c1 = class_('c_1')..members = [member('a')..type = 'int'];
    test('usesType works', () {
      expect(c1.usesType('std::string'), false);
      expect(c1.usesType('int'), true);
    });
  });

  group('immutable', () {
    final c1 = class_('c_1')
      ..isImmutable = true
      ..members = [member('a')..type = 'int'];
    final definition = darkMatter(c1.definition);
    test('makes member const',
        () => expect(definition.contains(darkMatter('int const a_')), true));
    test('provides member init all members', () => expect(
        definition.contains(darkMatter('C_1(int a) : a_ { a } {}')), true));
  });

  group('access code blocks', () {
    /// Accessing code blocks does not autocreate
    [
      clsPublic,
      clsPrivate,
      clsProtected,
      clsPreDecl,
      clsPostDecl
    ].forEach((ClassCodeBlock ccb) {
      test('getting $ccb', () {
        final c1 = class_('c_1');
        // Initially there should be no code blocks
        expect(c1.codeBlocks, {});
        final codeBlock = c1.getCodeBlock(ccb);
        expect(c1.codeBlocks, {ccb: codeBlock});
        // Getting the codeblock multiple times should return the same object
        expect(c1.getCodeBlock(ccb), codeBlock);
      });

      test('with custom block', () {
        final fooMethod = 'void foo() { std::cout << "Foo"; }';
        final c1 = class_('c_1');
        c1.withCustomBlock(ccb, (CodeBlock cb) {
          cb.snippets.add(fooMethod);
        });
        expect(darkMatter(c1.definition).contains(darkMatter(fooMethod)), true);
      });
    });
  });

  group('templatized class', () {
    test('from string', () {
      final c1 = class_('c_1')..template = ['typename T'];
      expect(darkMatter(c1.definition), darkMatter('''
template< typename T >
class C_1
{};
'''));
    });

    test('from multiple strings', () {
      final c1 = class_('c_1')
        ..template = ['typename T', 'typename FUNCTOR = Void_func_t'];
      expect(darkMatter(c1.definition), darkMatter('''
template< typename T, typename FUNCTOR = Void_func_t >
class C_1
{};
'''));
    });
  });

  group('add full member constructor', () {
    test('one member', () {
      final c1 = class_('c_1')
        ..members = [member('a')..init = 1]
        ..addFullMemberCtor();
      expect(darkMatter(c1.definition), darkMatter('''
class C_1
{
public:
  C_1(int a) : a_{ a } {}

private:
  int a_ { 1 };
};
'''));
    });

    test('two member', () {
      final c1 = class_('c_1')
        ..members = [member('a')..init = 1, member('b')..init = 2]
        ..addFullMemberCtor();
      expect(darkMatter(c1.definition), darkMatter('''
class C_1
{
public:
  C_1(int a, int b) : a_{ a }, b_{ b } { }

private:
  int a_ { 1 };
  int b_ { 2 };
};
'''));
    });
  });

  group('c++ singleton', () {
    test('access to single instance added', () {
      final c1 = class_('c_1')..isSingleton = true;
      expect(darkMatter(c1.definition), darkMatter('''
class C_1
{
public:
  static C_1 & instance() {
    static C_1 instance_s;
    return instance_s;
  }

private:
  C_1() {}
};
'''));
    });
  });

  group('auto-create methods', () {

    /// Here is an example showing how the defaultCtor is auto-initialized and
    /// when initialized provides access to mutation of access
    test('defaultCtor auto create', () {
      final c1 = class_('c_1');
      expect(c1.hasDefaultCtor, false);
      c1.defaultCtor;
      expect(c1.hasDefaultCtor, true);
      c1.defaultCtor.cppAccess = private;
      expect(c1.defaultCtor.cppAccess, private);
    });

    /// The following does similar tests on all such methods
    final hasMethods = {
      'defaultCtor': (cls) => cls.hasDefaultCtor,
      'copyCtor': (cls) => cls.hasCopyCtor,
      'moveCtor': (cls) => cls.hasMoveCtor,
      'assignCopy': (cls) => cls.hasAssignCopy,
      'assignMove': (cls) => cls.hasAssignMove,
      'dtor': (cls) => cls.hasDtor,
      'opEqual': (cls) => cls.hasOpEqual,
      'opLess': (cls) => cls.hasOpLess,
      'opOut': (cls) => cls.hasOpOut,
    };

    final withMethods = {
      'defaultCtor': (cls) => cls.withDefaultCtor,
      'copyCtor': (cls) => cls.withCopyCtor,
      'moveCtor': (cls) => cls.withMoveCtor,
      'assignCopy': (cls) => cls.withAssignCopy,
      'assignMove': (cls) => cls.withAssignMove,
      'dtor': (cls) => cls.withDtor,
      'opEqual': (cls) => cls.withOpEqual,
      'opLess': (cls) => cls.withOpLess,
      'opOut': (cls) => cls.withOpOut,
    };

    final autoInits = {
      'defaultCtor': (cls) => cls.defaultCtor,
      'copyCtor': (cls) => cls.copyCtor,
      'moveCtor': (cls) => cls.moveCtor,
      'assignCopy': (cls) => cls.assignCopy,
      'assignMove': (cls) => cls.assignMove,
      'dtor': (cls) => cls.dtor,
      'opEqual': (cls) => cls.opEqual,
      'opLess': (cls) => cls.opLess,
      'opOut': (cls) => cls.opOut,
    };

    final newEmpties = {
      'defaultCtor': (cls) => cls.defaultCtor = defaultCtor(),
      'copyCtor': (cls) => cls.copyCtor = copyCtor(),
      'moveCtor': (cls) => cls.moveCtor = moveCtor(),
      'assignCopy': (cls) => cls.assignCopy = assignCopy(),
      'assignMove': (cls) => cls.assignMove = assignMove(),
      'dtor': (cls) => cls.dtor = dtor(),
      'opEqual': (cls) => cls.opEqual = opEqual(),
      'opLess': (cls) => cls.opLess = opLess(),
      'opOut': (cls) => cls.opOut = opOut(),
    };

    [
      'defaultCtor',
      'copyCtor',
      'moveCtor',
      'assignCopy',
      'assignMove',
      'dtor',
      'opEqual',
      'opLess',
      'opOut'
    ].forEach((String method) {
      test('by default $method does not exist', () {
        final c1 = class_('c_1');
        expect(hasMethods[method](c1), false);
      });
      test('call to accessor $method creates method', () {
        final c1 = class_('c_1');
        autoInits[method](c1);
        expect(hasMethods[method](c1), true);
      });
      test('can be set manually', () {
        final c1 = class_('c_1');
        expect(hasMethods[method](c1), false);
        newEmpties[method](c1);
        expect(hasMethods[method](c1), true);
      });
      [public, protected, private].forEach((CppAccess access) {
        test('call to with$method allows set to $access', () {
          final c1 = class_('c_1');
          withMethods[method](c1)((ClassMethod m) => m.cppAccess = access);
          expect(hasMethods[method](c1), true);
          expect(autoInits[method](c1).cppAccess, access);
        });
      });
    });
  });

  group('nested classes', () {
    final expectations = {
      public: '''
class C_1
{
public:
  class Inner_c_1
  {
  private:
    int m_1_ { 1 };
    int m_2_ { 2 };
  };

private:
  int m_1_ { 1 };
  int m_2_ { 2 };
};
''',
      protected: '''
class C_1
{
protected:
  class Inner_c_1
  {
  private:
    int m_1_ { 1 };
    int m_2_ { 2 };
  };

private:
  int m_1_ { 1 };
  int m_2_ { 2 };
};
''',
      private: '''
class C_1
{
private:
  class Inner_c_1
  {
  private:
    int m_1_ { 1 };
    int m_2_ { 2 };
  };

  int m_1_ { 1 };
  int m_2_ { 2 };
};
'''
    };

    int _i = 0;
    i() => _i++;
    expectations.forEach((cppAccess, expected) {
      final c1 = class_('c_1')
        ..members = [member('m_1')..init = 1, member('m_2')..init = 2]
        ..nestedClasses = [
          class_('inner_c_1')
            ..cppAccess = cppAccess
            ..members = [member('m_1')..init = 1, member('m_2')..init = 2]
        ];
      test('$cppAccess nesting',
          () => expect(darkMatter(c1.definition), darkMatter(expected)));
    });
  });

  test('final class', () {
    expect(
        darkSame((class_('a')..isFinal = true).definition, 'class A final {};'),
        true);
  });

  test('class constexprs are static', () {
    expect(darkSame((class_('a')..constExprs = [constExpr('f', 42)]).definition,
        'class A { public: static constexpr int F { 42 }; };'), true);
  });

  test('const expr asHex', () {
    expect(
        darkSame(constExpr('f', 42)..isHex = true, 'constexpr int F { 0x2a };'),
        true);
  });

  test('class with members with custom code', () {
    expect(darkSame((class_('a')
      ..members = [
        member('goo')
          ..init = 42
          ..customBlock.snippets.add('''
int extraCounter { 43 };
''')
      ]).definition, '''
class A
{

public:
  int extraCounter { 43 };

private:
  int goo_ { 42 };

};
'''), true);

    expect(darkSame((class_('a')
      ..members = [
        member('x')..withCustomBlock((member, cb) => cb.tag = 'gimme')
      ]).definition, '''
class A
{

public:
  // custom <gimme>
  // end <gimme>

private:
  null x_ {};

};
'''), true);
  });

  test('streamable class with standard getter streams variable', () {
    expect(darkSame((class_('a')
      ..isStreamable = true
      ..members = [
        member('x')
          ..access = ro
          ..type = 'int'
          ..getterReturnModifier =
          ((member, oldValue) => 'endian_convert($oldValue)')
      ]).definition, r'''
class A {

public:
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           A const& item) {
    out << "A(" << &item << ") {";
    out << "\n  x:" << item.x();
    out << "\n}\n";
    return out;
  }

  //! getter for x_ (access is Ro)
  int x() const {
    return endian_convert(x_);
  }

private:
  int x_ {};

};
'''), true);
  });

  test('streamable class with custom getter streams function call', () {
    expect(darkSame((class_('a')
      ..isStreamable = true
      ..members = [
        member('x')
          ..access = ro
          ..type = 'int'
      ]).definition, r'''
class A {

public:
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           A const& item) {
    out << "A(" << &item << ") {";
    out << "\n  x:" << item.x_;
    out << "\n}\n";
    return out;
  }

  //! getter for x_ (access is Ro)
  int x() const {
    return x_;
  }

private:
  int x_ {};

};
'''), true);
  });

  test('immutable class', () {
    expect(darkSame((class_('point')
      ..isImmutable = true
      ..members = [member('x')..init = 0, member('y')..init = 0,]).definition,
        '''
class Point {
 public:
  Point(int x, int y) : x_{x}, y_{y} {}

  //! getter for x_ (access is Ro)
  int x() const { return x_; }

  //! getter for y_ (access is Ro)
  int y() const { return y_; }

 private:
  int const x_;
  int const y_;
};
'''), true);
  });

  test('forward declarations class', () {
    expect(darkSame((class_('transformer')
      ..forwardDecls =
      [forwardDecl('text_stream', namespace(['decode', 'streamers']))]
      ..memberCtors = [memberCtor(['out'])]
      ..members = [
        member('out')
          ..refType = ref
          ..type = 'decode::streamers::text_stream',
      ]).definition, '''
namespace decode {
  namespace streamers {
    class text_stream;
  }
}

class Transformer {
 public:

  Transformer(decode::streamers::text_stream& out) : out_{out} {}

 private:
  decode::streamers::text_stream& out_;
};
'''), true);
  });

// end <main>

}
