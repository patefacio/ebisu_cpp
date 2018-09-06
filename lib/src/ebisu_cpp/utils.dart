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
class ConstExpr extends CppEntity {
  /// The c++ type of the constexpr
  String type;

  /// Any namespace to wrap the constexpr in
  Namespace namespace;

  /// If class scoped the expr should be static
  bool isClassScoped = false;

  /// If true and literal is numeric it is assigned as hex.
  /// The idea is to make C++ more readable when large constants are used.
  bool isHex = false;

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
                  : throw 'ConstExpr does not infer types from ${value_.runtimeType} => $value_';
    }
    _value = value_;
  }

  get valueText => (_value is String)
      ? ((_value as String).length == 1 ? "'$_value'" : doubleQuote(_value))
      : ((_value is num)
          ? ((isHex && _value is int)
              ? '0x${(_value as int).toRadixString(16)}'
              : _value.toString())
          : throw 'ConstExpr value must be String or number');

  get vname => id.capSnake;
  get _static => isClassScoped ? 'static ' : '';
  get unqualDecl => '${_static}constexpr $type $vname { $valueText };';

  get _decl => namespace == null || namespace.length == 0
      ? unqualDecl
      : namespace.wrap(unqualDecl);

  toString() => chomp(brCompact([detailedComment, _decl]));

  // end <class ConstExpr>

  /// The initialization for the constexpr
  Object _value;
}

/// A forward class declaration
class ForwardDecl {
  ForwardDecl(this.type, [this.namespace, this.template]);

  /// Forward declaration documentation
  String doc;

  /// The c++ type being forward declared
  String type;

  /// The namespace to which the class being forward declared belongs
  Namespace namespace;

  /// A template associated with the forward declared class
  Template template;

  // custom <class ForwardDecl>

  toString() => brCompact(
      [doc == null ? null : blockComment(doc), _uncommentedForwardDecl]);

  get _uncommentedForwardDecl => namespace == null || namespace.length == 0
      ? _templatedDecl
      : namespace.names.reversed
          .fold(_templatedDecl, (prev, n) => 'namespace $n { $prev }');

  get _templatedDecl => template != null ? '$template$_rootDecl' : _rootDecl;

  get _rootDecl => 'class $type;';

  // end <class ForwardDecl>

}

/// Create ForwardDecl without new, for more declarative construction
ForwardDecl forwardDecl(String type,
        [Namespace namespace, Template template]) =>
    new ForwardDecl(type, namespace, template);

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

/// Create FriendClassDecl without new, for more declarative construction
FriendClassDecl friendClassDecl(final String decl) => new FriendClassDecl(decl);

/// Represents a c++ namespace which is essentially a list of names
class Namespace {
  /// The individual names in the namespace
  List<String> get names => _names;

  // custom <class Namespace>

  Namespace([Iterable n]) {
    if (n == null) {
      this.names = [];
    } else {
      this.names = new List.from(n.map((n) => n is Id
          ? n.snake
          : n is String
              ? n
              : throw 'Namespace needs Ids or Strings not ${n.runtimeType}'));
    }
  }

  set names(names) => _names = new List.from(names);

  /// Returns [txt] wrapped in namespace declaration(s) corresponding to *this*
  String wrap(String txt) => _helper(names.iterator, txt);

  /// Returns [name] qualified by the namespace
  String qualify(String name) => names.join('::') + '::$name';

  String get using => 'using namespace $this';

  String _helper(Iterator<String> it, String txt) {
    if (it.moveNext()) {
      final name = it.current;
      return '''
namespace $name {
${_helper(it, txt)}
} // namespace $name''';
    } else {
      return txt;
    }
  }

  get length => names.length;
  String toString() => names.join('::');
  String get asPath => names.join('/');
  String get snake => names.join('_');

  // end <class Namespace>

  List<String> _names = [];
}

/// A using namespace statement
class UsingNamespace {
  /// May be constructed with a [Namespace] instance or string representing
  /// the namespace as appears in code:
  ///
  ///     ..usingNamespaces = [
  ///       usingNamespace('std'),
  ///       usingNamespace(namespace(['x','y'])),
  ///       usingNamespace('foo::bar::goo', 'fbg'),
  ///     ]
  Namespace namespace;

  /// Optional alias for the namespace
  String alias;

  // custom <class UsingNamespace>

  UsingNamespace(ns, [this.alias]) : namespace = _makeNamespace(ns);

  get usingNamespaceStatement => alias != null && alias.isNotEmpty
      ? 'namespace $alias = $namespace'
      : namespace.using;

  toString() => usingNamespaceStatement;

