part of ebisu_cpp.db_schema;

class Schema {

  Schema(this.name, this.tables);

  String name;
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

  // custom <class Table>

  Table(this.name, this.columns);

  get hasAutoIncrement => columns.any((c) => c.isAutoIncrement);

  String toString() => '''
Table($name)
    ${columns.map((c) => c.toString()).join(',\n    ')}
''';

  Iterable get pkeyColumns => columns.where((c) => c.isPrimaryKey);
  Iterable get valueColumns => columns.where((c) => !c.isPrimaryKey);
  Iterable get nonAutoColumns => columns.where((c) => !c.isAutoIncrement);

  get allColumnsJoined => columns.map((c) => c.name).join(',\n');
  get pkeyColumnsJoined => pkeyColumns.map((c) => c.name).join(',\n');
  get valueColumnsJoined => valueColumns.map((c) => c.name).join(',\n');
  get nonAutoColumnsJoined => hasAutoIncrement?
    valueColumnsJoined : allColumnsJoined;

  get selectAll => '''
select
${indentBlock(allColumnsJoined)}
from
  $name
''';

  get selectValues => '''
select
${indentBlock(valueColumnsJoined)}
from
  $name
''';

  get selectKey => '''
select
${indentBlock(pkeyColumnsJoined)}
from
  $name
''';

  // end <class Table>
}

class DataType {

  const DataType(this.dbType, this.cppType);

  bool operator==(DataType other) =>
    identical(this, other) ||
    dbType == other.dbType &&
    cppType == other.cppType;

  int get hashCode => hash2(dbType, cppType);

  final String dbType;
  final String cppType;

  // custom <class DataType>

  toString() => 'Db($dbType) <=> C++($cppType)';

  // end <class DataType>
}

class FixedVarchar extends DataType {

  int size;

  // custom <class FixedVarchar>

  FixedVarchar(this.size, dbType, cppType) :
    super(dbType, cppType);

  // end <class FixedVarchar>
}

class Column {

  String name;
  DataType type;
  bool isNull = false;
  bool isPrimaryKey = false;
  bool isAutoIncrement = false;
  String defaultValue;
  String extra;

  // custom <class Column>

  get cppType => type.cppType;

  String toString() => '''
$name ${type.dbType} ${isNull? 'NULL' : 'NOT NULL'} ${isPrimaryKey? "PRI":""} $extra''';

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
