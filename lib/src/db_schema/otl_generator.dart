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

  OtlBindVariable.fromDataType(this.name, SqlType sqlType) {
    switch(sqlType.runtimeType) {
      case SqlString: {
        final str = sqlType as SqlString;
        if(str.length > 0) {
          dataType = BDT_SIZED_CHAR;
          size = str.length;
        } else {
          dataType = BDT_VARCHAR_LONG;
        }
      }
      break;
      case SqlInt:
        dataType = (sqlType as SqlInt).length <= 4? BDT_INT : BDT_BIGINT;
        break;
      case SqlDecimal:
        throw 'Add support for SqlDecimal';
      case SqlBinary:
        throw 'Add support for SqlDecimal';
      case SqlFloat:
        dataType = BDT_DOUBLE;
        break;
      case SqlDate:
      case SqlTime:
      case SqlTimestamp: {
        dataType = BDT_TIMESTAMP;
        break;
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

  // end <class OtlBindVariable>
}

/// Given a schema generates code to support accessing tables and configured
/// queries. Makes use of the otl c++ library.
///
class OtlSchemaCodeGenerator extends SchemaCodeGenerator {
  Id get connectionClassId => _connectionClassId;
  String get connectionClassName => _connectionClassName;
  // custom <class OtlSchemaCodeGenerator>
  OtlSchemaCodeGenerator(Schema schema) : super(schema) {
    _connectionClassId = new Id('connection_${id.snake}');
    _connectionClassName = _connectionClassId.capSnake;
  }

  get namespace => super.namespace;

  TableGatewayGenerator createTableGatewayGenerator(Table t) =>
    new OtlTableGatewayGenerator(installation, this, t);

  finishApiHeader(Header apiHeader) {
    final connectionClass = 'connection_${id.snake}';
    apiHeader
      ..includes.add('fcs/orm/orm.hpp')
      ..classes.add(
          class_(connectionClassId)
          ..getCodeBlock(clsPrivate).snippets = [_connectionSingletonPrivate]
          ..getCodeBlock(clsPublic).snippets = [_connectionSingletonPublic]
          ..isSingleton = true
          ..members = [
            member('tss_connection')..type = 'boost::thread_specific_ptr< otl_connect >',
          ]);
  }
  
  get _connectionSingletonPrivate => '''
$connectionClassName() {
  otl_connect *connection = new otl_connect;
  connection->rlogon("DSN=${id.snake}", 0);
  tss_connection_.reset(connection);
}

''';

  get _connectionSingletonPublic => '''
otl_connect * connection() {
  return tss_connection_.get();
}
''';

  // end <class OtlSchemaCodeGenerator>
  Id _connectionClassId;
  String _connectionClassName;
}

class OtlTableGatewayGenerator extends TableGatewayGenerator {
  // custom <class OtlTableGatewayGenerator>

  OtlTableGatewayGenerator(Installation installation,
      SchemaCodeGenerator schemaCodeGenerator, Table table) :
    super(installation, schemaCodeGenerator, table);

  void finishClass(Class cls) {
    cls.getCodeBlock(clsPostDecl).snippets.add(_otlStreamSupport(cls));
  }

  void finishGatewayClass(Class gatewayClass) {
    gatewayClass.members.add(
        member('connection')..type = 'otl_connect *'
        ..access = ia
        ..initText = 'Connection_code_metrics::instance().connection()');
  }

  void addRequiredIncludes(Header hdr) =>
    hdr.includes.addAll([
      'fcs/orm/otl_utils.hpp',
      'fcs/orm/orm_to_string_table.hpp',
    ]);


  get selectLastInsertId => '''
int select_last_insert_id() {
  int result {};
  otl_stream stream { 1, "SELECT LAST_INSERT_ID()", *connection_ };
  if(!stream.eof()) {
    stream >> result;
  }
  return result;
}

''';

  get selectAffectedRowCount => '''
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

''';

  get selectTableRowCount => '''
int select_table_row_count() {
  int result(0);
  otl_stream stream { 1, "SELECT COUNT(*) FROM $tableName", *connection_ };
  if(!stream.eof()) {
    stream >> result;
  }
  return result;
}

''';

  get selectAllRows => '''
Row_list_t select_all_rows(std::string const& where_clause = "") {
  Row_list_t found;
  char const* select_stmt = R"(
${indentBlock(chomp(_selectAll(table)), '    ')}
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
  return found;
}

''';

  get findRowByKey => '''
bool find_row_by_key(Pkey_t const& desideratum, Value_t & found) {
  char const* select_stmt = R"(
${indentBlock(chomp(_selectValues(table)), '    ')}
    where
${indentBlock(chomp(_bindingWhereClause(table.primaryKey)), '      ')}
  )";

  otl_stream stream { 50, select_stmt, *connection_ };
  stream << desideratum;
  if(!stream.eof()) {
    stream >> found;
    return true;
  }
  return false;
}

''';

  get findRowByValue => '''
bool find_row_by_value(Row_t & desideratum) {
  char const* select_stmt = R"(
${indentBlock(chomp(_selectKey(table)), '    ')}
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

''';

  get insertRowList => '''
void insert(Row_list_t const& nascent, int stream_buffer_size = 1) {
  if(nascent.empty()) {
    return;
  }
  char const* insert_stmt = R"(
    insert into ${tableName} (
${indentBlock(_joined(_nonAutoColumns(table)), '      ')}
    )
    values (
${indentBlock(chomp(_bindingValueClause(_nonAutoColumns(table))), '      ')}
    )
  )";
  otl_stream stream { 50, insert_stmt, *connection_ };
  for(auto const& row : nascent) {
${
table.hasAutoIncrement?
'    stream << row.second;' :
'    stream << row.first << row.second;'
}
  }
}

''';

  get updateRowList => '''
void update(Row_list_t const& changing) {
  if(changing.empty()) {
    return;
  }

  char const* update_stmt = R"(
    update $tableName
    set
${indentBlock(chomp(_bindingUpdateClause(table.valueColumns)), '      ')}
    where
${indentBlock(chomp(_bindingWhereClause(table.primaryKey)), '      ')}
  )";

  otl_stream stream(1, update_stmt, *connection_);
  for(auto const& row : changing) {
    stream << row.second << row.first;
  }

}

''';

  get deleteRow => '''
void delete_row(Pkey_t const& moribund) {
  char const * delete_stmt = R"(
    delete
    from ${tableName}
    where
${indentBlock(_bindingWhereClause(table.primaryKey))}
  )";
  otl_stream stream { 50, delete_stmt, *connection_ };
  stream << moribund;
}

''';

  get deleteAllRows => '''
size_t delete_all_rows() {
  long rows_deleted {
    otl_cursor::direct_exec(*connection_, "DELETE FROM $tableName")
  };
  return size_t(rows_deleted);
}
''';
  
  _otlStreamSupport(Class cls) => '''
inline otl_stream&
operator<<(otl_stream &out,
           ${cls.className} const& value) {
  out ${cls.members.map((m) => '<< value.${m.vname}').join('\n    ')};
  return out;
}

inline otl_stream&
operator>>(otl_stream &src,
           ${cls.className} & value) {
  src ${cls.members.map((m) => '>> value.${m.vname}').join('\n    ')};
  return src;
}
''';

  
  
  // end <class OtlTableGatewayGenerator>
}
// custom <part otl_generator>
// end <part otl_generator>
