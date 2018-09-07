part of ebisu_cpp.ebisu_cpp;

/// Serialization using *cereal* supports these types of serialization
enum SerializationStyle {
  jsonSerialization,
  xmlSerialization,
  binarySerialization
}

/// Convenient access to SerializationStyle.jsonSerialization with *jsonSerialization* see [SerializationStyle].
///
const SerializationStyle jsonSerialization =
    SerializationStyle.jsonSerialization;

/// Convenient access to SerializationStyle.xmlSerialization with *xmlSerialization* see [SerializationStyle].
///
const SerializationStyle xmlSerialization = SerializationStyle.xmlSerialization;

/// Convenient access to SerializationStyle.binarySerialization with *binarySerialization* see [SerializationStyle].
///
const SerializationStyle binarySerialization =
    SerializationStyle.binarySerialization;

/// Establishes an interface for instance serialization
abstract class Serializer {
  // custom <class Serializer>

  String serialize(Class cls);

  // end <class Serializer>

}

/// Provides support for serialization as *delimited separated values*
class DsvSerializer implements Serializer {
  String delimiter = ':';

  // custom <class DsvSerializer>

  DsvSerializer(this.delimiter);

  String serialize(Class cls) {
    return '''
${_out(cls)}
${cls.isImmutable ? _immutableIn(cls) : _in(cls)}
''';
    //TODO: add back
  }

  String _outMember(Member m) =>
      m.type == 'Timestamp_t' ? 'ebisu::timestamp::ticks(${m.vname})' : m.vname;

  String _out(Class cls) => '''
std::string serialize_to_dsv() const {
  fmt::MemoryWriter w__;
${indentBlock(br([
        'w__ ',
        cls.members
            .map((Member m) => "<< ${_outMember(m)} ")
            .join("<< '$delimiter'"),
        ';'
      ]))}
  return w__.str();
}
''';

  String _castMember(Member m) => m.type == 'Timestamp_t'
      ? '''
if(!ebisu::timestamp::convert_to_timestamp_from_ticks(*it__, ${m.vname})) {
  std::string msg { "Encountered invalid timestamp ticks:" };
  msg += *it__;
  throw std::logic_error(msg);
}
'''
      : m.isSerializedAsInt
          ? '${m.vname} = ${m.type}(lexical_cast<int>(*it__));'
          : '${m.vname} = lexical_cast<${m.type}>(*it__);';

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

${indentBlock(br([cls.members.map((Member m) => _readToken(cls, m))]))}
}
''';

  String _immutableIn(Class cls) => '''
static ${cls.className} serialize_from_dsv(std::string const& tuple__) {
  using namespace boost;
  char_separator<char> const sep__{"$delimiter"};
  tokenizer<char_separator<char> > tokens__(tuple__, sep__);
  tokenizer<boost::char_separator<char> >::iterator it__{tokens__.begin()};

${indentBlock(br(cls.members.map((Member m) => '${m.type} ${m.vname};')))}

${indentBlock(br([cls.members.map((Member m) => _readToken(cls, m))]))}

return ${cls.className}(${cls.members.map((Member m) => m.vname).join(', ')});
}
''';

  // end <class DsvSerializer>

}

/// Adds support for serialization using *cereal*
class Cereal implements Serializer {
  List<SerializationStyle> styles = [];

  // custom <class Cereal>

  Cereal(this.styles);

  static final _tag = const {
    jsonSerialization: 'json',
    xmlSerialization: 'xml',
  };

  static final _styleToInput = const {
    jsonSerialization: 'cereal::JSONInputArchive',
    xmlSerialization: 'cereal::XMLInputArchive',
  };

  static final _styleToOutput = const {
    jsonSerialization: 'cereal::JSONOutputArchive',
    xmlSerialization: 'cereal::XMLOutputArchive',
  };

  String serialize(Class cls) {
    final parts = [];
    cls.members.where((m) => !m.isCerealTransient).forEach((Member m) {
      parts.add('  ar__(cereal::make_nvp("${m.name}", ${m.vname}));');
    });
    parts.add('}');

    styles.forEach((SerializationStyle style) {
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

final json = jsonSerialization;
final xml = xmlSerialization;
final binary = binarySerialization;

Cereal cereal([List<SerializationStyle> styles]) {
  if (styles == null) styles = [json];
  return new Cereal(styles);
}

DsvSerializer dsv([String delimiter = ':']) {
  assert(delimiter.length == 1);
  return new DsvSerializer(delimiter);
}

// end <part serializer>
