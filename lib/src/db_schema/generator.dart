part of ebisu_cpp.db_schema;

class BindDataType implements Comparable<BindDataType> {
  static const BDT_INT = const BindDataType._(0);
  static const BDT_SHORT = const BindDataType._(1);
  static const BDT_DOUBLE = const BindDataType._(2);
  static const BDT_BIGINT = const BindDataType._(3);
  static const BDT_SIZED_CHAR = const BindDataType._(4);
  static const BDT_UNSIZED_CHAR = const BindDataType._(5);
  static const BDT_VARCHAR_LONG = const BindDataType._(6);
  static const BDT_TIMESTAMP = const BindDataType._(7);

  static get values => [
    BDT_INT,
    BDT_SHORT,
    BDT_DOUBLE,
    BDT_BIGINT,
    BDT_SIZED_CHAR,
    BDT_UNSIZED_CHAR,
    BDT_VARCHAR_LONG,
    BDT_TIMESTAMP
  ];

  final int value;

  int get hashCode => value;

  const BindDataType._(this.value);

  copy() => this;

  int compareTo(BindDataType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case BDT_INT: return "BdtInt";
      case BDT_SHORT: return "BdtShort";
      case BDT_DOUBLE: return "BdtDouble";
      case BDT_BIGINT: return "BdtBigint";
      case BDT_SIZED_CHAR: return "BdtSizedChar";
      case BDT_UNSIZED_CHAR: return "BdtUnsizedChar";
      case BDT_VARCHAR_LONG: return "BdtVarcharLong";
      case BDT_TIMESTAMP: return "BdtTimestamp";
    }
    return null;
  }

  static BindDataType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "BdtInt": return BDT_INT;
      case "BdtShort": return BDT_SHORT;
      case "BdtDouble": return BDT_DOUBLE;
      case "BdtBigint": return BDT_BIGINT;
      case "BdtSizedChar": return BDT_SIZED_CHAR;
      case "BdtUnsizedChar": return BDT_UNSIZED_CHAR;
      case "BdtVarcharLong": return BDT_VARCHAR_LONG;
      case "BdtTimestamp": return BDT_TIMESTAMP;
      default: return null;
    }
  }

}

const BDT_INT = BindDataType.BDT_INT;
const BDT_SHORT = BindDataType.BDT_SHORT;
const BDT_DOUBLE = BindDataType.BDT_DOUBLE;
const BDT_BIGINT = BindDataType.BDT_BIGINT;
const BDT_SIZED_CHAR = BindDataType.BDT_SIZED_CHAR;
const BDT_UNSIZED_CHAR = BindDataType.BDT_UNSIZED_CHAR;
const BDT_VARCHAR_LONG = BindDataType.BDT_VARCHAR_LONG;
const BDT_TIMESTAMP = BindDataType.BDT_TIMESTAMP;

class OtlBindVariable {

  String name;
  BindDataType dataType;
  int size = 0;

  // custom <class OtlBindVariable>

  OtlBindVariable.fromDataType(this.name, DataType cppDataType) {
    dataType = cppTypeMapping[cppDataType];
    if(dataType == null) {
      if(cppDataType is FixedVarchar) {
        dataType = BDT_SIZED_CHAR;
        size = cppDataType.size;
      } else {
        throw 'DataType $cppDataType which is a ${dataType.runtimeType} has no mapping';
      }
    }
  }

  toString() => dataType == BDT_SIZED_CHAR?
    ':$name<char[$size]>' : ':$name<${typeMapping[dataType]}>';

  static Map<BindDataType, String> typeMapping = {
    BDT_INT : 'int',
    BDT_SHORT : 'short',
    BDT_DOUBLE : 'double',
    BDT_BIGINT : 'bigint',
    BDT_UNSIZED_CHAR : 'char[]',
    BDT_VARCHAR_LONG : 'varchar_long',
    BDT_TIMESTAMP : 'timestamp',
  };

  static Map<DataType, BindDataType> cppTypeMapping = {
    Int : BDT_INT,
    TinyInt : BDT_SHORT,
    SmallInt : BDT_SHORT,
    BigInt : BDT_BIGINT,
    Time : BDT_TIMESTAMP,
    Timestamp : BDT_TIMESTAMP,
    DateTime : BDT_TIMESTAMP,
    Date : BDT_TIMESTAMP,
    Text : BDT_VARCHAR_LONG,
    VarChar : BDT_VARCHAR_LONG,
    Double : BDT_DOUBLE,
  };

