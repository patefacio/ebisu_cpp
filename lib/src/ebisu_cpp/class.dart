part of ebisu_cpp.ebisu_cpp;

/// The various supported code blocks associated with a C++ class. The
/// name indicates where in the class it appears. Within the class
/// definition the order is *public*, *protected* then
/// *private*. Additional locations for just before the class and just
/// after the class.
///
/// So, the following spec:
///
///         (class_('c')
///             ..customBlocks = [
///               clsPreDecl,
///               clsPublic,
///               clsProtected,
///               clsPrivate,
///               clsPostDecl
///             ])
///         .definition
///
///
/// Gives the following content:
///
///     // custom <ClsPreDecl C>
///     // end <ClsPreDecl C>
///
///     class C
///     {
///     public:
///       // custom <ClsPublic C>
///       // end <ClsPublic C>
///
///     protected:
///       // custom <ClsProtected C>
///       // end <ClsProtected C>
///
///     private:
///       // custom <ClsPrivate C>
///       // end <ClsPrivate C>
///
///     };
///
///     // custom <ClsPostDecl C>
///     // end <ClsPostDecl C>
///
enum ClassCodeBlock {
  /// The custom block appearing in the standard *public* section
  clsPublic,
  /// The custom block appearing in the standard *protected* section
  clsProtected,
  /// The custom block appearing in the standard *private* section
  clsPrivate,
  /// The custom block appearing just before the class definition
  clsPreDecl,
  /// The custom block appearing just after the class definition
  clsPostDecl
}
/// Convenient access to ClassCodeBlock.clsPublic with *clsPublic* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *public* section
///
const ClassCodeBlock clsPublic = ClassCodeBlock.clsPublic;

/// Convenient access to ClassCodeBlock.clsProtected with *clsProtected* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *protected* section
///
const ClassCodeBlock clsProtected = ClassCodeBlock.clsProtected;

/// Convenient access to ClassCodeBlock.clsPrivate with *clsPrivate* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *private* section
///
const ClassCodeBlock clsPrivate = ClassCodeBlock.clsPrivate;

/// Convenient access to ClassCodeBlock.clsPreDecl with *clsPreDecl* see [ClassCodeBlock].
///
/// The custom block appearing just before the class definition
///
const ClassCodeBlock clsPreDecl = ClassCodeBlock.clsPreDecl;

/// Convenient access to ClassCodeBlock.clsPostDecl with *clsPostDecl* see [ClassCodeBlock].
///
/// The custom block appearing just after the class definition
///
const ClassCodeBlock clsPostDecl = ClassCodeBlock.clsPostDecl;

abstract class ClassMethod {
  Class get parent => _parent;
  /// If true add logging
  bool log = false;
  Template get template => _template;
  /// C++ style access of method
  CppAccess cppAccess = public;
  // custom <class ClassMethod>

  String get definition;
  String get className => _parent.className;
  List<Member> get members => _parent.members;
  set template(Object t) => _template = _makeTemplate(t);

  // end <class ClassMethod>
  Class _parent;
  Template _template;
}

abstract class DefaultMethod extends ClassMethod {
  /// Has custom code, so needs protect block
  bool hasCustom = false;
  /// Code snippet to inject at beginning of method. The intent is for the
  /// methods to have standard generated implementations, but to also
  /// support programatic injection of implmementation into the
  /// methods. This supports injection near the top of the method.
  String topInject = '';
  /// Supports injecting code near the bottom of the method. *See*
  /// *topInject*
  String bottomInject = '';
  bool useDefault = false;
  bool delete = false;
  // custom <class DefaultMethod>

  String get customDefinition;
  String get prototype;

  String get definition => useDefault
      ? '$prototype = default;'
      : delete ? '$prototype = delete;' : customDefinition;

  // end <class DefaultMethod>
}

/// Default ctor, autoinitialized on read
class DefaultCtor extends DefaultMethod {
  // custom <class DefaultCtor>

  String get prototype => '${className}()';

