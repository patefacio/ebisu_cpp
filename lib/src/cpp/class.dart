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

class Class extends Entity {

  /// Is this definition a *struct*
  bool struct = false;
  List<Base> bases = [];
  List<PtrType> forwardPtrs = [];
  List<Enum> enumsForward = [];
  List<Enum> enums = [];
  List<Member> members = [];
  List<Method> methods = [];
  Headers get headers => _headers;
  Headers get implHeaders => _implHeaders;
  List<ClassCodeBlock> customBlocks = [];
  Map<ClassCodeBlock, CodeBlock> get codeBlocks => _codeBlocks;
  /// If true adds streaming support
  bool streamable = false;

  // custom <class Class>

  Class(Id id) : super(id);

  String get classStyle => struct? 'struct' : 'class';

  Iterable<Base> get basesPublic => bases.where((b) => b.access == public);
  Iterable<Base> get basesProtected => bases.where((b) => b.access == protected);
  Iterable<Base> get basesPrivate => bases.where((b) => b.access == private);

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
      customBlocks.forEach((ClassCodeBlock cb) {
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
    indentBlock(combine(_enumDecls)),
    indentBlock(combine(_enumStreamers)),
    _operatorMethods,
    _wrapInAccess(public,
        combine([
          _codeBlockText(clsPublic),
          indentBlock(publicMembers.map((m) => _memberDefinition(m)).join('\n')),
          streamable? outStreamer : null])),
    _wrapInAccess(protected,
        combine([
          _codeBlockText(clsProtected),
          indentBlock(protectedMembers.map((m) => _memberDefinition(m)).join('\n'))])),
    _wrapInAccess(private,
        combine([
          _codeBlockText(clsPrivate),
          indentBlock(privateMembers.map((m) => _memberDefinition(m)).join('\n'))])),
    _classCloser,
  ];

  get _enumDecls => enums.map((e) => e.decl);
  get _enumStreamers => enums.map((e) => e.streamSupport);

  _wrapInAccess(CppAccess access, String txt) {
    return (txt != null && txt.length > 0)? '''
$access:
${txt}
''' : null;
  }

  _codeBlockText(ClassCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null? codeBlock.toString() : null;
  }

  _memberDefinition(Member m) => m.toString();

  get className => id.capSnake;

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
{
''';
  get _classCloser => '};';

  get _opEqual {
    return '''
bool operator==($className const& rhs) {
  return this == &rhs ||
    (${
members.map((m) => '${m.vname} == rhs.${m.vname}').join(' &&\n    ')
});
}''';
  }

  get _opLessThan {
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


// end <part class>
