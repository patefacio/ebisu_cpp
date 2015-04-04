part of ebisu_cpp.ebisu_cpp;

/// Simple variable constexprs.
///
///       print(new ConstExpr('secret', 42));
///       print(new ConstExpr(new Id('voo_doo'), 'foo'));
///       print(new ConstExpr('pi', 3.14));
///
/// prints:
///
///     constexpr int Secret { 42 };
///     constexpr char const* Voo_doo { "foo" };
///     constexpr double Pi { 3.14 };
///
class ConstExpr extends Entity {

  /// The c++ type of the constexpr
  String type;
  /// The initialization for the constexpr
  String get value => _value;
  /// Any namespace to wrap the constexpr in
  Namespace namespace;

  // custom <class ConstExpr>

  /// Create a constant expression from an [id]
  /// [value_] the value of the const expression
  /// [type] the type of the expression
  ConstExpr(Object id, Object value_, [this.type]) : super(id) {
    value = value_;
  }

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  set value(Object value_) {
    if (type == null) {
      type = value_ is String
          ? 'char const*'
          : value_ is int
              ? 'int'
              : value_ is double
                  ? 'double'
                  : throw 'ConstExpr does not infer types from ${value.runtimeType} => $value';
    }
    if (value_ is String) {
      value_ = quote(value_);
    }
    _value = value_.toString();
  }

  set valueText(String txt) => _value = txt;

  get vname => id.capSnake;
  get unqualDecl => 'constexpr $type $vname { $value };';

  toString() => namespace == null || namespace.length == 0
      ? unqualDecl
      : namespace.wrap(unqualDecl);

  // end <class ConstExpr>

  String _value;
}

/// A forward declaration
class ForwardDecl {
  ForwardDecl(this.type, [this.namespace]);

  /// The c++ type being forward declared
  String type;
  /// The namespace to which the class being forward declared belongs
  Namespace namespace;

  // custom <class ForwardDecl>

  toString() => namespace == null || namespace.length == 0
      ? 'class $type;'
      : namespace.names.reversed.fold(
          'class $type;', (prev, n) => 'namespace $n { $prev }');

  // end <class ForwardDecl>

}

/// Create a ForwardDecl sans new, for more declarative construction
ForwardDecl forwardDecl(String type, [Namespace namespace]) =>
    new ForwardDecl(type, namespace);

/// Establishes an interface for generating code
abstract class CodeGenerator {

  // custom <class CodeGenerator>

  void generate();

  // end <class CodeGenerator>

}

/// Friend class declaration
class FriendClassDecl {
  const FriendClassDecl(this.decl);

  /// Declaration text without the *friend* and *class* keywords
  final String decl;

  // custom <class FriendClassDecl>

  String toString() => 'friend class $decl;';

  // end <class FriendClassDecl>

}

/// Create a FriendClassDecl sans new, for more declarative construction
FriendClassDecl friendClassDecl([String decl]) => new FriendClassDecl(decl);

/// Represents a c++ namespace which is essentially a list of names
class Namespace {

  /// The individual names in the namespace
  List<String> names = [];

  // custom <class Namespace>

  Namespace([Iterable<String> n])
      : this.names = n == null ? [] : new List.from(n);

  String wrap(String txt) => _helper(names.iterator, txt);

  String get using => 'using namespace $this';

  String _helper(Iterator<String> it, String txt) {
    if (it.moveNext()) {
      final name = it.current;
      return '''
namespace $name {
${_helper(it, txt)}
} // namespace $name''';
    } else {
      return indentBlock(txt);
    }
  }

  get length => names.length;
  String toString() => names.join('::');
  String get asPath => names.join('/');
  String get snake => names.join('_');

  // end <class Namespace>

}

/// Collection of header includes
class Includes {

  /// Set of strings representing the includes
  Set<String> get included => _included;

  // custom <class Includes>

  Includes([Iterable<String> from])
      : _included = from == null ? new Set() : new Set.from(from);

  Iterable<String> get includeEntries {
    final boostHeaders = [];
    final systemHeaders = [];
    final rest = [];
    _included.forEach((String include) {
      if (include.contains('boost/')) {
        boostHeaders.add(_sysInclude(include));
      } else if (isSystemHeader(include)) {
        systemHeaders.add(_sysInclude(include));
      } else {
        rest.add(_include(include));
      }
    });
    return concat([rest..sort(), boostHeaders..sort(), systemHeaders..sort()]);
  }

