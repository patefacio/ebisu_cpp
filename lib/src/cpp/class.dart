part of ebisu_cpp.cpp;

class Class extends Entity {

  /// Is this definition a *struct*
  bool struct = false;
  List<String> basesPublic = [];
  List<String> basesPrivate = [];
  List<String> basesProtected = [];
  List<PtrType> forwardPtrs = [];
  List<Enum> enumsForward = [];
  List<Enum> enums = [];
  Headers get headers => _headers;
  Headers get implHeaders => _implHeaders;

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
    ' :\n' + indentBlock(_baseDecls.join(',\n')) + ' {' : '';
  }

  String get definition => combine(_parts);

  get _parts => [
    _forwardPtrs,
    enumsForward.map((e) => e.toString()).join('\n'),
    briefComment,
    detailedComment,
    _classOpener,
    indentBlock(enums.map((e) => e.toString()).join('\n')),
    _classCloser,
  ];

  get className => id.capCamel;
  get _classOpener => '$classStyle $className$_baseDecl';
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

  _makeHeaders(Object h) =>
    h is Iterable? new Headers(h) :
    h is String? new Headers([h]) :
    h is Headers? h :
    throw 'Headers must be String, List<String> or Headers';

  set headers(Object h) => _headers = _makeHeaders(h);
  set implHeaders(Object h) => _implHeaders = _makeHeaders(h);

  // end <class Class>
  Headers _headers;
  Headers _implHeaders;
}
// custom <part class>

// CppClass
// class_(Object id) =>
//   new CppClass(id is Id? id : new Id(id));

Class
class_(Object id) =>
  new Class(id is Id? id : new Id(id));

// end <part class>