  String get customDefinition {
    final cb = customBlock('${className} defaultCtor');
    var result = '''
${className}() {
$topInject
${hasCustom? indentBlock(cb) : ''}
$bottomInject
}''';
    return result;
  }

  // end <class DefaultCtor>
}

/// Copy ctor, autoinitialized on read
class CopyCtor extends DefaultMethod {
  // custom <class CopyCtor>

  String get prototype => '${className}(${className} const& other)';

  String get customDefinition {
    final cb = customBlock('${className} copyCtor');
    var result = '''
${className}(${className} const& other) {
$topInject
${hasCustom? indentBlock(cb) : ''}
$bottomInject
}''';
    return result;
  }

  // end <class CopyCtor>
}

/// Move ctor, autoinitialized on read
class MoveCtor extends DefaultMethod {
  // custom <class MoveCtor>

  String get prototype => '${className}(${className} && other)';

  String get customDefinition => 'Move Ctor';

  // end <class MoveCtor>
}

class AssignCopy extends DefaultMethod {
  // custom <class AssignCopy>

  String get prototype => '${className}& operator=(${className} const&)';
  String get customDefinition =>
      throw 'AssignCopy not generated - specify useDefault or delete for ${className}';

  // end <class AssignCopy>
}

class AssignMove extends DefaultMethod {
  // custom <class AssignMove>

  String get prototype => '${className}& operator=(${className} &&)';
  String get customDefinition =>
      throw 'AssignMove not generated - specify useDefault or delete for ${className}';

  // end <class AssignMove>
}

/// Provides a destructor
class Dtor extends DefaultMethod {
  bool abstract = false;
  // custom <class Dtor>

  String get definition => delete
      ? throw "Don't delete the destructor for $className"
      : super.definition;

  String get prototype => '~${className}()';

  String get customDefinition => abstract
      ? '''
virtual ~${className}() {
$topInject
$bottomInject
}'''
      : '''
~${className}() {
$topInject
$bottomInject
}''';

  // end <class Dtor>
}

/// A *Member Constructor Parameter*. Defines a single parameter to be passed to a
/// MemberCtor in order to initialize a single member variable. MemberCtor will
/// convert strings automatically into instances of MemberCtorParm. For example:
///
///     memberCtor(['x', 'y'])
///
/// would produce the following constructor:
///
///     class Point {
///     public:
///       Point(int x, int y) : x_{x}, y_{y} {}
///     private:
///       int x_;
///       int y_;
///     }
///
/// But to modify the parameter definition or initializtaion you might rather
/// construct and modify the MemberCtorParm instead of taking the default:
///
///         final cls = class_('point')
///           ..members = [ member('x')..init = 0, member('y')..init = 0 ]
///           ..memberCtors = [
///             memberCtor( [
///               memberCtorParm('x')
///               ..defaultValue = '42',
///               memberCtorParm('y')
///               ..defaultValue = '42'] )
///           ];
///
/// which produces:
///
///     class Point
///     {
///     public:
///       Point(
///         int x = 42,
///         int y = 42) :
///         x_ { x },
///         y_ { y } {
///       }
///
///     private:
///       int x_ { 0 };
///       int y_ { 0 };
///     };
///
///
class MemberCtorParm {
  MemberCtorParm(this.name);

