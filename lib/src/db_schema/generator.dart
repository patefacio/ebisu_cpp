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
class SchemaCodeGenerator extends Object with InstallationCodeGenerator {
  Schema schema;
  Id get id => _id;
  Id get connectionClassId => _connectionClassId;
  String get connectionClassName => _connectionClassName;
  List<Query> queries = [];
  TableFilter tableFilter = (Table t) => true;
  // custom <class SchemaCodeGenerator>

  SchemaCodeGenerator(this.schema) {
    _id = idFromString(schema.name);
    _connectionClassId = new Id('connection_${id.snake}');
    _connectionClassName = _connectionClassId.capSnake;
  }

  get tables => schema.tables.where((t) => tableFilter(t));

  get namespace => new Namespace(['fcs','orm', id.snake ]);

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

  void generate() {

    final queryVisitor = schema.engine.queryVisitor;
    print('All queries are ${queries.map((q) => queryVisitor.select(q))}');
    final ns = namespace;
    final connectionClass = 'connection_${id.snake}';

    final apiHeader = new Header(id)
      ..includes = [
        'fcs/orm/orm.hpp',
      ]
      ..isApiHeader = true
      ..namespace = ns
      ..classes = [
        class_(connectionClassId)
        ..getCodeBlock(clsPrivate).snippets = [_connectionSingletonPrivate]
        ..getCodeBlock(clsPublic).snippets = [_connectionSingletonPublic]
        ..isSingleton = true
        ..members = [
          member('tss_connection')..type = 'boost::thread_specific_ptr< otl_connect >',
        ],
      ]
      ..setFilePathFromRoot(installation.cppPath);

    final lib = new Lib(id)
      ..installation = installation
      ..namespace = ns
      ..headers = [ apiHeader ];

    tables.forEach((Table t) {
      final header = new TableGatewayGenerator(installation, this, t).header;
      header.includes.add(apiHeader.includeFilePath);
      lib.headers.add(header);
    });

    lib.generate();
  }

  // end <class SchemaCodeGenerator>
  Id _id;
  Id _connectionClassId;
  String _connectionClassName;
}

class TableDetails {
  const TableDetails(this.schema, this.table, this.tableId, this.tableName,
    this.className, this.keyClassId, this.valueClassId);

  final Schema schema;
  final Table table;
  final Id tableId;
  final String tableName;
  final String className;
  final Id keyClassId;
  final Id valueClassId;
  // custom <class TableDetails>

  factory TableDetails.fromTable(Schema schema, Table table) {
    final tableId = idFromString(table.name);
    return new TableDetails(schema,
        table, tableId, table.name, tableId.capSnake,
        idFromString('${tableId.snake}_pkey'),
        idFromString('${tableId.snake}_value'));
  }

  get columnIds => table.columns.map((c) => idFromString(c.name));
  get keyClassName => keyClassId.capSnake;
  get valueClassName => valueClassId.capSnake;
  get keyColumns => table.primaryKey;
  get valueColumns => table.valueColumns;
  get fkeyPath => schema.getDfsPath(table.name);
  get rowType => '$className<>::Row_t';

  // end <class TableDetails>
}

class TableGatewayGenerator {
  Installation installation;
  SchemaCodeGenerator schemaCodeGenerator;
  Class keyClass;
  Class valueClass;
  // custom <class TableGatewayGenerator>

  TableGatewayGenerator(this.installation, this.schemaCodeGenerator, Table table) {
    _tableDetails = new TableDetails.fromTable(schemaCodeGenerator.schema, table);
    keyClass = _makeClass(keyClassId.snake, table.primaryKey);
    valueClass = _makeClass(valueClassId.snake, table.valueColumns);
  }

  get schema => _tableDetails.schema;
  get table => _tableDetails.table;
  get tableId => _tableDetails.tableId;
  get tableName => _tableDetails.tableName;
  get className => _tableDetails.className;
  get rowType => _tableDetails.rowType;
  get keyClassId => _tableDetails.keyClassId;
  get valueClassId => _tableDetails.valueClassId;

  _makeMember(c) =>
    member(c.name)
    ..cppAccess = public
    ..type = _cppType(c.type)
    ..noInit = true;

  _colInRow(Table table, Column c) =>
    table.isPrimaryKeyColumn(c) ?
    'first.${c.name}' : 'second.${c.name}';

  _linkToMethod(ForeignKey fk) {
    final ref = new TableDetails.fromTable(schema, fk.refTable);
    return '''
// Establish link from $className to ${ref.className}
// across foreign key $tableName.`${fk.name}`
inline void
link_rows($rowType & from_row,
          ${ref.rowType} const& to_row) {
  ${
fk.columnPairs.map((l) =>
  'from_row.${_colInRow(table, l[0])} = to_row.${_colInRow(ref.table, l[1])}').join(';\n  ')};
}''';
  }