  // end <class OtlBindVariable>
}

/// Given a schema generates code to support accessing tables and configured
/// queries. Makes use of the otl c++ library.
///
class SchemaCodeGenerator extends Object with InstallationCodeGenerator {

  Schema schema;
  List<Query> queries = [];
  TableFilter tableFilter = (Table t) => true;

  // custom <class SchemaCodeGenerator>

  SchemaCodeGenerator(this.schema);

  get tables => schema.tables.where((t) => tableFilter(t));

  void generate() {
    tables.forEach((Table t) {
      final tgg = new TableGatewayGenerator(schema, t);
      tgg.header
        ..setFilePathFromRoot(installation.cppPath)
        ..generate();
    });
  }

  // end <class SchemaCodeGenerator>
}

class TableGatewayGenerator {

  Schema schema;
  Table table;
  Id tableId;
  String tableName;

  // custom <class TableGatewayGenerator>

  TableGatewayGenerator(this.schema, this.table) {
    tableId = idFromString(table.name);
    tableName = tableId.snake;
  }

  _makeMember(c) =>
    member(c.name)
    ..cppAccess = public
    ..type = c.cppType
    ..noInit = true;

  _stringListSupport(Iterable<Member> members) => '''
static inline
void member_names_list(String_list_t &out) {
  ${members.map((m) => 'out.push_back("${m.vname}");').join('\n  ')}
}

inline
void to_string_list(String_list_t &out) const {
  ${members.map((m) => 'out.push_back(boost::lexical_cast< std::string >(${m.vname}));').join('\n  ')}
}
''';

  _otlStreamSupport(Class cls) => '''
inline otl_stream& operator<<(otl_stream &out, ${cls.className} const& value) {
  out ${cls.members.map((m) => '<< value.${m.vname}').join('\n    ')};
}

inline otl_stream& operator>>(otl_stream &out, ${cls.className} & value) {
  out ${cls.members.map((m) => '>> value.${m.vname}').join('\n    ')};
}
''';

  _makeClass(String id, Iterable<Column> columns) {
    final result = class_(id)
      ..struct = true
      ..opEqual..opLess
      ..streamable = true
      ..members = columns.map((c) => _makeMember(c)).toList();
    return result
      ..getCodeBlock(clsPublic)
      .snippets
      .add(_stringListSupport(result.members))
      ..getCodeBlock(clsPostDecl)
      .snippets
      .add(_otlStreamSupport(result));
  }

  Header get header {
    final keyClass = '${tableName}_pkey';
    final keyClassType = idFromString(keyClass).capCamel;
    final valueClass = '${tableName}_value';
    final valueClassType = idFromString(valueClass).capCamel;
    final pkeyColumns = table.pkeyColumns;
    final valueColumns = table.valueColumns;
    final ns = namespace(['fcs','orm', tableName, 'table']);
    final result = new Header(tableId)
    ..includes = [
      'cstdint',
      'sstream',
      'vector',
      'boost/any.hpp',
      'fcs/orm/otl_config.hpp',
      'fcs/orm/otl_utils.hpp',
      'fcs/orm/orm_to_string_table.hpp',
    ]
    ..namespace = ns
    ..classes = [
      _makeClass(keyClass, pkeyColumns),
      _makeClass(valueClass, valueColumns),
      class_('${tableName}')
      ..isSingleton = true
      ..template = [
        'typename PKEY_LIST_TYPE = std::vector< $keyClassType >',
        'typename VALUE_LIST_TYPE = std::vector< $valueClassType >',
      ]
      ..usings = [
        'Pkey_t = $keyClassType',
        'Value_t = $valueClassType',
        'Pkey_list_t = PKEY_LIST_TYPE',
        'Value_list_t = VALUE_LIST_TYPE',
        'Row_t = std::pair< PKey_t, Value_t >',
        'Row_list_t = std::vector< Row_t >',
      ]
      ..getCodeBlock(clsPublic).snippets.add(_gateway_support),
    ];
    return result;
  }

