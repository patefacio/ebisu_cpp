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

class DsvSerializer
  implements Serializer {
  String delimiter = ':';
  // custom <class DsvSerializer>

  DsvSerializer(this.delimiter);

  String serialize(Class cls) {
    return '''
${_out(cls)}
${cls.immutable? _immutableIn(cls) : _in(cls)}
''';
    //TODO: add back
  }

  String _outMember(Member m) =>
    m.type == 'Timestamp_t'? 'fcs::timestamp::ticks(${m.vname})' : m.vname;


  String _out(Class cls) => '''
std::string serialize_to_dsv() const {
  fmt::MemoryWriter w__;
${
indentBlock(
  br([ 'w__ ',
       cls
         .members
         .map((Member m) => "<< ${_outMember(m)} ")
         .join("<< '$delimiter'"),
       ';']))
}
  return w__.str();
}
''';

  String _castMember(Member m) =>
    m.type == 'Timestamp_t'?
    '''
if(!fcs::timestamp::convert_to_timestamp_from_ticks(*it__, ${m.vname})) {
  std::string msg { "Encountered invalid timestamp ticks:" };
  msg += *it__;
  throw std::logic_error(msg);
}
''' :
    m.serializeInt? '${m.vname} = ${m.type}(lexical_cast<int>(*it__));' :
    '${m.vname} = lexical_cast<${m.type}>(*it__);';


  String _readToken(Class cls, Member m) => '''
if(it__ != tokens__.end()) {
${indentBlock(_castMember(m))}
  ++it__;
} else {
  throw std::logic_error("Tokenize ${cls.className} failed: expected ${m.vname}");
}
''';

  String _in(Class cls) => '''
void serialize_from_dsv(std::string const& tuple__) {
  using namespace boost;
  char_separator<char> const sep__{"$delimiter"};
  tokenizer<char_separator<char> > tokens__(tuple__, sep__);
  tokenizer<boost::char_separator<char> >::iterator it__{tokens__.begin()};

${
indentBlock(
  br([
       cls
         .members
         .map((Member m) => _readToken(cls, m))
     ]))
}
}
''';

  String _immutableIn(Class cls) => '''
static ${cls.className} serialize_from_dsv(std::string const& tuple__) {
  using namespace boost;
  char_separator<char> const sep__{"$delimiter"};
  tokenizer<char_separator<char> > tokens__(tuple__, sep__);
  tokenizer<boost::char_separator<char> >::iterator it__{tokens__.begin()};

${
indentBlock(
  br(cls.members.map((Member m) => '${m.type} ${m.vname};')))
}

${
indentBlock(
  br([
       cls
         .members
         .map((Member m) => _readToken(cls, m))
     ]))
}

return ${cls.className}(${cls.members.map((Member m) => m.vname).join(', ')});
}
''';


  // end <class DsvSerializer>
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
    cls
      .members
      .where((m) => !m.cerealTransient)
      .forEach((Member m) {
      parts.add('  ar__(cereal::make_nvp("${m.name}", ${m.vname}));');
    });
    parts.add('}');

    styles.forEach((SerializationStyle style) {
      final id = idFromString(style.toString());
      parts.add('''

void serialize_to_${_tag[style]}(std::ostream & out__) const {
  ${_styleToOutput[style]} ar__(out__);
  const_cast<${cls.className}*>(this)->serialize(ar__);
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

DsvSerializer dsv([ String delimiter = ':' ]) {
  assert(delimiter.length == 1);
  return new DsvSerializer(delimiter);
}

// end <part serializer>
