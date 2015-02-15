part of ebisu_cpp.db_schema;

enum BindDataType {
  bdtInt,
  bdtShort,
  bdtDouble,
  bdtBigint,
  bdtSizedChar,
  bdtUnsizedChar,
  bdtVarcharLong,
  bdtTimestamp
}
/// Convenient access to BindDataType.bdtInt with *bdtInt* see [BindDataType].
///
const BindDataType bdtInt = BindDataType.bdtInt;

/// Convenient access to BindDataType.bdtShort with *bdtShort* see [BindDataType].
///
const BindDataType bdtShort = BindDataType.bdtShort;

/// Convenient access to BindDataType.bdtDouble with *bdtDouble* see [BindDataType].
///
const BindDataType bdtDouble = BindDataType.bdtDouble;

/// Convenient access to BindDataType.bdtBigint with *bdtBigint* see [BindDataType].
///
const BindDataType bdtBigint = BindDataType.bdtBigint;

/// Convenient access to BindDataType.bdtSizedChar with *bdtSizedChar* see [BindDataType].
///
const BindDataType bdtSizedChar = BindDataType.bdtSizedChar;

/// Convenient access to BindDataType.bdtUnsizedChar with *bdtUnsizedChar* see [BindDataType].
///
const BindDataType bdtUnsizedChar = BindDataType.bdtUnsizedChar;

/// Convenient access to BindDataType.bdtVarcharLong with *bdtVarcharLong* see [BindDataType].
///
const BindDataType bdtVarcharLong = BindDataType.bdtVarcharLong;

/// Convenient access to BindDataType.bdtTimestamp with *bdtTimestamp* see [BindDataType].
///
const BindDataType bdtTimestamp = BindDataType.bdtTimestamp;

class OtlBindVariable {
  String name;
  BindDataType dataType;
  int size = 0;
  // custom <class OtlBindVariable>

  OtlBindVariable.fromDataType(this.name, SqlType sqlType) {
    switch (sqlType.runtimeType) {
      case SqlString:
        {
          final str = sqlType as SqlString;
          if (str.length > 0) {
            dataType = bdtSizedChar;
            size = str.length;
          } else {
            dataType = bdtVarcharLong;
          }
        }
        break;
      case SqlInt:
        dataType = (sqlType as SqlInt).length <= 4 ? bdtInt : bdtBigint;
        break;
      case SqlDecimal:
        throw 'Add support for SqlDecimal';
      case SqlBinary:
        throw 'Add support for SqlDecimal';
      case SqlFloat:
        dataType = bdtDouble;
        break;
      case SqlDate:
      case SqlTime:
      case SqlTimestamp:
        {
          dataType = bdtTimestamp;
          break;
        }
    }
  }

  toString() => dataType == bdtSizedChar
      ? ':$name<char[$size]>'
      : ':$name<${typeMapping[dataType]}>';

  static Map<BindDataType, String> typeMapping = {
    bdtInt: 'int',
    bdtShort: 'short',
    bdtDouble: 'double',
    bdtBigint: 'bigint',
    bdtUnsizedChar: 'char[]',
    bdtVarcharLong: 'varchar_long',
    bdtTimestamp: 'timestamp',
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
      ..classes.add(class_(connectionClassId)
        ..getCodeBlock(clsPublic).snippets = [_connectionSingletonPublic]
        ..withDefaultCtor((ctor) => ctor.topInject = '''
  otl_connect *connection = new otl_connect;
  connection->rlogon("DSN=${id.snake}", 0);
  tss_connection_.reset(connection);
''')
        ..isSingleton = true
        ..members = [
          member('tss_connection')
            ..type = 'boost::thread_specific_ptr< otl_connect >',
        ]);
  }

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
      SchemaCodeGenerator schemaCodeGenerator, Table table)
      : super(installation, schemaCodeGenerator, table);

  void finishClass(Class cls) {
    cls.getCodeBlock(clsPostDecl).snippets.add(_otlStreamSupport(cls));
  }

  void finishGatewayClass(Class gatewayClass) {
    gatewayClass.members.add(member('connection')
      ..type = 'otl_connect *'
      ..access = ia
      ..initText = 'Connection_code_metrics::instance().connection()');
  }

  void addRequiredIncludes(Header hdr) => hdr.includes
      .addAll(['fcs/orm/otl_utils.hpp', 'fcs/orm/orm_to_string_table.hpp',]);

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

  String _bindingVariableText(Column column) =>
      new OtlBindVariable.fromDataType(column.name, column.type).toString();

  String _bindingWhereClause(Iterable<Column> cols) => '''
${cols.map((col) => '${col.name}=${_bindingVariableText(col)}').join(' AND\n')}
''';

  String _bindingUpdateClause(Iterable<Column> cols) => '''
${cols.map((col) => '${col.name}=${_bindingVariableText(col)}').join(',\n')}
''';

  String _bindingValueClause(Iterable<Column> cols) => '''
${cols.map((col) => '${_bindingVariableText(col)}').join(',\n')}
''';

  // end <class OtlTableGatewayGenerator>
}
// custom <part otl_generator>
// end <part otl_generator>
