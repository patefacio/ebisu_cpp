part of ebisu_cpp.db_schema;

class DataType {
  const DataType(this.dbType, this.cppType);

  bool operator ==(DataType other) => identical(this, other) ||
      dbType == other.dbType && cppType == other.cppType;

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

  FixedVarchar(this.size, dbType, cppType) : super(dbType, cppType);

  // end <class FixedVarchar>
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
