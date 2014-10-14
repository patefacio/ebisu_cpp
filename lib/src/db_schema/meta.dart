part of ebisu_cpp.db_schema;

class Schema {

  Schema(this.tables);

  List<Table> tables = [];

  // custom <class Schema>

  String toString() => '''
Schema(todo)
  ${tables.map((t) => t.toString()).join('\n  ')}
''';

  // end <class Schema>
}

class Query {


  // custom <class Query>
  // end <class Query>
}

class Table {

  String name;
  List<Column> columns = [];
  List<Column> pkey = [];

  // custom <class Table>

  String toString() => '''
Table($name)
    ${columns.map((c) => c.toString()).join(',\n    ')}
''';

  // end <class Table>
}

class DataType {

  const DataType(this.dbType, this.cppType);

  final String dbType;
  final String cppType;

  // custom <class DataType>
  // end <class DataType>
}

class FixedVarchar extends DataType {

  int size;

  // custom <class FixedVarchar>

  FixedVarchar(this.size, dbType, cppType) :
    super(dbType, cppType);

  // end <class FixedVarchar>
}

class DbType {

  DbType(this.type);

  String type;

  // custom <class DbType>

  String toString() => type;

  // end <class DbType>
}

class Column {

  String name;
  DataType type;
  bool isNull = false;
  String key;
  String defaultValue;
  String extra;

  // custom <class Column>

  String toString() => '''
$name ${type.dbType} ${isNull? 'NULL' : 'NOT NULL'}''';

  // end <class Column>
}
// custom <part meta>

const Int = const DataType('INT', 'int32_t');
const TinyInt = const DataType('TINYINT', 'int16_t');
const SmallInt = const DataType('SMALLINT', 'int16_t');
const BigInt = const DataType('BIGINT', 'int64_t');
const Time = const DataType('TIME', 'otl_time');
const Timestamp = const DataType('TIMESTAMP', 'otl_datetime');
const DateTime = const DataType('DATETIME', 'otl_datetime');
const Date = const DataType('DATE', 'otl_datetime');
const Text = const DataType('TEXT', 'otl_long_string');
const VarChar = const DataType('VARCHAR', 'otl_long_string');
const Double = const DataType('DOUBLE', 'double');

// end <part meta>
