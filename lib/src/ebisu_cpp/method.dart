part of ebisu_cpp.ebisu_cpp;

/// A parameter declaration.
///
/// Method signatures consist of a [List<ParmDecl>] and a return type.
/// [ParmDecl]s may be constructed from declaration text:
///
///       var pd = new ParmDecl.fromDecl('std::vector< std::vector < double > > matrix');
///       print('''
///     id    => ${pd.id} (${pd.id.runtimeType})
///     type  => ${pd.type}
///     ''');
///
/// prints:
///
///     id    => matrix (Id)
///     type  => std::vector< std::vector < double > >
///
/// [ParmDecl]s may be constructed with Id, declaratively:
///
///       var pd = new ParmDecl('matrix')..type = 'std::vector< std::vector < double > >';
///       print('''
///     id    => ${pd.id} (${pd.id.runtimeType})
///     type  => ${pd.type}
///     ''');
///
/// prints:
///
///     id    => matrix (Id)
///     type  => std::vector< std::vector < double > >
///
class ParmDecl extends Entity {
  String type;
  // custom <class ParmDecl>

  ParmDecl(id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  static RegExp declRe = new RegExp(r'^(.*?)\s+(\w+)\s*$');

  factory ParmDecl.fromDecl(String decl) {
    final declMatch = declRe.firstMatch(decl.trim());
    if (declMatch == null) {
      throw new ArgumentError('''
Invalid parm decl: <$decl>
Try something familiar like these:
  int x
  char const* name
  Reduce_func_t reducer
''');
    }

    final type = declMatch.group(1);
    final id = idFromString(declMatch.group(2));

    return new ParmDecl(id)..type = type;
  }

  toString() => '$type ${id.snake}';

  // end <class ParmDecl>
}

/// A method declaration, which consist of a [List<ParmDecl>] (i.e. the
/// parameters) and a [returnType]
///
/// [MethodDecl]s may be constructed from declaration text:
///
///       var md = new MethodDecl.fromDecl('Row_list_t find_row(std::string s)');
///       print(md);
///
/// prints:
///
///     Row_list_t find_row(std::string s) {
///     // custom <find_row>
///     // end <find_row>
///
///     }
///
/// [MethodDecl]s may be constructed with [id] declaratively:
///
///   var md = new MethodDecl('find_row')
///     ..parmDecls = [ new ParmDecl.fromDecl('std::string s') ]
///     ..returnType = 'Row_list_t';
///
/// prints:
///
/// Row_list_t find_row(std::string s) {
/// // custom <find_row>
/// // end <find_row>
///
/// }
///
class MethodDecl extends Entity {
  List<ParmDecl> parmDecls = [];
  String returnType;
  // custom <class MethodDecl>

  MethodDecl(id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  static RegExp declRe = new RegExp(r'^(.*?)\s+(\w+)\s*\(([^\)]*)\)\s*$');

  factory MethodDecl.fromDecl(String decl) {
    final declMatch = declRe.firstMatch(decl);
    if (declMatch == null) {
      throw new ArgumentError('''
Invalid method decl: $decl
Try something familiar like: "void add(int a, int b)"
''');
    }

    final returnType = declMatch.group(1);
    final id = idFromString(declMatch.group(2));
    final parmsText = declMatch.group(3);

    final parmDecls = parmsText
        .split(',')
        .map((String parm) => parm.trim())
        .where((String parm) => parm != '')
        .map((String parm) => new ParmDecl.fromDecl(parm))
        .toList();

    return new MethodDecl(id)
      ..returnType = returnType
      ..parmDecls = parmDecls;
  }

  String get signature => '$returnType ${id.snake}(${parmDecls.join(',')})';

  String get _declaration => '''
${this.docComment}$signature {
${chomp(indentBlock(customBlock(id.snake)))}
}''';

  String get asVirtual => 'virtual $_declaration';
  String get asNonVirtual => _declaration;
  String get asPureVirtual => 'virtual $signature = 0;';

  String declaration(bool isVirtual) => isVirtual ? asVirtual : asNonVirtual;

  toString() => _declaration;

  // end <class MethodDecl>
}

/// A collection of methods that as a group are either virtual or not.  A
/// *virtual* interface expresses a desire to have code generated that
/// will implement (i.e. derive from) the set of methods virtually. If the
/// interface is *not* virtual, it is an indication that the implementers
/// of the interface will provide implementations to be used via static
/// polymorphism.
///
///       var md = new Interface('alarmist')
///         ..doc = 'Methods that cause alarm'
///         ..methodDecls = [
///           'void shoutsFireInTheater(int volume)',
///           'void wontStopWithTheGlobalWarming()',
///           new MethodDecl.fromDecl('void growl()')..doc = 'Scare them'
///         ];
///       print(md);
///
/// prints:
///
///     /**
///      Methods that cause alarm
///     */
///     interface Alarmist
///       void shouts_fire_in_theater(int volume) {
///         // custom <shouts_fire_in_theater>
///         // end <shouts_fire_in_theater>
///       }
///       void wont_stop_with_the_global_warming() {
///         // custom <wont_stop_with_the_global_warming>
///         // end <wont_stop_with_the_global_warming>
///       }
///       /**
///        Scare them
///       */
///       void growl() {
///         // custom <growl>
///         // end <growl>
///       }
///     }
///
class Interface extends Entity {
  /// If true interface results in pure abstract class, else *static
  /// polymorphic* base.
  bool isVirtual = false;
  List<MethodDecl> get methodDecls => _methodDecls;
  // custom <class Interface>

  Interface(id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  get name => namer.nameClass(id);

  set methodDecls(Iterable decls) {
    _methodDecls = decls.map((var decl) => decl is String
        ? methodDecl(decl).declaration(isVirtual)
        : decl is MethodDecl
            ? decl.declaration(isVirtual)
            : throw new ArgumentError('''
MethodDecls must be initialized with String or MethodDecl
''')).toList();
  }

  /// The interface is empty if there are no methods
  bool get isEmpty => methodDecls.isEmpty;

  String get definition => '''
${_methodDecls.join('\n')}
''';

  toString() => '''
${this.docComment}interface ${id.capCamel}
${chomp(indentBlock(definition))}
}
''';

  // end <class Interface>
  List<MethodDecl> _methodDecls = [];
}

/// An [interface] with a [CppAccess], so interfaces can be scoped
class AccessInterface {
  AccessInterface(this.interface);

  Interface interface;
  CppAccess cppAccess = public;
  // custom <class AccessInterface>

  String get name => interface.name;
  String get definition => interface.definition;
  bool get isVirtual => interface.isVirtual;

  toString() => '${ev(cppAccess)}: ${interface.id.snake}';

  // end <class AccessInterface>
}
// custom <part method>

/// Convenience fucnction for creating an [Interface]
///
/// All interface must be named with an [Id]. This method accepts an [Id] or
/// creates one. Creation of [Id] requires a string in *snake case*
Interface interface(Object id) => new Interface(id is Id ? id : new Id(id));

/// Convenience fucnction for creating a [MethodDecl]
///
MethodDecl methodDecl(String decl) => new MethodDecl.fromDecl(decl);

AccessInterface accessInterface(Interface interface,
        [CppAccess cppAccess = public]) =>
    new AccessInterface(interface)..cppAccess = cppAccess;

// end <part method>
