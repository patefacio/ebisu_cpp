part of ebisu_cpp.ebisu_cpp;

/// A c++ enumeration.
///
/// There are two main styles of enumerations, *standard* and
/// *mask*.
///
/// Enumerations are often used to establish values to be used in
/// masks. The actual manipulation with masks is done in the *int* space,
/// but enums are convenient for setting up the mask values:
///
///       print(enum_('gl_buffer')
///           ..values = [ 'gl_color_buffer', 'gl_depth_buffer',
///             'gl_accum_buffer', 'gl_stencil_buffer' ]
///           ..isMask = true);
///
/// will print:
///
///     enum Gl_buffer {
///       Gl_color_buffer_e = 1 << 0,
///       Gl_depth_buffer_e = 1 << 1,
///       Gl_accum_buffer_e = 1 << 2,
///       Gl_stencil_buffer_e = 1 << 3
///     };
///
/// The *values* for enumeration entries can be ignored when their only
/// purpose is to draw distinction:
///
///     print(enum_('region')..values = ['north', 'south', 'east', 'west']);
///
/// will print:
///
///     enum Region {
///       North_e,
///       South_e,
///       East_e,
///       West_e
///     };
///
/// Sometimes it is important not only to distinguish, but also to assign
/// values. For this purpose the values associated with the entries may be
/// provided via the [valueMap]
///
///     print(enum_('thresholds')
///           ..valueMap = { 'high' : 100, 'medium' : 50, 'low' : 10 });
///
/// gives:
///
///     enum Thresholds {
///       High_e = 100,
///       Medium_e = 50,
///       Low_e = 10
///     };
///
/// Optionally the [isClass] field can be set to improve scoping by making
/// the enum a *class* enum.
///
///     print(enum_('color_as_class')
///           ..values = ['red', 'green', 'blue']
///           ..isClass = true);
///
/// gives:
///
///     enum class Color_as_class {
///       Red_e,
///       Green_e,
///       Blue_e
///     };
///
/// Optionally the [enumBase] can be used to specify the
/// base type. This is particularly useful where the enum
/// is a field in a *packed* structure.
///
///     print(enum_('color_with_base')
///           ..values = ['red', 'green', 'blue']
///           ..enumBase = 'std::int8_t');
///
/// gives:
///
///     enum Color_with_base : std::int8_t {
///       Red_e,
///       Green_e,
///       Blue_e
///     };
///
/// [isClass] may be combined with [enumBase].
///
/// The [isStreamable] flag will provide *to_c_str* and *operator<<* methods:
///
///     print(enum_('color')
///           ..values = ['red', 'green', 'blue']
///           ..enumBase = 'std::int8_t'
///           ..isStreamable = true
///           );
///
/// gives:
///
///     enum class Color : std::int8_t {
///       Red_e,
///       Green_e,
///       Blue_e
///     };
///     inline char const* to_c_str(Color e) {
///       switch(e) {
///         case Color::Red_e: return "Red_e";
///         case Color::Green_e: return "Green_e";
///         case Color::Blue_e: return "Blue_e";
///       }
///     }
///     inline std::ostream& operator<<(std::ostream &out, Color e) {
///       return out << to_c_str(e);
///     }
///
/// For the *standard* style enum you can use the [hasFromCStr] to include
/// a c-string to enum conversion method:
///
///     inline void from_c_str(char const* str, Color &e) {
///       using namespace std;
///       if(0 == strcmp("Red_e", str)) { e = Color::Red_e; return; }
///       if(0 == strcmp("Green_e", str)) { e = Color::Green_e; return; }
///       if(0 == strcmp("Blue_e", str)) { e = Color::Blue_e; return; }
///       string msg { "No Color matching:" };
///       throw std::runtime_error(msg + str);
///     }
///
class Enum extends Entity {

  /// Strings for the values of the enum
  List<String> get values => _values;
  /// String value, numeric value pairs
  Map<String, int> get valueMap => _valueMap;
  /// If true the enum is a class enum as opposed to "plain" enum
  bool isClass = false;
  /// Base of enum - if set must be an integral type
  String enumBase;
  /// If true adds from_c_str method
  bool hasFromCStr = false;
  /// If true adds to_c_str method
  bool hasToCStr = false;
  /// If true adds streaming support
  bool isStreamable = false;
  /// If true the values are powers of two for bit masking
  bool isMask = false;
  /// If true is nested in class and requires *friend* stream support
  bool isNested = false;
  /// If the map has values assigned by user, this can be used to display
  /// them in the enum as hex
  bool isDisplayedHex = false;

  // custom <class Enum>