  get _foreignLinks => combine(
    table
    .foreignKeys
    .values
    //.where((ForeignKey fk) => td.table == table)
    .map((ForeignKey fk) => _linkToMethod(fk)));

  _stringListSupport(Iterable<Member> members) => '''
static inline
void member_names_list(String_list_t &out) {
  ${members.map((m) => 'out.push_back("${m.name}");').join('\n  ')}
}

inline void
to_string_list(String_list_t &out) const {
  ${members.map((m) => 'out.push_back(boost::lexical_cast< std::string >(${m.vname}));').join('\n  ')}
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

  setFilePathFromRoot(String root) =>
    header.setFilePathFromRoot(root);

  Header get header {
    if(_header == null) {
      _header = _makeHeader();
    }
    return _header;
  }

  Namespace get namespace => new Namespace(
    []
    ..addAll(schemaCodeGenerator.namespace.names)
    ..addAll(['table']));

  Header _makeHeader() {
    final keyClassType = keyClass.className;
    final valueClassType = valueClass.className;
    final valueColumns = table.valueColumns;
    final hasForeignKey  = table.hasForeignKey;
    var fkeyIncludes = [];
    table.foreignKeys.values.forEach((ForeignKey fk) {
      final refTableId = idFromString(fk.refTable.name);
      fkeyIncludes.add('${refTableId.snake}.hpp');
    });

    final result = new Header(tableId)
      ..namespace = namespace
      ..includes = (
        [
          'cstdint',
          'utility',
          'sstream',
          'vector',
          'boost/any.hpp',
          'fcs/orm/otl_utils.hpp',
          'fcs/orm/orm_to_string_table.hpp',
        ]..addAll(fkeyIncludes)
                    )
      ..classes = [
        keyClass,
        valueClass,
        class_('${tableName}')
        ..includeTest = !hasForeignKey
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
          'Row_t = std::pair< Pkey_t, Value_t >',
          'Row_list_t = std::vector< Row_t >',
        ]
        ..members = [
          member('connection')..type = 'otl_connect *'
          ..access = ia
          ..initText = 'Connection_code_metrics::instance().connection()',
        ]
        ..getCodeBlock(clsPublic).snippets.add(_gatewaySupport)
        ..getCodeBlock(clsPostDecl).snippets.add(_foreignLinks),
      ];

    //    if(!hasForeignKey) {
    new GatewayTestGenerator(result.test, _tableDetails, namespace);
      //    }

    return result;
  }

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

  get _gatewaySupport => '''
static void
print_recordset_as_table(Row_list_t const& recordset,
                         std::ostream &out) {
  fcs::orm::print_recordset_as_table< $className >(recordset, out);
}

static void
print_values_as_table(Value_list_t const& values,
                      std::ostream &out) {
  fcs::orm::print_values_as_table< $className >(values, out);
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

size_t delete_all_rows() {
  long rows_deleted {
    otl_cursor::direct_exec(*connection_, "DELETE FROM $tableName")
  };
  return size_t(rows_deleted);
}
''';

  // end <class TableGatewayGenerator>
  TableDetails _tableDetails;
  Header _header;
}
// custom <part generator>

typedef bool TableFilter(Table);

TableFilter TableNameFilter(Iterable<String> tableNames) =>
  (Table t) => tableNames.contains(t.name);

_nonAutoColumns(Table table) => table.columns.where((c) => !c.autoIncrement);
_joined(Iterable<Column> cols) => cols.map((c) => c.name).join(',\n');

_selectKey(Table table) {
  final name = table.name;
  final keyColumnsJoined = table.primaryKey.map((c) => c.name).join(',\n');
  return '''
select
${indentBlock(keyColumnsJoined)}
from
  $name
''';
}

_selectValues(Table table) {
  final name = table.name;
  final valueColumnsJoined = _joined(table.valueColumns);
  return '''
select
${indentBlock(valueColumnsJoined)}
from
  $name
''';
}

_selectAll(Table table) {
  final name = table.name;
  final allColumnsJoined = _joined(table.columns);
  return '''
select
${indentBlock(allColumnsJoined)}
from
  $name
''';
}

String _cppType(SqlType sqlType) {
    switch(sqlType.runtimeType) {
      case SqlString:
        final str = sqlType as SqlString;
        return (str.length > 0)?
          'fcs::utils::Fixed_size_char_array< ${str.length} >' :
          'std::string';
      case SqlInt: return (sqlType as SqlInt).length <= 4? 'int32_t' : 'int64_t';
      case SqlDecimal: return 'decimal';
      case SqlBinary: throw 'Add support for SqlDecimal';
      case SqlFloat: return 'double';
      case SqlDate:
      case SqlTime:
      case SqlTimestamp: return 'otl_datetime';
    }
    throw 'SqlType $sqlType not supported';
}

// end <part generator>