  /// Name of member initialized by argument to member ctor
  final String name;
  /// cpp member to be initialized
  Member member;
  /// *Override* for arguemnt declaration. This is rarely needed. Suppose
  /// you want to initialize member *Y y* from an input argument *X x* that
  /// requires a special function *f* to do the conversion:
  ///
  ///     Class(X x) : y_ {f(x)}
  ///
  /// Which would be achieved by:
  ///
  ///     memberCtor([
  ///       memberCtorParm("y")
  ///       ..parmDecl = "X x"
  ///       ..init = "f(x)"
  ///     ])
  String parmDecl;
  /// *Override* of initialization text. This is rarely needed since
  /// initialization of members in a member ctor is straightforward:
  ///
  /// This definition:
  ///
  ///     memberCtor(['x', 'y'])
  ///
  /// would produce the following constructor:
  ///
  ///     class Point {
  ///     public:
  ///       Point(int x, int y) : x_{x}, y_{y} {}
  ///     private:
  ///       int x_;
  ///       int y_;
  ///     }
  ///
  /// But sometimes you need more:
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  /// Which would be achieved by:
  ///
  ///     memberCtor([
  ///       memberCtorParm("previous_mode")
  ///       ..parmDecl = "mode_t new_mode"
  ///       ..init = "umask(new_mode)"
  ///     ])
  set init(String init) => _init = init;
  /// If set provides a default value for the parm in the ctor. For example:
  ///
  ///     memberCtorParm('x')..defaultValue = '42'
  ///
  /// where the type of member *x* is *int* might yield:
  ///
  ///     Cls(int x = 42) : x_{x}
  String defaultValue;
  // custom <class MemberCtorParm>

  /// The parameter as declared in the ctor, including any defaultValue. So, the:
  ///     mode_t new_mode
  /// in the following ctor
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  get decl => parmDecl != null
      ? parmDecl
      : defaultValue != null
          ? '${member.passType} ${member.name} = $defaultValue'
          : '${member.passType} ${member.name}';

  /// The complete initialization text for the member in the ctor. So, the:
  ///     previous_mode_{umask(new_mode)}
  /// in the following:
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  get member_init => member.ctorInit != null
      ? '${member.vname} { ${member.ctorInit} }'
      : _init != null
          ? '${member.vname} { $_init }'
          : '${member.vname} { ${member.name} }';

  // end <class MemberCtorParm>
  String _init;
}

/// Create a MemberCtorParm sans new, for more declarative construction
MemberCtorParm memberCtorParm([String name]) => new MemberCtorParm(name);

/// Specificication for a member constructor. A member constructor is a constructor
/// with the intent of initializing one or more members of a class.
///
/// Assumig a class has members *int x* and *int y*
/// *memberCtor(["x", "y"])*
///
/// would generate the corresponding:
///
///     Class(int x, int y) : x_{x}, y_{y} {}
///
/// If custom logic is additionally required, set the *hasCustom* flag to include a
/// custom block. In that case the class might look like:
///
///     Class(int x, int y) : x_{x}, y_{y} {
///       // custom <Class>
///       // end <Class>
///     }
///
class MemberCtor extends ClassMethod {
  /// List of members that are passed as arguments for initialization
  List<MemberCtorParm> memberParms = [];
  /// List of additional decls ["Type Argname", ...]
  List<String> decls;
  /// Has custom code, so needs protect block
  set hasCustom(bool hasCustom) => _hasCustom = hasCustom;
  /// Label for custom protect block if desired
  set customLabel(String customLabel) => _customLabel = customLabel;
  /// If set automatically includes all members as args
  bool allMembers = false;
  // custom <class MemberCtor>

  static _makeParm(parm) => (parm is String)
      ? memberCtorParm(parm)
      : (parm is MemberCtorParm)
          ? parm
          : (throw new Exception('''
MemberCtor ctor requires list of parms where each parm is a *String* naming the
member being initialized or a MemberCtorParm instance'''));

  MemberCtor(List parms, [this.decls]) {
    memberParms = parms.map((parm) => _makeParm(parm)).toList();
    if (decls == null) decls = [];
  }

  String get _templateDecl => _template == null ? '' : br(_template.decl);