  // end <class UsingNamespace>

}

/// Collection of header includes
class Includes {
  /// Set of strings representing the includes
  Set<String> get included => _included;

  // custom <class Includes>

  Includes([Iterable<String> from])
      : _included = from == null ? new Set() : new Set.from(from);

  Iterable<String> get includeEntries {
    final boostHeaders = <String>[];
    final systemHeaders = <String>[];
    final rest = <String>[];
    _included.forEach((String include) {
      if (include.contains('boost/')) {
        boostHeaders.add(_sysInclude(include));
      } else if (isSystemHeader(include)) {
        systemHeaders.add(_sysInclude(include));
      } else {
        rest.add(_include(include));
      }
    });
    //    return concat([systemHeaders..sort(), boostHeaders..sort(), rest..sort()]);
    return concat([rest..sort(), boostHeaders..sort(), systemHeaders..sort()]);
  }

  String get includes => includeEntries.map((h) => h).join('\n');

  mergeIncludes(Includes other) {
    if (other != null) {
      _included.addAll(other._included);
    }
    return this;
  }

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

  /// Name a [Union] from its [Id]
  String nameUnion(Id id);

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
  String nameUnion(Id id) => id.capSnake;
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
  String nameUsingType(Id id) => addSuffixToId('t', id).capSnake;

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
  String nameUnion(Id id) => id.capCamel;
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
  String nameUsingType(Id id) => id.capCamel;

  // end <class GoogleNamer>

}

/// Namer somewhat compatible with Qt coding conventions
class QtNamer implements Namer {
  // custom <class QtNamer>

  const QtNamer();

  String nameApp(Id id) => id.snake;
  String nameScript(Id id) => id.snake;
  String nameLib(Namespace namespace, Id id) {
    if (namespace.names.length > 0 && namespace.names.last == id.snake) {
      return namespace.snake;
    } else {
      return namespace.snake + '_' + id.snake;
    }
  }

  String nameHeader(Id id) => '${id.snake}.hpp';
  String nameImpl(Id id) => '${id.snake}.cc';

  String nameClass(Id id) => id.capCamel;
  String nameUnion(Id id) => id.capCamel;
  String nameMember(Id id) => id.camel;
  String nameMemberVar(Id id, bool isPublic) =>
      isPublic ? id.camel : '${id.camel}_';
  String nameMethod(Id id) => id.camel;
  String nameEnum(Id id) => id.capCamel;
  String nameEnumConst(Id id) => id.capCamel;
  String nameStaticConst(Id id) => id.shout;
  String nameTemplateDeclParm(Id id) => id.shout;
  String nameUsingType(Id id) => id.capCamel;

  // end <class QtNamer>

}

/// A base class of another class.
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
class Base {
  Base(this.className);

  /// The name of the class being derived from
  String className;

  /// Is base class public, protected, or private
  CppAccess cppAccess = public;

  /// How to initiailize the base class in ctor initializer
  String init;

  /// If true inheritance is virtual
  bool isVirtual = false;

  /// If true and streamers are being provided, base is streamed first
  bool isStreamable = false;

  // custom <class Base>

  /// Return this [Base] as it would appear in a declaration
  String get decl => '${ev(cppAccess)} $_virtual$className';
  String get _virtual => isVirtual ? 'virtual ' : '';

  // end <class Base>

}

/// Create Base without new, for more declarative construction
Base base(String className) => new Base(className);

/// Base for class and union to provide abilility to set defaults
class AggregateBase {
  /// If set and member has no [access] set, this is used
  Access defaultMemberAccess;

  /// If set and member has no [cppAccess] set, this is used
  CppAccess defaultCppAccess;

  // custom <class AggregateBase>
  // end <class AggregateBase>

}

// custom <part utils>

Namespace _makeNamespace(ns) => ns is List
    ? new Namespace(ns)
    : ns is String
        ? new Namespace(ns.split('::'))
        : throw 'namespace(ns) requires List<String> or String';

final namespace = _makeNamespace;

UsingNamespace usingNamespace(ns, [String alias]) =>
    new UsingNamespace(ns, alias);

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
  _logger.info('Clang-Formatting text of length ${contents.length}');
  final tmpDir = Directory.systemTemp.createTempSync();
  var tmpFile = new File(path.join(tmpDir.path, fname));
  tmpFile.writeAsStringSync(contents);
  final formatted =
      Process.runSync('clang-format', ['--style=Google', tmpFile.path]).stdout;
  tmpDir.deleteSync(recursive: true);
  return formatted;
}

