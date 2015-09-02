part of ebisu_cpp.ebisu_cpp;

/// A parameter declaration.
///
/// Method signatures consist of a List of [ParmDecl] and a return type.
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
///       var pd = new ParmDecl('matrix')
///         ..type = 'std::vector< std::vector < double > >';
///
///       print('''
///     id    => ${pd.id} (${pd.id.runtimeType})
///     type  => ${pd.type}
///     ''');
///
/// prints:
///
///     id    => matrix (Id)
///     type  => std::vector< std::vector < double > >
class ParmDecl extends CppEntity {
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

/// A method declaration, which consists of a List of [ParmDecl] (i.e. the
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
class MethodDecl extends CppEntity {
  /// The template by which the method is parameterized
  Template template;
  List<ParmDecl> parmDecls = [];
  String returnType;

  /// True if this [MethodDecl] is *const*
  bool isConst = false;

  // custom <class MethodDecl>

  MethodDecl(id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  static RegExp declRe =
      new RegExp(r'^(.*?)\s+(\w+)\s*\(([^\)]*)\)\s*(const)?\s*$');

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
    final isConst = declMatch.group(4) != null;

    final parmDecls = parmsText
        .split(',')
        .map((String parm) => parm.trim())
        .where((String parm) => parm != '')
        .map((String parm) => new ParmDecl.fromDecl(parm))
        .toList();

    return new MethodDecl(id)
      ..returnType = returnType
      ..parmDecls = parmDecls
      ..isConst = isConst;
  }

  get _const => isConst ? ' const' : '';
  String get signature =>
      '$returnType ${id.snake}(${parmDecls.join(',')})$_const';

  String get asVirtual => 'virtual $signature';
  String get _templateDecl => template == null ? '' : '${template.decl}\n';
  String get asNonVirtual => '$_templateDecl$signature';
  String get asPureVirtual => 'virtual $signature = 0';

  String qualifiedSignature(bool isVirtual) =>
      isVirtual ? asVirtual : asNonVirtual;

  String declaration(bool isVirtual) => '${qualifiedSignature(isVirtual)};';

  String definition(bool isVirtual, [String methodPrefix = '']) => brCompact([
        qualifiedSignature(isVirtual),
        '{',
        chomp(customBlock('$methodPrefix::${id.snake}')),
        '}',
      ]);

  String commentedDeclaration(bool isVirtual) =>
      brCompact([docComment, declaration(isVirtual)]);

  toString() => declaration(true);

  // end <class MethodDecl>

}

/// A [Method] represents a single class method that will be *owned* by
/// the class implementing it. A [Method] method is *owned* by a single
/// class and therefore has an implementation defined in that class. The
/// [Method] *has a* signature which it refers to via
/// [MethodDecl]. [Method] will have its own [CodeBlock] for purpose of
/// allowing custom code and code insertion.
///
/// When defining a class, declaratively or otherwise, [Method]s are
/// created and owned by the [Class] based on the [implementedInterfaces]
/// specified. To access the [CodeBlock] of a [Method] in a [Class], use
/// the [getMethod] function.
class Method {
  MethodDecl methodDecl;
  CodeBlock codeBlock;

  // custom <class Method>
  // end <class Method>

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
class Interface extends CppEntity {
  List<MethodDecl> get methodDecls => _methodDecls;

  // custom <class Interface>

  Interface(id) : super(id);

  static _hasPrefix(String s) => s.startsWith('i_');

  static _forceInterfacePrefix(id) => id is Id
      ? (_hasPrefix(id.snake) ? id : idFromString('i_${id.snake}'))
      : id is String
          ? (_hasPrefix(id)
              ? idFromString(id)
              : idFromString('i_${idFromString(id).snake}'))
          : throw 'Interface *id* must be an Id or String';

  Iterable<Entity> get children => methodDecls;

  get name => namer.nameClass(id);

  set methodDecls(Iterable decls) {
    _methodDecls = decls
        .map((var decl) => decl is String
            ? methodDecl(decl)
            : decl is MethodDecl ? decl : throw new ArgumentError('''
MethodDecls must be initialized with String or MethodDecl
'''))
        .toList();
  }

  /// The interface is empty if there are no methods
  bool get isEmpty => methodDecls.isEmpty;

  String get definition => (class_(id)
        ..doc = doc
        ..getCodeBlock(clsPublic).snippets.addAll(
            [chomp(br(_methodDecls.map((m) => m.commentedDeclaration(true))))]))
      .definition;

  String get description => '''
${_methodDecls.map((md) => md.asVirtual).join('\n')}
''';

  InterfaceImplementation createImplementation(
          {CppAccess cppAccess: public, bool isVirtual: false}) =>
      new InterfaceImplementation(this,
          cppAccess: cppAccess, isVirtual: isVirtual);

  ///
  /// Create a [TestScenario] for each method.
  ///
  /// [tagMethodName] - If set the custom block uses the method name.
  ///
  /// [prefix] - A prefix for the test name. This is useful for test having the
  /// same interface or overloaded methods. A prefix can be used to prevent
  /// conflicts.
  ///
  Iterable<TestScenario> createMethodTests(
          {bool tagMethodName: true, String prefix: ''}) =>
      methodDecls.map((MethodDecl md) {
        var testName = md.id.snake;
        if (prefix.isNotEmpty) testName = '$prefix $testName';
        final result = testScenario(testName);
        if (tagMethodName) {
          result.startCodeBlock.tag = testName;
        }
        return result;
      });

  // end <class Interface>

  List<MethodDecl> _methodDecls = [];
}

/// An [interface] with a [CppAccess] to be implemented by a [Class]
class InterfaceImplementation extends CppEntity {
  Interface interface;
  CppAccess cppAccess = public;

  /// If true the interface is virtual
  bool isVirtual = false;

  // custom <class InterfaceImplementation>

  InterfaceImplementation(interface,
      {CppAccess cppAccess: public, bool isVirtual: false})
      : super(interface.id) {
    this.interface = interface;
    this.cppAccess = cppAccess;
    this.isVirtual = isVirtual;
  }

  String get name => interface.name;
  String get definition => interface.definition;
  List<MethodDecl> get methodDecls => interface.methodDecls;

  /// InterfaceImplementation has no children - returns empty [Iterable]
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  get _methodPrefix =>
      owner is Class ? owner.className : owner is CppFile ? onwer.baseName : '';

  Iterable<String> get methodImpls =>
      methodDecls.map((MethodDecl md) => brCompact([
            blockComment(chomp(
                brCompact([md.descr, "[Inherited from ${interface.name}]",]))),
            md.definition(isVirtual, _methodPrefix)
          ]));

  toString() => '${ev(cppAccess)}: ${interface.id.snake}';

  // end <class InterfaceImplementation>

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

// end <part method>
