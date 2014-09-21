part of cpp_meta;

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);

  static get values => [
    IA,
    RO,
    RW
  ];

  final int value;

  const Access._(this.value);

  String toString() {
    switch(this) {
      case IA: return "IA";
      case RO: return "RO";
      case RW: return "RW";
    }
  }

  static Access fromString(String s) {
    switch(s) {
      case "IA": return IA;
      case "RO": return RO;
      case "RW": return RW;
    }
  }


}
// custom <part cpp_meta>
// end <part cpp_meta>