  /// The [MemberCtor] definition as it appears in the class
  String get definition {
    if (allMembers) {
      assert(memberParms.isEmpty);
      memberParms =
          parent.members.map((m) => _makeParm(m.name)..member = m).toList();
    } else {
      memberParms.forEach((MemberCtorParm mp) =>
          mp.member = parent.members.firstWhere((m) => mp.name == m.name));
    }

    List<String> argDecls = decls == null ? [] : new List<String>.from(decls);
    List<String> initializers = [];

    parent.bases
        .where((b) => b.init != null)
        .forEach((b) => initializers.add(b.init));

    memberParms.forEach((MemberCtorParm parm) {
      argDecls.add(parm.decl);
      initializers.add(parm.member_init);
    });

    return '''
$_templateDecl${className}(
${indentBlock(argDecls.join(',\n'))}) :
${indentBlock(initializers.join(',\n'))} {
${indentBlock(_protectBlock)}}''';
  }

  get hasCustom => _hasCustom || _customLabel != null;

  get customLabel => _customLabel != null ? _customLabel : decls.join(', ');

  get _protectBlock =>
      hasCustom ? customBlock('${className}($customLabel)') : '';

  // end <class MemberCtor>
  bool _hasCustom = false;
  String _customLabel;
}

/// Provides *operator==()*
class OpEqual extends ClassMethod {
  // custom <class OpEqual>

  String get definition => '''bool operator==(${className} const& rhs) const {
  return this == &rhs ||
    (${
members.map((m) => '${m.vname} == rhs.${m.vname}').join(' &&\n    ')
});
}

bool operator!=($className const& rhs) const {
  return !(*this == rhs);
}''';

  // end <class OpEqual>
}

/// Provides *operator<()*
class OpLess extends ClassMethod {
  // custom <class OpLess>

  String get definition {
    List pairs = [];
    pairs.addAll(members.map((m) => [m.vname, 'rhs.${m.vname}']));
    return '''
bool operator<($className const& rhs) const {
  return ${
pairs.map((p) => '${p[0]} != ${p[1]}? ${p[0]} < ${p[1]} : (').join('\n    ')
}
    false${pairs.map((_) => ')').join()};
}
''';
  }

  // end <class OpLess>
}

/// Provides *operator<<()*
class OpOut extends ClassMethod {
  // custom <class OpOut>

  String get definition => '''
friend inline
std::ostream& operator<<(std::ostream &out,
                         $className const& item) {
  using fcs::utils::streamers::operator<<;
  fcs::utils::Block_indenter indenter;
  char const* indent(indenter.current_indentation_text());
  out << \'\\n\' << indent << "$className(" << &item << ") {";
${
combine(members.map((m) =>
'  out << \'\\n\' << indent << "  ${m.name}:" << item.${m.vname};'))
}
  out << \'\\n\' << indent << "}\\n";
  return out;
}''';

  // end <class OpOut>
}

