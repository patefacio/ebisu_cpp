part of ebisu_cpp.cpp;

enum ClassCodeBlock {
  clsPublic,
  clsProtected,
  clsPrivate,
  clsPreDecl,
  clsPostDecl
}
const clsPublic = ClassCodeBlock.clsPublic;
const clsProtected = ClassCodeBlock.clsProtected;
const clsPrivate = ClassCodeBlock.clsPrivate;
const clsPreDecl = ClassCodeBlock.clsPreDecl;
const clsPostDecl = ClassCodeBlock.clsPostDecl;

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
  ///     Class(X x) : y_(f(x)) {}
  ///
  /// The usage would be:
  ///
  /// memberCtor([ memberCtorParm("y")..parmDecl = "X x" ])
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
  /// The usage would be:
  ///
  ///     memberCtor([
  ///       memberCtorParm("previous_mode")
  ///       ..parmDecl = "mode_t new_mode"
  ///       ..init = "umask(new_mode)"
  ///     ])
  set init(String init) => _init = init;
  String defaultValue;
  // custom <class MemberCtorParm>

  get decl => defaultValue != null
      ? '${member.passType} ${member.name} = $defaultValue'
      : '${member.passType} ${member.name}';

  get init => member.ctorInit != null
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
          : (throw Exception('''
MemberCtor ctor requires list of parms where each parm is a *String* naming the
member being initialized or a MemberCtorParm instance'''));

  MemberCtor(List parms, [this.decls]) {
    memberParms = parms.map((parm) => _makeParm(parm)).toList();
    if (decls == null) decls = [];
  }

  String get _templateDecl => _template == null ? '' : br(_template.decl);

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
      initializers.add(parm.init);
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
  /// If true makes members const provides single ctor
  bool immutable = false;
  /// List of processors supporting flavors of serialization
  List<Serializer> serializers = [];
  // custom <class Class>

  Class(Id id) : super(id);

  String get classStyle => struct ? 'struct' : 'class';

  //! Accessing auto-initilizes
  DefaultCtor get defaultCtor =>
      _defaultCtor = _defaultCtor == null ? new DefaultCtor() : _defaultCtor;
  withDefaultCtor(void f(DefaultCtor)) => f(defaultCtor);

  CopyCtor get copyCtor =>
      _copyCtor = _copyCtor == null ? new CopyCtor() : _copyCtor;
  withCopyCtor(void f(CopyCtor)) => f(copyCtor);

  MoveCtor get moveCtor =>
      _moveCtor = _moveCtor == null ? new MoveCtor() : _moveCtor;
  withMoveCtor(void f(MoveCtor)) => f(moveCtor);

  AssignCopy get assignCopy =>
      _assignCopy = _assignCopy == null ? new AssignCopy() : _assignCopy;
  withAssignCopy(void f(AssignCopy)) => f(assignCopy);

  AssignMove get assignMove =>
      _assignMove = _assignMove == null ? new AssignMove() : _assignMove;
  withAssignMove(void f(AssignMove)) => f(assignMove);

  Dtor get dtor => _dtor = _dtor == null ? new Dtor() : _dtor;
  withDtor(void f(Dtor)) => f(dtor);

  OpEqual get opEqual => _opEqual = _opEqual == null ? new OpEqual() : _opEqual;
  withOpEqual(void f(OpEqual)) => f(opEqual);

  OpLess get opLess => _opLess = _opLess == null ? new OpLess() : _opLess;
  withOpLess(void f(OpLess)) => f(opLess);

  OpOut get opOut => _opOut = _opOut == null ? new OpOut() : _opOut;
  withOpOut(void f(OpOut)) => f(opOut);

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

  set template(Object t) => _template = _makeTemplate(t);

  usesType(String type) => members.any((m) => m.type == type);
  get typesReferenced => members.map((m) => m.type);

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => b.decl))
    ..addAll(basesProtected.map((b) => b.decl))
    ..addAll(basesPrivate.map((b) => b.decl));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0 ? ' :\n' + indentBlock(_baseDecls.join(',\n')) : '';
  }

  CodeBlock getCodeBlock(ClassCodeBlock cb) {
    var result = _codeBlocks[cb];
    return (result == null) ? (_codeBlocks[cb] = codeBlock()) : result;
  }

  addFullMemberCtor() =>
      memberCtors.add(memberCtor(members.map((m) => m.name).toList()));

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

  Iterable<Member> get publicMembers =>
      members.where((m) => m.cppAccess == public);
  Iterable<Member> get protectedMembers =>
      members.where((m) => m.cppAccess == protected);
  Iterable<Member> get privateMembers =>
      members.where((m) => m.cppAccess == private);

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

  String get className => id.capSnake;

  get outStreamer => combine([
    '''
friend inline
std::ostream& operator<<(std::ostream& out,
                         $className const& item) {''',
    usesStreamers ? '  using fcs::utils::streamers::operator<<;' : null,
    '''
  ${
members.map((m) => "out << '\\n' << ${quote(m.name + ':')} << item.${m.vname}").join(';\n  ')
};
  return out;
}
'''
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

// CppClass
// class_(Object id) =>
//   new CppClass(id is Id? id : new Id(id));

Class class_(Object id) => new Class(id is Id ? id : new Id(id));

Template _makeTemplate(Object t) => t is Iterable
    ? new Template(t)
    : t is String ? new Template([t]) : t as Template;

defaultCtor() => new DefaultCtor();
copyCtor() => new CopyCtor();
moveCtor() => new MoveCtor();
assignCopy() => new AssignCopy();
assignMove() => new AssignMove();
dtor() => new Dtor();
opEqual() => new OpEqual();
opLess() => new OpLess();
opOut() => new OpOut();

/// Create a MemberCtor sans new, for more declarative construction
MemberCtor memberCtor([List memberParms, List<String> decls]) => new MemberCtor(
    memberParms == null ? [] : memberParms, decls == null ? [] : decls);

// end <part class>