  Enum(Id id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  get includes => hasToCStr
      ? new Includes(['iosfwd', 'sstream', 'stdexcept', 'cstring'])
      : new Includes();

  set values(Iterable<String> values) {
    _values = new List<String>.from(values);
    if (_values.any((String v) =>
        !Id.isSnake(v))) throw 'For CppEnum($id) *values* must be snake case';
    _ids = _values.map((v) => new Id(v)).toList();
    _valueNames = _ids.map((id) => namer.nameEnumConst(id)).toList();
  }

  set valueMap(Map<String, int> valueMap) {
    values = valueMap.keys;
    _valueMap = valueMap;
  }

  String toString() {
    _checkRequirements();
    return br([decl, streamSupport]);
  }

  get streamSupport => br([
    (isStreamable || hasToCStr) ? toCString : null,
    isStreamable ? outStreamer : null,
    hasFromCStr ? fromCString : null,
  ]);

  /// The enum declaration string
  get decl => isMask
      ? _makeMaskEnum()
      : valueMap != null ? _makeMapEnum() : _makeBasicEnum();

  /// The C++ name as provided by the namer
  get name => namer.nameEnum(id);

  /// Text for a ..._to_c_str method
  get toCString => isMask ? _maskToCString : _generalToCString;

  get _classDecl => isClass ? 'class $name' : name;
  get _intType => enumBase != null ? enumBase : 'int';

  /// Masks are printed as a list of entries that are set
  ///
  ///
  get _maskToCString => '''
${_friend}inline char const* ${name}_mask_to_c_str($_intType e) {
  std::ostringstream out__;
  out__ << '[';
${
  indentBlock(_valueNames.map((n) =>
    'if(e & $_intType($name::$n)) { out__ << "$name::$n, ";}')
  .join('\n'))
}
  out__ << ']';
  return out__.str().c_str();
}
$_generalToCString''';

  String get _friend => isNested ? 'friend ' : '';
  String get _generalToCString => '''
${_friend}inline char const* to_c_str($name e) {
  switch(e) {
${
  indentBlock(_valueNames.map((n) => 'case $name::$n: return ${quote(n)}').join(';\n'), '    ')
};
    default: {
      std::ostringstream msg;
      msg << "to_c_str($name) encountered invalid value:" << $_intType(e);
      throw std::logic_error(msg.str());
    }
  }
}''';

  String get outStreamer => '''
${_friend}inline std::ostream& operator<<(std::ostream &out, $name e) {
  return out << to_c_str(e);
}''';

  String get fromCString => isMask ? _maskFromCString : _generalFromCString;
  String get _maskFromCString => '';
  String get _generalFromCString => !hasFromCStr
      ? null
      : '''
inline void from_c_str(char const* str, $name &e) {
  using namespace std;
${
  indentBlock(_valueNames.map((n) => 'if(0 == strcmp(${quote(n)}, str)) { e = $name::$n; return; }').join('\n'))
}
  string msg { "No $name matching:" };
  throw std::runtime_error(msg + str);
}''';

  get _enumHead =>
      'enum $_classDecl' + (enumBase != null ? ' : $enumBase' : '');

  String _makeBasicEnum() => '''
$_enumHead {
${indentBlock(_valueNames.join(',\n'))}
};''';

  String _makeMaskEnum() {
    int i = 0;
    return '''
$_enumHead {
${indentBlock(_valueNames.map((n) => n + ' = 1 << ${i++}').join(',\n'))}
};''';
  }

  get _maxValue => max(valueMap.values);
  get _padWidth => (log(_maxValue) / log(2)).ceil() ~/ 4;

  _enumDisplayValue(v) =>
      isDisplayedHex ? '0x' + v.toRadixString(16).padLeft(_padWidth, '0') : v;

  String _makeMapEnum() {
    if (valueMap.keys.any((String v) => !Id.isSnake(
        v))) throw 'For CppEnum($id) *valueMap* must have snake case keys';
    return '''
$_enumHead {
${
  indentBlock(
    valueMap.keys.map((k) =>
      namer.nameEnumConst(idFromString(k)) +
        ' = ${_enumDisplayValue(valueMap[k])}').join(',\n'))
}
};''';
  }

  _checkRequirements() {
    if (values == null &&
        valueMap ==
            null) throw 'For CppEnum($id) *values* or *valueMap* must be set';
  }

  // end <class Enum>

  List<String> _values;
  /// Ids for the values of the enum
  List<Id> _ids;
  /// Names for values as they appear
  List<String> _valueNames;
  Map<String, int> _valueMap;
}

// custom <part enum>

Enum enum_(Object id) => new Enum(id is Id ? id : new Id(id));

// end <part enum>