/// A C++ class.
///
/// Classes optionally have these items:
///
/// * A [template]
/// * A collection of [bases]
/// * A collection of [members]
/// * A collection of class local [usings]
/// * A collection of class local [enums]
/// * A collection of class local [forward_ptrs] which are like [usings] but standardized for pointer type
/// * A collection of *optionally included* standard methods including:
///
///   * Constructors including:
///
///     * [CopyCtor]
///     * [MoveCtor]
///     * [DefaultCtor]
///     * Zero or more member initializing ctors [MemberCtor]
///
///   * Assignment functions:
///
///     * [AssignCopy]
///     * [AssignMove]
///
///   * [Dtor]
///
///   * Standard Utility Methods
///
///     * [OpEqual]
///     * [OpLess]
///     * [OpOut] - Support for streaming fields
///
/// * A fixed collection of indexed [codeBlocks] that can be used for
///   providing *CustomBlocks* and/or for dynamically injecting code - see
///   [CodeBlock].
///
class Class extends Entity {
  /// Is this definition a *struct*
  bool struct = false;
  /// The template by which the class is parameterized
  Template get template => _template;
  /// List of usings that will be scoped to this class near the top of
  /// the class definition.
  List<String> usings = [];
  /// List of usings to occur after the class declaration. Sometimes it is
  /// useful to establish some type definitions directly following the class
  /// so they may be reused among any client of the class. For instance if
  /// class *Foo* will most commonly be used in vector, the using occuring
  /// just after the class definition will work:
  ///
  ///     using Foo = std::vector<Foo>;
  List<String> usingsPostDecl = [];
  /// Base classes this class derives form.
  List<Base> bases = [];
  List<MemberCtor> memberCtors = [];
  List<PtrType> forwardPtrs = [];
  List<Enum> enumsForward = [];
  List<Enum> enums = [];
  List<Member> members = [];
  List<ClassCodeBlock> customBlocks = [];
  bool isSingleton = false;
  Map<ClassCodeBlock, CodeBlock> get codeBlocks => _codeBlocks;
  /// If true adds streaming support
  bool streamable = false;
  /// If true adds {using fcs::utils::streamers::operator<<} to streamer
  bool usesStreamers = false;
  /// If true adds test function to tests of the header it belongs to
  bool includeTest = false;
  /// If true makes all members const provides single member ctor
  /// initializing all.
  ///
  /// There are a few options to achieve *immutable* support. The first is
  /// this type, where all fields are constant and therefore must be
  /// initialized. An alternative concept is immutable from perspective of
  /// user. This can be achieved with use of [addFullMemberCtor] and the
  /// developer ensuring the members are not modified. This provides a
  /// stronger guarantee of immutability.
  bool immutable = false;
  /// List of processors supporting flavors of serialization
  List<Serializer> serializers = [];
  /// List of interfaces this class implements. The [Interface] determines
  /// whether the polymorphism is runtime via virtual methods or compile
  /// time via call forwarding. The entries in the list must be either:
  ///
  /// * Interface: identifying the interface implemented. The interface will
  ///   be wrapped in an [AccessInterface] with [public] access.
  ///
  /// * AccessInterface: which will be used directly
  List implementedInterfaces = [];
  // custom <class Class>

  Class(Id id) : super(id);

  Iterable<Entity> get children => concat([enumsForward, enums, members]);

  String get classStyle => struct ? 'struct' : 'class';

  /// Auto-initializing accessor for the [DefaultCtor]
  DefaultCtor get defaultCtor =>
      _defaultCtor = _defaultCtor == null ? new DefaultCtor() : _defaultCtor;
  withDefaultCtor(void f(DefaultCtor)) => f(defaultCtor);
  bool get hasDefaultCtor => _defaultCtor != null;

  /// Auto-initializing accessor for the [CopyCtor]
  CopyCtor get copyCtor =>
      _copyCtor = _copyCtor == null ? new CopyCtor() : _copyCtor;
  withCopyCtor(void f(CopyCtor)) => f(copyCtor);
  bool get hasCopyCtor => _copyCtor != null;

  /// Auto-initializing accessor for the [MoveCtor]
  MoveCtor get moveCtor =>
      _moveCtor = _moveCtor == null ? new MoveCtor() : _moveCtor;
  withMoveCtor(void f(MoveCtor)) => f(moveCtor);
  bool get hasMoveCtor => _moveCtor != null;

  /// Auto-initializing accessor for the [AssignCopy]
  AssignCopy get assignCopy =>
      _assignCopy = _assignCopy == null ? new AssignCopy() : _assignCopy;
  withAssignCopy(void f(AssignCopy)) => f(assignCopy);
  bool get hasAssignCopy => _assignCopy != null;

  /// Auto-initializing accessor for the [AssignMove]
  AssignMove get assignMove =>
      _assignMove = _assignMove == null ? new AssignMove() : _assignMove;
  withAssignMove(void f(AssignMove)) => f(assignMove);
  bool get hasAssignMove => _assignMove != null;

  /// Auto-initializing accessor for the [Dtor]
  Dtor get dtor => _dtor = _dtor == null ? new Dtor() : _dtor;
  withDtor(void f(Dtor)) => f(dtor);
  bool get hasDtor => _dtor != null;

  /// Auto-initializing accessor for the [OpEqual]
  OpEqual get opEqual => _opEqual = _opEqual == null ? new OpEqual() : _opEqual;
  withOpEqual(void f(OpEqual)) => f(opEqual);
  bool get hasOpEqual => _opEqual != null;