  String _bindingVariableText(Column column) =>
    new OtlBindVariable.fromDataType(column.name, column.type).toString();

  String _bindingWhereClause(Iterable<Column> cols) => '''
${cols.map((col) => '${col.name}=${_bindingVariableText(col)}').join(' AND\n')}
''';

  String _bindingValueClause(Iterable<Column> cols) => '''
${cols.map((col) => '${_bindingVariableText(col)}').join(',\n')}
''';

  get _gateway_support => '''
static void print_recordset_as_table(Row_list_t const& recordset, std::ostream &out) {
  fcs::orm::print_recordset_as_table< Code_locations >(recordset, out);
}

static void print_values_as_table(Value_list_t const& values, std::ostream &out) {
  fcs::orm::print_values_as_table< Code_locations >(values, out);
}

int select_last_insert_id() {
  int result {};
  otl_stream stream { 1, "SELECT LAST_INSERT_ID()", *connection_ };
  if(!stream.eof()) {
    stream >> result;
  }
  return result;
}

int select_affected_row_count() {
  int result {};
  otl_stream stream { 1, "SELECT ROW_COUNT()", *connection_ };
  if(!stream.eof()) {
    int signed_result(0);
    stream >> signed_result;
    result = (signed_result < 0)? 0 : signed_result;
  }
  return result;
}

int select_table_row_count() {
  int result(0);
  otl_stream stream { 1, "SELECT COUNT(*) FROM $tableName", *connection_ };
  if(!stream.eof()) {
    stream >> result;
  }
  return result;
}

void select_all_rows(Row_list_t &found, std::string const& where_clause = "") {
  char const* select_stmt = R"(
${indentBlock(chomp(table.selectAll), '    ')}
  )";

  otl_stream stream { 50,
    where_clause.empty()?
      select_stmt :
      (std::string(select_stmt) + where_clause).c_str(),
    *connection_ };

  while(!stream.eof()) {
    Row_t row;
    stream >> row.first >> row.second;
    found.push_back(row);
  }
}

bool find_row_by_key(Pkey_t const& desideratum, Value_t & found) {
  char const* select_stmt = R"(
${indentBlock(chomp(table.selectValues), '    ')}
    where
${indentBlock(chomp(_bindingWhereClause(table.pkeyColumns)), '      ')}
  )";

  otl_stream stream { 50, select_stmt, *connection_ };
  stream << desideratum;
  if(!stream.eof()) {
    stream >> found;
    return true;
  }
  return false;
}

bool find_row_by_value(Row_t & desideratum) {
  char const* select_stmt = R"(
${indentBlock(chomp(table.selectKey), '    ')}
    where
${indentBlock(chomp(_bindingWhereClause(table.valueColumns)), '      ')}
  )";
  otl_stream stream { 50, select_stmt, *connection_ };
  stream << desideratum.second;
  if(!stream.eof()) {
    stream >> desideratum.first;
    return true;
  }
  return false;
}

void insert(Row_list_t const& nascent, int stream_buffer_size = 1) {
  if(nascent.empty()) {
    return;
  }
  char const* insert_stmt = R"(
    insert into ${tableName} (
${indentBlock(table.nonAutoColumnsJoined, '      ')}
    )
    values (
${indentBlock(chomp(_bindingValueClause(table.nonAutoColumns)), '      ')}
    )
  )";

  for(auto const& row : nascent) {
${
table.hasAutoIncrement?
'    stream << row.second;' :
'    stream << row.first << row.second;'
}
  }
}

void delete_row(Pkey_t const& moribund) {
  char const * delete_stmt = R"(
    delete
    from ${tableName}
    where
${indentBlock(_bindingWhereClause(table.pkeyColumns))}
  )";
  otl_stream stream { 50, delete_stmt, *connection_ };
  stream << moribund;
}

size_t delete_all_rows() {
  long rows_deleted { otl_cursor::direct_exec(*connection_, "DELETE FROM $tableName") };
  return size_t(rows_deleted);
}
''';

  // end <class TableGatewayGenerator>
}
// custom <part generator>

typedef bool TableFilter(Table);

TableFilter TableNameFilter(Iterable<String> tableNames) =>
  (Table t) => tableNames.contains(t.name);

// end <part generator>
