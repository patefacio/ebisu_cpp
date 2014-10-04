part of ebisu_cpp.cpp;

class ClassCodeBlock implements Comparable<ClassCodeBlock> {
  static const CLS_PUBLIC = const ClassCodeBlock._(0);
  static const CLS_PROTECTED = const ClassCodeBlock._(1);
  static const CLS_PRIVATE = const ClassCodeBlock._(2);
  static const CLS_PRE_DECL = const ClassCodeBlock._(3);
  static const CLS_POST_DECL = const ClassCodeBlock._(4);

  static get values => [
    CLS_PUBLIC,
    CLS_PROTECTED,
    CLS_PRIVATE,
    CLS_PRE_DECL,
    CLS_POST_DECL
  ];

  final int value;

  int get hashCode => value;

  const ClassCodeBlock._(this.value);

  copy() => this;

  int compareTo(ClassCodeBlock other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case CLS_PUBLIC: return "ClsPublic";
      case CLS_PROTECTED: return "ClsProtected";
      case CLS_PRIVATE: return "ClsPrivate";
      case CLS_PRE_DECL: return "ClsPreDecl";
      case CLS_POST_DECL: return "ClsPostDecl";
    }
    return null;
  }

  static ClassCodeBlock fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "ClsPublic": return CLS_PUBLIC;
      case "ClsProtected": return CLS_PROTECTED;
      case "ClsPrivate": return CLS_PRIVATE;
      case "ClsPreDecl": return CLS_PRE_DECL;
      case "ClsPostDecl": return CLS_POST_DECL;
      default: return null;
    }
  }

}

abstract class ClassMethod {

  Class get parent => _parent;
  /// If true add logging
  bool log = false;
  Template get template => _template;

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
  bool useDefault = false;
  bool delete = false;

  // custom <class DefaultMethod>

  String get customDefinition;
  String get prototype;

  String get definition =>
    useDefault? '$prototype = default;' :
    delete? '$prototype = delete;' :
    customDefinition;

  // end <class DefaultMethod>
}

/// Default ctor, autoinitialized on read
class DefaultCtor extends DefaultMethod {


  // custom <class DefaultCtor>

  String get prototype =>
    '${className}(${className} const& other)';

  String get customDefinition {
    final cb = customBlock('${className} defaultCtor');
    var result = '''
${className}() {
${hasCustom? indentBlock(cb) : ''}}''';
    return result;
  }

  // end <class DefaultCtor>
}

/// Copy ctor, autoinitialized on read
class CopyCtor extends DefaultMethod {


  // custom <class CopyCtor>

  String get prototype =>
    '${className}(${className} const& other)';

  String get customDefinition {
    final cb = customBlock('${className} copyCtor');
    var result = '''
${className}(${className} const& other) {
${hasCustom? indentBlock(cb) : ''}}''';
    return result;
  }

  // end <class CopyCtor>
}

/// Move ctor, autoinitialized on read
class MoveCtor extends DefaultMethod {


  // custom <class MoveCtor>

  String get prototype =>
    '${className}(${className} && other)';

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

class Dtor extends DefaultMethod {


  // custom <class Dtor>

  String get definition =>
    delete? throw "Don't delete the destructor for $className" : super.definition;
  String get prototype => '~${className}()';
  String get customDefinition => '~${className}() {}';

  // end <class Dtor>
}

class MemberCtor extends ClassMethod {

  MemberCtor(this.memberArgs, [ this.optInit, this.decls ]);

  /// List of members that are passed as arguments for initialization
  List<String> memberArgs = [];
  /// Map member name to text for initialization
  Map<String, String> optInit = {};
  /// List of additional decls ["Type Argname", ...]
  List<String> decls = [];
  /// Has custom code, so needs protect block
  bool hasCustom = false;

  // custom <class MemberCtor>

  String get _templateDecl => _template == null? '' : br(_template.decl);

  String get definition {
    List<String> argDecls = decls == null? [] : new List<String>.from(decls);
    List<String> initializers = [];
    memberArgs.forEach((String arg) {
      final member = members.singleWhere((m) => m.id.snake == arg);
      var decl = member.passDecl;
      final init = optInit[arg];
      if(init != null)
        decl += ' = $init';

      argDecls.add(decl);
      initializers.add('${member.vname} { $arg }');
    });
    return '''
$_templateDecl${className}(
${indentBlock(argDecls.join(',\n'))}) :
${indentBlock(initializers.join(',\n'))} {
${indentBlock(_protectBlock)}}''';
  }