  String get includes => includeEntries.map((h) => h).join('\n');

  add(String include) => _included.add(include);
  addAll(Iterable<String> more) => _included.addAll(more);
  contains(String include) => _included.contains(include);

  String toString() => includes;

  static _sysInclude(String include) => '#include <$include>';
  static _include(String include) => '#include "$include"';

  // end <class Includes>

  Set<String> _included;
}

/// Provides support for consistent naming of C++ entities
abstract class Namer {

  // custom <class Namer>

  /// Name an [App] from its [Id]
  String nameApp(Id id);
  /// Name a [Script] from its [Id]
  String nameScript(Id id);
  /// Name a [Class] from its namespace and [Id].
  ///
  /// Namespaces are encouraged/required and the namespace name should be
  /// incorporated into the name of the library. For the default namer,
  /// [EbisuCppNamer] if the last entry in the namespace matches the lib id then
  /// that finishes the name. Otherwise the lib name is the namespace name
  /// concatenated with the lib id.
  ///
  /// nameLib(new Namespace(['foo', 'bar']), idFromString('bar')) => 'foo_bar'
  /// nameLib(new Namespace(['foo', 'bar']), idFromString('goo')) => 'foo_bar_goo'
  ///
  String nameLib(Namespace namespace, Id id);
  /// Name a [Class] from its [Id]
  String nameClass(Id id);
  /// Name of member in a generic sense
  /// Essentially this is used to determine case of the member in general
  /// but the actual declared variable may use a different convention based
  /// on [CppAccess]
  String nameMember(Id id);
  /// Name a [Member] from its [Id] and whether it is public.  If the name is
  /// *public* the default namer, [EbisuCppNamer] uses just the snake case of
  /// the id. Otherwise it adds a '_' suffix
  String nameMemberVar(Id id, bool isPublic);
  /// Name a [Method] from its [Id]
  String nameMethod(Id id);
  /// Name an [Enum] from its [Id]
  String nameEnum(Id id);
  /// Name a static const variable from its [Id]
  String nameStaticConst(Id id);
  /// Name a template parameter that is non-type template parameter
  String nameTemplateDeclParm(Id id) => id.shout;
  /// Name an [Enum] value from its [Id]
  String nameEnumConst(Id id);
  /// Name a [Header] from its [Id]
  String nameHeader(Id id);
  /// Name an [Impl] from its [Id]
  String nameImpl(Id id);
  /// Name using type identifier introduced by using statement
  String nameUsingType(Id id);

  // end <class Namer>

}

/// Default namer establishing reasonable conventions, that are fairly
/// *snake* case heavy like the STL.
///
class EbisuCppNamer implements Namer {

  // custom <class EbisuCppNamer>

  const EbisuCppNamer();

  String nameApp(Id id) => id.snake;
  String nameScript(Id id) => id.snake;
  String nameLib(Namespace namespace, Id id) {
    if (namespace.names.length > 0 && namespace.names.last == id.snake) {
      return namespace.snake;
    } else {
      return namespace.snake + '_' + id.snake;
    }
  }
  String nameClass(Id id) => id.capSnake;
  String nameMember(Id id) => id.snake;
  String nameMemberVar(Id id, bool isPublic) =>
      isPublic ? id.snake : '${id.snake}_';
  String nameMethod(Id id) => id.snake;
  String nameEnum(Id id) => id.capSnake;
  String nameEnumConst(Id id) => '${id.capSnake}_e';
  String nameStaticConst(Id id) => id.shout;
  String nameTemplateDeclParm(Id id) => id.shout;
  String nameHeader(Id id) => '${id.snake}.hpp';
  String nameImpl(Id id) => '${id.snake}.cpp';
  String nameUsingType(Id id) => addSuffix('t', id);

  // end <class EbisuCppNamer>

}

/// Namer based on google coding conventions
class GoogleNamer implements Namer {

  // custom <class GoogleNamer>

  const GoogleNamer();

