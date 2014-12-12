part of ebisu_cpp.cpp;

class SerializationStyle implements Comparable<SerializationStyle> {
  static const JSON_SERIALIZATION = const SerializationStyle._(0);
  static const XML_SERIALIZATION = const SerializationStyle._(1);
  static const BINARY_SERIALIZATION = const SerializationStyle._(2);

  static get values => [
    JSON_SERIALIZATION,
    XML_SERIALIZATION,
    BINARY_SERIALIZATION
  ];

  final int value;

  int get hashCode => value;

  const SerializationStyle._(this.value);

  copy() => this;

  int compareTo(SerializationStyle other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case JSON_SERIALIZATION: return "JsonSerialization";
      case XML_SERIALIZATION: return "XmlSerialization";
      case BINARY_SERIALIZATION: return "BinarySerialization";
    }
    return null;
  }

  static SerializationStyle fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "JsonSerialization": return JSON_SERIALIZATION;
      case "XmlSerialization": return XML_SERIALIZATION;
      case "BinarySerialization": return BINARY_SERIALIZATION;
      default: return null;
    }
  }

}

abstract class Serializer {
  // custom <class Serializer>

  String serialize(Class cls);

  // end <class Serializer>
}

class Cereal
  implements Serializer {
  List<SerializationStyle> styles = [];
  // custom <class Cereal>

  Cereal(this.styles);

  static final _tag = const {
    SerializationStyle.JSON_SERIALIZATION : 'json',
    SerializationStyle.XML_SERIALIZATION : 'xml',
  };

  static final _styleToInput = const {
    SerializationStyle.JSON_SERIALIZATION : 'cereal::JSONInputArchive',
    SerializationStyle.XML_SERIALIZATION : 'cereal::XMLInputArchive',
  };

  static final _styleToOutput = const {
    SerializationStyle.JSON_SERIALIZATION : 'cereal::JSONOutputArchive',
    SerializationStyle.XML_SERIALIZATION : 'cereal::XMLOutputArchive',
  };

  String serialize(Class cls) {
    final parts = [];
    cls.members.forEach((Member m) {
      parts.add('  ar__(cereal::make_nvp("${m.name}", ${m.vname}));');
    });
    parts.add('}');

    styles.forEach((SerializationStyle style) {
      final id = idFromString(style.toString());
      parts.add('''

void serialize_to_${_tag[style]}(std::ostream & out__) {
  ${_styleToOutput[style]} ar__(out__);
  serialize(ar__);
}

void serialize_from_${_tag[style]}(std::istream & in__) {
  ${_styleToInput[style]} ar__ { in__ };
  serialize(ar__);
}
''');
    });

    return br([
      '''
template <class Archive>
void serialize(Archive &ar__) {''',
      parts.join('\n'),
    ]);
  }

  // end <class Cereal>
}
// custom <part serializer>

final json = SerializationStyle.JSON_SERIALIZATION;
final xml = SerializationStyle.XML_SERIALIZATION;
final binary = SerializationStyle.XML_SERIALIZATION;

Cereal cereal([ List<SerializationStyle> styles ]) {
  if(styles == null) styles = [ json ];
  return new Cereal(styles);
}

// end <part serializer>