  /// Auto-initializing accessor for the [OpLess]
  OpLess get opLess => _opLess = _opLess == null ? new OpLess() : _opLess;
  withOpLess(void f(OpLess)) => f(opLess);
  bool get hasOpLess => _opLess != null;

  /// Auto-initializing accessor for the [OpOut]
  OpOut get opOut => _opOut = _opOut == null ? new OpOut() : _opOut;
  withOpOut(void f(OpOut)) => f(opOut);
  bool get hasOpOut => _opOut != null;

  set defaultCtor(DefaultCtor defaultCtor) => _defaultCtor = defaultCtor;
  set copyCtor(CopyCtor copyCtor) => _copyCtor = copyCtor;
  set moveCtor(MoveCtor moveCtor) => _moveCtor = moveCtor;
  set assignCopy(AssignCopy assignCopy) => _assignCopy = assignCopy;
  set assignMove(AssignMove assignMove) => _assignMove = assignMove;
  set dtor(Dtor dtor) => _dtor = dtor;
  set opEqual(OpEqual opEqual) => _opEqual = opEqual;
  set opLess(OpLess opLess) => _opLess = opLess;
  set opOut(OpOut opOut) => _opOut = opOut;

  Iterable<Base> get basesPublic => bases.where((b) => b.access == public);
  Iterable<Base> get basesProtected =>
      bases.where((b) => b.access == protected);
  Iterable<Base> get basesPrivate => bases.where((b) => b.access == private);

  void withCustomBlock(ClassCodeBlock cb, void f(CodeBlock)) =>
      f(getCodeBlock(cb));

  set template(Object t) => _template = _makeTemplate(t);

  usesType(String type) => members.any((m) => m.type == type);
  get typesReferenced => members.map((m) => m.type);

  /// Get the specified [ClassCodeBlock] and if not present creates a
  /// fresh one.
  ///
  /// [CodeBlock] allows for injection of code at a location indicated
  /// by the [ClassCodeBlock] argument. For example:
  ///
  ///    class_('c')
  ///    ..getCodeBlock(clsPublic).snippets.add('// foo')
  ///    ..definition
  ///
  /// generates something like:
  ///
  ///    class C
  ///    {
  ///    public:
  ///      // foo
  ///    };
  ///
  CodeBlock getCodeBlock(ClassCodeBlock cb) {
    var result = _codeBlocks[cb];
    return (result == null) ? (_codeBlocks[cb] = codeBlock()) : result;
  }

  /// Adds a member constructor that provides for initialization of
  /// all members
  ///
  /// Used by [immutable].
  addFullMemberCtor() =>
      memberCtors.add(memberCtor(members.map((m) => m.name).toList()));

  /// Returns a string representation of the class definition
  String get definition {
    if (_definition == null) {
      if (immutable) {
        members.forEach((Member m) {
          if (_defaultCtor == null) {
            m.noInit = true;
          }
          m.isConst = !m.mutable;
          m.access = ro;
        });
        if (memberCtors.isEmpty) {
          addFullMemberCtor();
        }
      }

      if (isSingleton) {
        defaultCtor.cppAccess = private;
      }

      enums.forEach((e) => e.isNested = true);
      _methods.forEach((m) {
        if (m != null) m._parent = this;
      });
      memberCtors.forEach((m) {
        if (m != null) m._parent = this;
      });
      customBlocks.forEach((ClassCodeBlock cb) {
        getCodeBlock(cb).tag = '${evCap(cb)} $className';
      });
      _definition = combine(_parts);
    }
    return _definition;
  }

  /// Members defined in the [public] section
  Iterable<Member> get publicMembers =>
      members.where((m) => m.cppAccess == public);
  /// Members defined in the [protected] section
  Iterable<Member> get protectedMembers =>
      members.where((m) => m.cppAccess == protected);
  /// Members defined in the [private] section
  Iterable<Member> get privateMembers =>
      members.where((m) => m.cppAccess == private);

