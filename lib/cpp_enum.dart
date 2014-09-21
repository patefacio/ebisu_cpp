library ebisu_cpp.cpp_enum;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
// custom <additional imports>
// end <additional imports>

class CppEnum {

  CppEnum(this.id);

  /// Id for the enumeration
  Id id;
  /// Brief description for the enum
  String brief;
  /// Strings for the values of the enum
  List<String> values;
  /// String value, numeric value pairs
  Map<String, int> valueMap;
  /// If true the enum is a class enum as opposed to "plain" enum
  bool isClass = false;
  /// If true adds methods to go from string (i.e. picklist representation)
  /// back to enum
  bool supportsPicklist = false;
  /// If true the values are powers of two for bit masking
  bool isMask = false;

  // custom <class CppEnum>

  String toString() {
    _checkRequirements();
    if(values != null) {
      if(values.any((String v) => !Id.isSnake(v)))
        errors.add('For CppEnum($id) *values* must snake case');
      if(isMask) {
        return _makeMaskEnum();
      } else {
        return _makeBasicEnum();
      }
    } else {
      return _makeMapEnum();
    }
  }

  String get _classDecl => isClass? 'class ${id.capCamel}' : id.capCamel;

  String _makeBasicEnum() {
    List<Id> valueIds = values.map((String v) => new Id(v)).toList();
    return '''
enum ${_classDecl} {
${indentBlock(valueIds.map((id) => id.shout).join(',\n'))}
};''';
  }

  String _makeMaskEnum() {
    List<Id> valueIds = values.map((String v) => new Id(v)).toList();
    int i = 0;
    return '''
enum ${_classDecl} {
${indentBlock(valueIds.map((id) => id.shout + ' = 1 << ${i++}').join(',\n'))}
};''';
  }

  String _makeMapEnum() {
    if(valueMap.keys.any((String v) => !Id.isSnake(v)))
      errors.add('For CppEnum($id) *valueMap* must have snake case keys');
    return '''
enum ${_classDecl} {
${
  indentBlock(
    valueMap.keys.map((k) => new Id(k).shout + ' = ${valueMap[k]}').join(',\n'))
}
};''';
  }

  _checkRequirements() {
    if(values == null && valueMap == null)
      throw 'For CppEnum($id) *values* or *valueMap* must be set';

    if(values != null && valueMap != null)
      throw 'For CppEnum($id) one of *values* or *valueMap* can be set';
  }

  // end <class CppEnum>
}

// custom <library cpp_enum>

CppEnum
cppEnum([Object id]) =>
  new CppEnum(id is Id? id : new Id(id));

// end <library cpp_enum>