  String nameApp(Id id) => id.snake;
  String nameScript(Id id) => id.snake;
  String nameLib(Namespace namespace, Id id) {
    if (namespace.names.length > 0 && namespace.names.last == id.snake) {
      return namespace.snake;
    } else {
      return namespace.snake + '_' + id.snake;
    }
  }
  String nameClass(Id id) => id.capCamel;
  String nameMember(Id id) => id.snake;
  String nameMemberVar(Id id, bool isPublic) =>
      isPublic ? id.snake : '${id.snake}_';
  String nameMethod(Id id) => id.capCamel;
  String nameEnum(Id id) => id.capCamel;
  String nameEnumConst(Id id) => id.shout;
  String nameStaticConst(Id id) => 'k${id.capCamel}';
  String nameTemplateDeclParm(Id id) => id.shout;
  String nameHeader(Id id) => '${id.snake}.hpp';
  String nameImpl(Id id) => '${id.snake}.cc';
  String nameUsingType(Id id) => addSuffix('t', id).capCamel;

  // end <class GoogleNamer>

}

/// A base class of another class.
///
///
/// The style of inheritance is determined by [virtual] and [access]. Examples:
///
/// Default is *not* virtual and [public] inheritance:
///
///     class_('derived')
///     ..bases = [
///       base('Base')
///     ];
///
/// gives:
///
///     class Derived : public Base {};
///
/// With overrides:
///
///     class_('derived')
///     ..bases = [
///       base('Base')
///       ..isVirtual = true
///       ..access = protected
///     ];
///
/// Gives:
///
///     class Derived :
///       protected virtual Base
///     {
///     };
///
class Base {
  Base(this.className);

  /// The name of the class being derived from
  String className;
  /// Is base class public, protected, or private
  CppAccess access = public;
  /// How to initiailize the base class in ctor initializer
  String init;
  /// If true inheritance is virtual
  bool isVirtual = false;
  /// If true and streamers are being provided, base is streamed first
  bool isStreamable = false;

  // custom <class Base>

  /// Return this [Base] as it would appear in a declaration
  String get decl => '${ev(access)} $_virtual$className';
  String get _virtual => isVirtual ? 'virtual ' : '';

  // end <class Base>

}

/// Create a Base sans new, for more declarative construction
Base base([String className]) => new Base(className);

// custom <part utils>

Namespace namespace(List<String> ns) => new Namespace()..names = ns;

Includes includes([List<String> includes]) => new Includes(includes);

ConstExpr constExpr(Object id, Object value,
    [String typeStr, Namespace namespace]) {
  id = id is Id
      ? id
      : id is String
          ? idFromString(id)
          : throw 'ConstExpr must be created with an id or string - not $id';

  return new ConstExpr(id, value, typeStr);
}

final _commonTypes = const {
  'std::string': 'string',
  'std::vector': 'vector',
  'std::set': 'set',
  'std::map': 'map',
  'std::pair': 'utility',
  'std::stringstream': 'sstream',
};

/// Given an iterable of [types] for any that represent common
/// system (STL) includes, add appropriate include to [includes].
/// [Includes] models the actual included files as a set so there
/// will be no duplications
addIncludesForCommonTypes(Iterable<String> types, Includes includes) {
  types.forEach((String type) {
    if (_commonTypes.containsKey(type)) {
      includes.add(_commonTypes[type]);
    }
  });
}

/// Returns [contents] formatted by *clang* formmatter.
/// [fname] is an optional filename where contents will be written by
/// clang
String clangFormat(String contents, [String fname = 'ebisu_txt.cpp']) {
  final tmpDir = Directory.systemTemp.createTempSync();
  var tmpFile = new File(path.join(tmpDir.path, fname));
  tmpFile.writeAsStringSync(contents);
  final formatted =
      Process.runSync('clang-format', ['--style=Google', tmpFile.path]).stdout;
  tmpDir.deleteSync(recursive: true);
  return formatted;
}

/// Assuming *v* is an enum value, returns that value as capitalized string
///
/// if v is CppAccess.private => Private
String evCap(v) => Id.capitalize(v.toString().split('.')[1]);

/// Assuming *v* is an enum value, returns that value
///
/// if v is CppAccess.private => private
String ev(v) => v.toString().split('.')[1];

const defaultNamer = const EbisuCppNamer();

// end <part utils>