  void _finalizeEntity() {
    for (int i = 0; i < implementedInterfaces.length; ++i) {
      final interface = implementedInterfaces[i];
      if (interface is Interface) {
        implementedInterfaces[i] = new AccessInterface(interface);
      }
      assert(implementedInterfaces[i] is AccessInterface);
    }
    _logger.info('Class ($id) finalized supporting: ${implementedInterfaces}');
  }

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => b.decl))
    ..addAll(basesProtected.map((b) => b.decl))
    ..addAll(basesPrivate.map((b) => b.decl));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0 ? ' :\n' + indentBlock(_baseDecls.join(',\n')) : '';
  }

  get _ctorMethods => [_defaultCtor, _copyCtor, _moveCtor];

  get _allCtors => []
    ..addAll(_ctorMethods.where((m) => m != null))
    ..addAll(memberCtors);

  get _opMethods =>
      [_assignCopy, _assignMove, _dtor, _opEqual, _opLess, _opOut];

  get _methods => []
    ..addAll(_ctorMethods)
    ..addAll(_opMethods);

  get _parts => [
    _forwardPtrs,
    enumsForward.map((e) => e.toString()).join('\n'),
    _codeBlockText(clsPreDecl),
    briefComment,
    detailedComment,
    _templateDecl,
    _classOpener,
    _wrapInAccess(struct ? null : public, indentBlock(combine([
      br(usings.map((u) => 'using $u;')),
      br([_enumDecls, _enumStreamers]),
      br(publicMembers
          .where((m) => m.isPublicStaticConst)
          .map((m) => _memberDefinition(m))),
      br(_allCtors
          .where((m) => m.cppAccess == public)
          .map((m) => m.definition)),
      br(_opMethods
          .where((m) => m != null && m.cppAccess == public)
          .map((m) => m.definition)),
      br(implementedInterfaces
          .where((i) => i.cppAccess == public)
          .map((i) => i.definition)),
      br(_singleton),
      _codeBlockText(clsPublic),
      br(publicMembers
          .where((m) => !m.isPublicStaticConst)
          .map((m) => _memberDefinition(m))),
      chomp(combine(members.map((m) => br([m.getter, m.setter])))),
      streamable ? outStreamer : null,
      serializers.map((s) => s.serialize(this)),
    ]))),
    _wrapInAccess(protected, indentBlock(combine([
      _codeBlockText(clsProtected),
      br(_allCtors
          .where((m) => m.cppAccess == protected)
          .map((m) => m.definition)),
      br(_opMethods
          .where((m) => m != null && m.cppAccess == protected)
          .map((m) => m.definition)),
      br(implementedInterfaces
          .where((i) => i.cppAccess == protected)
          .map((i) => i.definition)),
      br(protectedMembers.map((m) => _memberDefinition(m)))
    ]))),
    _wrapInAccess(private, indentBlock(combine([
      _codeBlockText(clsPrivate),
      br(_allCtors
          .where((m) => m.cppAccess == private)
          .map((m) => m.definition)),
      br(_opMethods
          .where((m) => m != null && m.cppAccess == private)
          .map((m) => m.definition)),
      br(implementedInterfaces
          .where((i) => i.cppAccess == private)
          .map((i) => i.definition)),
      br(privateMembers.map((m) => _memberDefinition(m)))
    ]))),
    br(_classCloser),
    br(usingsPostDecl.map((u) => 'using $u;')),
    _codeBlockText(clsPostDecl),
  ];

  get _singleton => isSingleton
      ? '''
static $className & instance() {
  static $className instance_s;
  return instance_s;
}'''
      : null;

  get _templateDecl => _template != null ? _template.decl : null;
  get _enumDecls => enums.map((e) => e.decl);
  get _enumStreamers => enums.map((e) => e.streamSupport);
  _access(CppAccess access) => access == null
      ? ''
      : '''
${ev(access)}:
''';

  _wrapInAccess(CppAccess access, String txt) {
    return (txt != null && txt.length > 0)
        ? '''
${_access(access)}${txt}'''
        : null;
  }

  _codeBlockText(ClassCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null ? codeBlock.toString() : null;
  }

  _memberDefinition(Member m) => '$m';

  /// Class names are capitalized *snake case*
  String get className => id.capSnake;

  String get _streamInstanceOpener =>
      'out << "${className}(" << &item << ") {";';
  String get _streamInstanceCloser => r'out << "\n}\n";';

  String _streamBase(Base b) => 'out << static_cast<${b.className}>(item);';
  get _streamBases =>
      bases.where((b) => b.streamable).map((b) => _streamBase(b));

  String _streamMember(Member m) =>
      'out << "\\n  ${m.name}: " << item.${m.vname};';
  get _streamMembers => members.map((m) => _streamMember(m));

  /// Returns the *operator<<* method for this class
  get outStreamer => combine([
    '''
friend inline
std::ostream& operator<<(std::ostream& out,
                         $className const& item) {''',
    usesStreamers ? '  using fcs::utils::streamers::operator<<;' : null,
    indentBlock(chomp(br([
      _streamBases,
      _streamInstanceOpener,
      _streamMembers,
      _streamInstanceCloser,
      'return out;',
    ]))),
    '}'
  ]);

  get _classOpener => '''
$classStyle $className$_baseDecl
{''';
  get _classCloser => '};';

  get _forwardPtrs {
    if (forwardPtrs.length > 0) {
      final name = className;
      List<String> parts = ['class $name;'];
      for (var ptr in forwardPtrs) {
        parts.add('using ${name}_${ptrSuffix(ptr)} = ${ptrType(ptr, name)};');
      }
      return parts.join('\n');
    }
    return null;
  }

  // end <class Class>
  /// The contents of the class definition. *Inaccessible* and established
  /// as a member so custom *definition* getter can be called multiple times
  /// on the same class and results lazy-inited here
  String _definition;
  Template _template;
  DefaultCtor _defaultCtor;
  CopyCtor _copyCtor;
  MoveCtor _moveCtor;
  AssignCopy _assignCopy;
  AssignMove _assignMove;
  Dtor _dtor;
  OpEqual _opEqual;
  OpLess _opLess;
  OpOut _opOut;
  Map<ClassCodeBlock, CodeBlock> _codeBlocks = {};
}
// custom <part class>

