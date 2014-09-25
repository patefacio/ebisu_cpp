part of ebisu_cpp.cpp;

class CppClass extends Entity {

  /// Is this definition a *struct*
  bool struct = false;
  List<String> basesPublic = [];
  List<String> basesPrivate = [];
  List<String> basesProtected = [];
  List<PtrType> forwardPtrs = [];
  List<CppEnum> forwardEnums = [];
  List<CppEnum> enums = [];

  // custom <class CppClass>

  CppClass(Id id) : super(id);

  String get classStyle => struct? 'struct' : 'class';

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => 'public $b'))
    ..addAll(basesProtected.map((b) => 'protected $b'))
    ..addAll(basesPrivate.map((b) => 'private $b'));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0?
    ' :\n' + indentBlock(_baseDecls.join(',\n')) + '\n{' : '';
  }

  String get definition => combine(_parts);

  get _parts => [
    _forwardPtrs,
    forwardEnums.map((e) => e.toString()).join('\n'),
    briefComment,
    detailedComment,
    _classOpener,
    indentBlock(enums.map((e) => defineEnum(e)).join('\n')),
    _classCloser,
  ];

  String defineEnum(CppEnum e) =>
    combine([
      e.decl,
      e.hasToCStr ? 'friend\n' + e.toCString : null,
      e.hasToCStr ? 'friend\n' + e.outStreamer : null,
      e.hasFromCStr ? 'friend\n' + e.fromCString : null
    ]);

  get className => id.capCamel;
  get _classOpener => '''
$classStyle $className$_baseDecl
public:''';
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


  // end <class CppClass>
}
// custom <part class>

CppClass
cppClass(Object id) =>
  new CppClass(id is Id? id : new Id(id));

// end <part class>