  get _protectBlock => hasCustom?
    customBlock('${className}(${decls.join(", ")} + ${memberArgs.join(", ")}') : '';

  // end <class MemberCtor>
}

/// Create a MemberCtor sans new, for more declarative construction
MemberCtor
memberCtor(List<String> memberArgs,
    [
      Map<String, String> optInit,
      List<String> decls
    ]) =>
  new MemberCtor(memberArgs,
      optInit,
      decls);

class OpEqual extends ClassMethod {


  // custom <class OpEqual>

  String get definition => '''bool operator==(${className} const& rhs) {
  return this == &rhs ||
    (${
members.map((m) => '${m.vname} == rhs.${m.vname}').join(' &&\n    ')
});
}''';


  // end <class OpEqual>
}

class OpLess extends ClassMethod {


  // custom <class OpLess>

  String get definition {
    List pairs = [];
    pairs.addAll(members.map((m) => [ m.vname, 'rhs.${m.vname}' ]));
    return '''
bool operator<($className const& rhs) {
  return ${
pairs.map((p) => '${p[0]} != ${p[1]}? ${p[0]} < ${p[1]} : (').join('\n    ')
}
    false${pairs.map((_) => ')').join()};
}
''';
  }

  // end <class OpLess>
}

class OpOut extends ClassMethod {


  // custom <class OpOut>

