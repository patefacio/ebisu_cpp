library ebisu_cpp.cpp;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
// custom <additional imports>
// end <additional imports>

part 'src/cpp/utils.dart';
part 'src/cpp/file.dart';
part 'src/cpp/enum.dart';
part 'src/cpp/member.dart';
part 'src/cpp/class.dart';

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access implements Comparable<Access> {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);
  static const WO = const Access._(3);

  static get values => [
    IA,
    RO,
    RW,
    WO
  ];

  final int value;

  int get hashCode => value;

  const Access._(this.value);

  copy() => this;

  int compareTo(Access other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case IA: return "Ia";
      case RO: return "Ro";
      case RW: return "Rw";
      case WO: return "Wo";
    }
    return null;
  }

  static Access fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Ia": return IA;
      case "Ro": return RO;
      case "Rw": return RW;
      case "Wo": return WO;
      default: return null;
    }
  }

}

/// Cpp access
class CppAccess implements Comparable<CppAccess> {
  static const PUBLIC = const CppAccess._(0);
  static const PRIVATE = const CppAccess._(1);
  static const PROTECTED = const CppAccess._(2);

  static get values => [
    PUBLIC,
    PRIVATE,
    PROTECTED
  ];

  final int value;

  int get hashCode => value;

  const CppAccess._(this.value);

  copy() => this;

  int compareTo(CppAccess other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case PUBLIC: return "Public";
      case PRIVATE: return "Private";
      case PROTECTED: return "Protected";
    }
    return null;
  }

  static CppAccess fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Public": return PUBLIC;
      case "Private": return PRIVATE;
      case "Protected": return PROTECTED;
      default: return null;
    }
  }

}

/// Reference type
class RefType implements Comparable<RefType> {
  static const REF = const RefType._(0);
  static const CREF = const RefType._(1);
  static const VREF = const RefType._(2);
  static const CVREF = const RefType._(3);
  static const VALUE = const RefType._(4);

  static get values => [
    REF,
    CREF,
    VREF,
    CVREF,
    VALUE
  ];

  final int value;

  int get hashCode => value;

  const RefType._(this.value);

  copy() => this;

  int compareTo(RefType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case REF: return "Ref";
      case CREF: return "Cref";
      case VREF: return "Vref";
      case CVREF: return "Cvref";
      case VALUE: return "Value";
    }
    return null;
  }

  static RefType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Ref": return REF;
      case "Cref": return CREF;
      case "Vref": return VREF;
      case "Cvref": return CVREF;
      case "Value": return VALUE;
      default: return null;
    }
  }

}

/// Standard pointer type declaration
class PtrType implements Comparable<PtrType> {
  static const SPTR = const PtrType._(0);
  static const UPTR = const PtrType._(1);
  static const SCPTR = const PtrType._(2);
  static const UCPTR = const PtrType._(3);

  static get values => [
    SPTR,
    UPTR,
    SCPTR,
    UCPTR
  ];

  final int value;

  int get hashCode => value;

  const PtrType._(this.value);

  copy() => this;

  int compareTo(PtrType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case SPTR: return "Sptr";
      case UPTR: return "Uptr";
      case SCPTR: return "Scptr";
      case UCPTR: return "Ucptr";
    }
    return null;
  }

  static PtrType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Sptr": return SPTR;
      case "Uptr": return UPTR;
      case "Scptr": return SCPTR;
      case "Ucptr": return UCPTR;
      default: return null;
    }
  }

}

class Entity {

  Entity(this.id);

  /// Id for the entity
  Id id;
  /// Brief description for the entity
  String brief;
  /// Description of entity
  String descr;

  // custom <class Entity>

  String get briefComment => brief != null? '//! $brief' : null;
  String get detailedComment => descr != null?
    blockComment(descr) : null;

  // end <class Entity>
}

// custom <library cpp>

const ia = Access.IA;
const ro = Access.RO;
const rw = Access.RW;
const wo = Access.WO;

const public = CppAccess.PUBLIC;
const private = CppAccess.PRIVATE;
const protected = CppAccess.PROTECTED;

const ref = RefType.REF;
const cref = RefType.CREF;
const vref = RefType.VREF;
const cvref = RefType.CVREF;
const value = RefType.VALUE;

const sptr = PtrType.SPTR;
const uptr = PtrType.UPTR;
const scptr = PtrType.SCPTR;
const ucptr = PtrType.UCPTR;

const Map _ptrSuffixMap = const {
  sptr : 'sptr',
  uptr : 'uptr',
  scptr : 'scptr',
  ucptr : 'ucptr',
};

ptrSuffix(PtrType ptrType) => _ptrSuffixMap[ptrType];

Map _ptrStdTypeMap = {
  sptr : (String T) => 'shared_ptr< $T >',
  uptr : (String T) => 'unique_ptr< $T >',
  scptr : (String T) => 'shared_ptr< const $T >',
  ucptr : (String T) => 'unique_ptr< const $T >',
};

ptrType(PtrType ptrType, String t) =>
  _ptrStdTypeMap[ptrType](t);

String combine(List<String> parts) =>
  parts
  .where((String s) => s != null && s.length > 0)
  .join('\n');

String quote(String s) => '"$s"';

// end <library cpp>