/// Creates a temporary file with [contents] in the directory of [filePath] (so
/// the appropriate .clang-format file is used) and then formats with
/// clang-format, returning the formatted text. Deletes the temporary file
/// before returning.
String clangFormatFile(String contents, filePath) {
  _logger.info('Clang-Formatting text of length ${contents.length}');
  final folder = path.dirname(filePath);
  final tempFilePath = path.join(folder, '.ebisu_cpp.temp_file.cpp');
  final tempFile = new File(tempFilePath)..writeAsStringSync(contents);
  final formatted = Process.runSync('clang-format', [tempFile.path]).stdout;
  tempFile.deleteSync();
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

var _defaultCppNamer = new EbisuCppNamer();

/// Returns a default cpp namer
get defaultCppNamer => _defaultCppNamer;

/// Allow clients to set the default cpp namer
set defaultCppNamer(Namer namer) => _defaultCppNamer = namer;

get defaultNamer => defaultCppNamer;

/// Given a [datum], as in a value initializing a C++ variable, try to infer the
/// corresponding C++ type
String inferCppType(Object datum) {
  var inferredType = 'int';
  if (datum is double) {
    inferredType = 'double';
  } else if (datum is String) {
    inferredType = 'std::string';
  } else if (datum is bool) {
    inferredType = 'bool';
  } else if (datum is List) {
    List list = datum;
    if (list.isEmpty) throw 'Can not infer type from emtpy list';
    final first = datum.first;
    final guess = inferCppType(first);
    if (list.sublist(1).every((i) => guess == inferCppType(first))) {
      inferredType = 'std::vector< $guess >';
    } else {
      throw 'Can not infer type from list with mixed types: $datum';
    }
  }
  return inferredType;
}

/// Provides consistent mechanism for invoking the namer.
///
/// It is desirable that client code not be tied to a given namer. Yet, in
/// certain circumstances type names need to be provided by client code.
///
/// For example:
///
///     class_("cartesian_point")
///     ..members = [ member("x")..classInit = 0, member("y").classInit = 0 ];
///
///     class_("translation")
///     ..members = [ member("offset")..type = "Cartesian_point" ]
///
/// The problem here is client is required to use knowledge of what the namer is
/// going to do in order to specify the type. Rather than doing this, either use
/// this [name] function which invokes the [defaultNamer] or use the special
/// symbol syntax.
///
/// The format for a nameSpec is: *nameFunctionDesignator*.id
///
/// The *nameFunctionDesignators* are:
///
///   - 'c': Name the id as a class - example 'c.my_class'
///   - 'u': Name the id as the left hand side of a using - exmaple 'u.processor_list'
///   - 'e': Name the id as an enum - exmaple 'e.primary_color'
///   - 'm': Name the id as a member - example 'm.my_member'
///   - 'M': Name the id as a method - example 'M.my_method'
///
String name(String namingSpec, [defaultNamingFunction]) {
  final terms = namingSpec.split('.');
  if (terms.length == 2) {
    final switchPart = terms[0];
    final idPart = terms[1];
    switch (switchPart) {
      case 'c':
        {
          return defaultNamer.nameClass(makeId(idPart));
        }
      case 'm':
        {
          return defaultNamer.nameMember(makeId(idPart));
        }
      case 'M':
        {
          return defaultNamer.nameMethod(makeId(idPart));
        }
      case 'e':
        {
          return defaultNamer.nameEnum(makeId(idPart));
        }
      case 'ec':
        {
          return defaultNamer.nameEnumConst(makeId(idPart));
        }
      case 'sc':
        {
          return defaultNamer.nameStaticConst(makeId(idPart));
        }
      case 'tdp':
        {
          return defaultNamer.nameTemplateDeclParm(makeId(idPart));
        }
      case 'u':
        {
          return defaultNamer.nameUsingType(makeId(idPart));
        }
    }

    throw new ArgumentError('namingSpec error: $namingSpec');
  } else if (terms.length == 1) {
    final id = makeId(namingSpec);
    if (defaultNamingFunction == null) {
      return defaultNamer.nameClass(id);
    } else {
      return defaultNamingFunction(id);
    }
  } else {
    _logger.warning("Naming spec should have at most one colon -> '.'");
  }
}

/// Return name(s) so using a symbol indicates desire to use namer
String nameFromSymbol(Symbol s, [defaultNamingFunction]) =>
    name(MirrorSystem.getName(s));

String _name(s, [defaultNamingFunction]) => s is Symbol
    ? nameFromSymbol(s, defaultNamingFunction)
    : s is String
        ? s
        : throw 'Naming requires a Symbol identifying a NamingSpec or a String convertible to Id';

// end <part utils>