  String get definition => '''
friend inline
std::ostream& operator<<(std::ostream &out, $className const& item) {
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
  Template get template => _template;
  List<String> usings = [];
  List<Base> bases = [];
  List<MemberCtor> memberCtors = [];
  List<PtrType> forwardPtrs = [];
  List<Enum> enumsForward = [];
  List<Enum> enums = [];
  List<Member> members = [];
  List<ClassCodeBlock> customBlocks = [];
  Map<ClassCodeBlock, CodeBlock> get codeBlocks => _codeBlocks;
  /// If true adds streaming support
  bool streamable = false;

  // custom <class Class>

  Class(Id id) : super(id);

  String get classStyle => struct? 'struct' : 'class';

  //! Accessing auto-initilizes
  DefaultCtor get defaultCtor => _defaultCtor = _defaultCtor == null? new DefaultCtor() : _defaultCtor;
  CopyCtor get copyCtor => _copyCtor = _copyCtor == null? new CopyCtor() : _copyCtor;
  MoveCtor get moveCtor => _moveCtor = _moveCtor == null? new MoveCtor() : _moveCtor;
  AssignCopy get assignCopy => _assignCopy = _assignCopy == null? new AssignCopy() : _assignCopy;
  AssignMove get assignMove => _assignMove = _assignMove == null? new AssignMove() : _assignMove;
  Dtor get dtor => _dtor = _dtor == null? new Dtor() : _dtor;
  OpEqual get opEqual => _opEqual = _opEqual == null? new OpEqual() : _opEqual;
  OpLess get opLess => _opLess = _opLess == null? new OpLess() : _opLess;
  OpOut get opOut => _opOut = _opOut == null? new OpOut() : _opOut;


  set defaultCtor(DefaultCtor defaultCtor) =>  _defaultCtor = defaultCtor;
  set copyCtor(CopyCtor copyCtor) => _copyCtor = copyCtor;
  set moveCtor(MoveCtor moveCtor) => _moveCtor = moveCtor;
  set assignCopy(AssignCopy assignCopy) => _assignCopy = assignCopy;
  set assignMove(AssignMove assignMove) => _assignMove = assignMove;
  set dtor(Dtor dtor) => _dtor = dtor;
  set opEqual(OpEqual opEqual) => _opEqual = opEqual;
  set opLess(OpLess opLess) => _opLess = opLess;
  set opOut(OpOut opOut) => _opOut = opOut;

  Iterable<Base> get basesPublic => bases.where((b) => b.access == public);
  Iterable<Base> get basesProtected => bases.where((b) => b.access == protected);
  Iterable<Base> get basesPrivate => bases.where((b) => b.access == private);

  set template(Object t) => _template = _makeTemplate(t);

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => b.decl))
    ..addAll(basesProtected.map((b) => b.decl))
    ..addAll(basesPrivate.map((b) => b.decl));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0?
    ' :\n' + indentBlock(_baseDecls.join(',\n')) : '';
  }

  CodeBlock getCodeBlock(ClassCodeBlock cb) {
    var result = _codeBlocks[cb];
    return (result == null) ?
      (_codeBlocks[cb] = codeBlock()) : result;
  }

  String get definition {
    if(_definition == null) {
      enums.forEach((e) => e.isNested = true);
      _methods.forEach((m) { if(m != null) m._parent = this; });
      memberCtors.forEach((m) { if(m != null) m._parent = this; });
      customBlocks.forEach((ClassCodeBlock cb) {
        getCodeBlock(cb).tag = '$cb $className';
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

  get _ctorMethods => [ _defaultCtor, _copyCtor, _moveCtor ];
  get _opMethods => [ _assignCopy, _assignMove, _dtor, _opEqual, _opLess, _opOut ];
  get _methods => []..addAll(_ctorMethods)..addAll(_opMethods);

  get _parts => [
    _forwardPtrs,
    enumsForward.map((e) => e.toString()).join('\n'),
    briefComment,
    detailedComment,
    _codeBlockText(clsPreDecl),
    _templateDecl,
    _classOpener,

    _wrapInAccess(public,
        indentBlock(
          combine([
            usings.map((u) => br('using $u;')),
            br([_enumDecls, _enumStreamers]),
            br(memberCtors.map((m) => m.definition)),
            br(_methods.map((m) => m == null? m : m.definition)),
            _codeBlockText(clsPublic),
            br(publicMembers.map((m) => _memberDefinition(m))),
            members.map((m) => br([m.getter, m.setter])),
            streamable? outStreamer : null
          ]))),

    _wrapInAccess(protected,
        indentBlock(
          combine([
            _codeBlockText(clsProtected),
            br(protectedMembers.map((m) => _memberDefinition(m)))
          ]))),

    _wrapInAccess(private,
        indentBlock(
          combine([
            _codeBlockText(clsPrivate),
            br(privateMembers.map((m) => _memberDefinition(m)))
          ]))),

    _classCloser,
    _codeBlockText(clsPostDecl),
  ];

  get _templateDecl => _template != null? _template.decl : null;
  get _enumDecls => enums.map((e) => e.decl);
  get _enumStreamers => enums.map((e) => e.streamSupport);

  _wrapInAccess(CppAccess access, String txt) {
    return (txt != null && txt.length > 0)? '''
$access:
${txt}''' : null;
  }

  _codeBlockText(ClassCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null? codeBlock.toString() : null;
  }

  _memberDefinition(Member m) => m.toString();

  String get className => id.capSnake;

  get outStreamer => '''
  friend inline std::ostream& operator<<(std::ostream& out, $className const& item) {
    ${
members.map((m) => "out << '\\n' << ${quote(m.name + ':')} << item.${m.vname}").join(';\n    ')
};
    return out;
  }
''';

  get _classOpener => '''
$classStyle $className$_baseDecl
{''';
  get _classCloser => '};';

  get _forwardPtrs {
    if(forwardPtrs.length > 0) {
      final name = className;
      List<String> parts = ['class $name;'];
      for(var ptr in forwardPtrs) {
        parts.add('using ${name}_${ptrSuffix(ptr)} = ${ptrType(ptr, name)};');
      }
      return parts.join('\n');
    }
    return null;
  }

  // end <class Class>
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

Class
class_(Object id) =>
  new Class(id is Id? id : new Id(id));

const clsPublic = ClassCodeBlock.CLS_PUBLIC;
const clsProtected = ClassCodeBlock.CLS_PROTECTED;
const clsPrivate = ClassCodeBlock.CLS_PRIVATE;
const clsPreDecl = ClassCodeBlock.CLS_PRE_DECL;
const clsPostDecl = ClassCodeBlock.CLS_POST_DECL;

Template _makeTemplate(Object t) =>
  t is Iterable? new Template(t) :
  t is String? new Template([t]) :
  t as Template;

defaultCtor() => new DefaultCtor();
copyCtor() => new CopyCtor();
moveCtor() => new MoveCtor();
assignCopy() => new AssignCopy();
assignMove() =>  new AssignMove();
dtor() => new Dtor();
opEqual() => new OpEqual();
opLess() => new OpLess();
opOut() => new OpOut();


// end <part class>