/// Convenience fucnction for creating a [Class]
///
/// All classes must be named with an [Id]. This method accepts an [Id] or
/// creates one. Creation of [Id] requires a string in *snake case*
Class class_(Object id) => new Class(id is Id ? id : new Id(id));

/// Create a template from (1) a single string (2) [Iterable] of arguments for
/// construction
Template _makeTemplate(Object t) => t is Iterable
    ? new Template(t)
    : t is String ? new Template([t]) : t as Template;

/// Convenience returning empty [DefaultCtor]
DefaultCtor defaultCtor() => new DefaultCtor();
/// Convenience returning empty [CopyCtor]
CopyCtor copyCtor() => new CopyCtor();
/// Convenience returning empty [MoveCtor]
MoveCtor moveCtor() => new MoveCtor();
/// Convenience returning empty [AssignCopy]
AssignCopy assignCopy() => new AssignCopy();
/// Convenience returning empty [AssignMove]
AssignMove assignMove() => new AssignMove();
/// Convenience returning empty [Dtor]
Dtor dtor() => new Dtor();
/// Convenience returning empty [OpEqual]
OpEqual opEqual() => new OpEqual();
/// Convenience returning empty [OpLess]
OpLess opLess() => new OpLess();
/// Convenience returning empty [OpOut]
OpOut opOut() => new OpOut();

/// Create a MemberCtor sans new, for more declarative construction
MemberCtor memberCtor([List memberParms, List<String> decls]) => new MemberCtor(
    memberParms == null ? [] : memberParms, decls == null ? [] : decls);

// end <part class>