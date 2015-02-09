part of ebisu_cpp.cpp;

/// A c++ enumeration
class Enum extends Entity {
  /// Strings for the values of the enum
  List<String> get values => _values;
  /// String value, numeric value pairs
  Map<String, int> get valueMap => _valueMap;
  /// If true the enum is a class enum as opposed to "plain" enum
  bool isClass = false;
  /// If true adds from_c_str method
  bool hasFromCStr = false;
  /// If true adds to_c_str method
  bool hasToCStr = false;
  /// If true adds streaming support
  bool streamable = false;
  /// If true the values are powers of two for bit masking
  bool isMask = false;
  /// If true is nested in class and requires *friend* stream support
  bool isNested = false;
  // custom <class Enum>

  Enum(Id id) : super(id);

  set values(Iterable<String> values) {
    _values = new List<String>.from(values);
    if (_values.any((String v) =>
        !Id.isSnake(v))) throw 'For CppEnum($id) *values* must be snake case';
    _ids = _values.map((v) => new Id(v)).toList();
    _valueNames = _ids.map((id) => Id.capitalize(id.snake) + '_e').toList();
  }

  set valueMap(Map<String, int> valueMap) {
    values = valueMap.keys;
    _valueMap = valueMap;
  }

  String toString() {
    _checkRequirements();

    return combine([decl, streamSupport]);
  }

  String get streamSupport => combine([
    (streamable || hasToCStr) ? toCString : null,
    streamable ? outStreamer : null,
    hasFromCStr ? fromCString : null,
  ]);

  String get decl {
    String result;
    if (values != null) {
      if (values.any((String v) =>
          !Id.isSnake(v))) throw 'For CppEnum($id) *values* must snake case';
      if (isMask) {
        result = _makeMaskEnum();
      } else {
        result = _makeBasicEnum();
      }
    } else {
      result = _makeMapEnum();
    }
    return result;
  }

  String get name => id.capSnake;
  String get _classDecl => isClass ? 'class $name' : name;

  String get toCString => isMask ? _maskToCString : _generalToCString;
  String get _maskToCString => '';
  String get _friend => isNested ? 'friend ' : '';
  String get _generalToCString => '''
${_friend}inline char const* to_c_str($name e) {
  switch(e) {
${
  indentBlock(_valueNames.map((n) => 'case $name::$n: return ${quote(n)}').join(';\n'), '    ')
};
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
}
''';

  String _makeBasicEnum() {
    return '''
enum ${_classDecl} {
${indentBlock(_valueNames.join(',\n'))}
};''';
  }

  String _makeMaskEnum() {
    int i = 0;
    return '''
enum ${_classDecl} {
${indentBlock(_ids.map((id) => id.shout + ' = 1 << ${i++}').join(',\n'))}
};''';
  }

  String _makeMapEnum() {
    if (valueMap.keys.any((String v) => !Id.isSnake(
        v))) throw 'For CppEnum($id) *valueMap* must have snake case keys';
    return '''
enum ${_classDecl} {
${
  indentBlock(
    valueMap.keys.map((k) => new Id(k).shout + ' = ${valueMap[k]}').join(',\n'))
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

main() => print('goo');

// end <part enum>
