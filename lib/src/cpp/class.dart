part of ebisu_cpp.cpp;

class CodeBlocks implements Comparable<CodeBlocks> {
  static const CB_PUBLIC = const CodeBlocks._(0);
  static const CB_PROTECTED = const CodeBlocks._(1);
  static const CB_PRIVATE = const CodeBlocks._(2);
  static const CB_PRE_DECL = const CodeBlocks._(3);
  static const CB_POST_DECL = const CodeBlocks._(4);

  static get values => [
    CB_PUBLIC,
    CB_PROTECTED,
    CB_PRIVATE,
    CB_PRE_DECL,
    CB_POST_DECL
  ];

  final int value;

  int get hashCode => value;

  const CodeBlocks._(this.value);

  copy() => this;

  int compareTo(CodeBlocks other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case CB_PUBLIC: return "CbPublic";
      case CB_PROTECTED: return "CbProtected";
      case CB_PRIVATE: return "CbPrivate";
      case CB_PRE_DECL: return "CbPreDecl";
      case CB_POST_DECL: return "CbPostDecl";
    }
    return null;
  }

  static CodeBlocks fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "CbPublic": return CB_PUBLIC;
      case "CbProtected": return CB_PROTECTED;
      case "CbPrivate": return CB_PRIVATE;
      case "CbPreDecl": return CB_PRE_DECL;
      case "CbPostDecl": return CB_POST_DECL;
      default: return null;
    }
  }

}

class Class extends Entity {

  /// Is this definition a *struct*
  bool struct = false;
  List<String> basesPublic = [];
  List<String> basesPrivate = [];
  List<String> basesProtected = [];
  List<PtrType> forwardPtrs = [];
  List<Enum> enumsForward = [];
  List<Enum> enums = [];
  List<Member> members = [];
  List<Method> methods = [];
  Headers get headers => _headers;
  Headers get implHeaders => _implHeaders;
  List<CodeBlocks> customBlocks = [];
  Map<CodeBlocks, CodeBlock> get codeBlocks => _codeBlocks;

  // custom <class Class>

  Class(Id id) : super(id);

  String get classStyle => struct? 'struct' : 'class';

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => 'public $b'))
    ..addAll(basesProtected.map((b) => 'protected $b'))
    ..addAll(basesPrivate.map((b) => 'private $b'));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0?
    ' :\n' + indentBlock(_baseDecls.join(',\n')) : '';
  }

  CodeBlock getCodeBlock(CodeBlocks cb) {
    var result = _codeBlocks[cb];
    return (result == null) ?
      (_codeBlocks[cb] = codeBlock()) : result;
  }

  String get definition {
    if(_definition == null) {
      customBlocks.forEach((CodeBlocks cb) {
        getCodeBlock(cb)..tag = '$cb $className';
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

  get _parts => [
    _forwardPtrs,
    enumsForward.map((e) => e.toString()).join('\n'),
    briefComment,
    detailedComment,
    _classOpener,
    indentBlock(enums.map((e) => e.toString()).join('\n')),
    _operatorMethods,
    'public:',
    _codeBlockText(cbPublic),
    indentBlock(publicMembers.map((m) => _memberDefinition(m)).join('\n')),
    'protected:',
    _codeBlockText(cbProtected),
    indentBlock(protectedMembers.map((m) => _memberDefinition(m)).join('\n')),
    'private:',
    _codeBlockText(cbPrivate),
    indentBlock(privateMembers.map((m) => _memberDefinition(m)).join('\n')),
    _classCloser,
  ];

  _codeBlockText(CodeBlocks cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null? codeBlock.toString() : null;
  }

  _memberDefinition(Member m) => m.toString();

  get className => id.capSnake;
  get _classOpener => '''
$classStyle $className$_baseDecl
{
public:''';
  get _classCloser => '};';

  get _opEqual {
    return '''
bool operator==($className const& rhs) {
  return this == &rhs ||
    (${
members.map((m) => '${m.name} == rhs.${m.name}').join(' &&\n    ')
});
}''';
  }

  get _opLessThan {
    List pairs = [];
    pairs.addAll(members.map((m) => [ m.name, 'rhs.${m.name}' ]));
    return '''
bool operator<($className const& rhs) {
  return ${
pairs.map((p) => '${p[0]} != ${p[1]}? ${p[0]} < ${p[1]} : (').join('\n    ')
}
    false${pairs.map((_) => ')').join()};
}
''';
  }

  get _operatorMethods {
    List parts = [];
    if(methods.contains(equal)) {
      parts.add(indentBlock(_opEqual));
    }
    if(methods.contains(less)) {
      parts.add(indentBlock(_opLessThan));
    }
    return combine(parts);
  }

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

  _makeHeaders(Object h) =>
    h is Iterable? new Headers(h) :
    h is String? new Headers([h]) :
    h is Headers? h :
    throw 'Headers must be String, List<String> or Headers';

  set headers(Object h) => _headers = _makeHeaders(h);
  set implHeaders(Object h) => _implHeaders = _makeHeaders(h);

  // end <class Class>
  String _definition;
  Headers _headers;
  Headers _implHeaders;
  Map<CodeBlocks, CodeBlock> _codeBlocks = {};
}
// custom <part class>

// CppClass
// class_(Object id) =>
//   new CppClass(id is Id? id : new Id(id));

Class
class_(Object id) =>
  new Class(id is Id? id : new Id(id));

const cbPublic = CodeBlocks.CB_PUBLIC;
const cbProtected = CodeBlocks.CB_PROTECTED;
const cbPrivate = CodeBlocks.CB_PRIVATE;
const cbPreDecl = CodeBlocks.CB_PRE_DECL;
const cbPostDecl = CodeBlocks.CB_POST_DECL;


// end <part class>
