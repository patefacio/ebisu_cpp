part of ebisu_cpp.db_schema;

// custom <part mysql>

RegExp _intRe = new RegExp(r'^int(?:\(\d+\))', caseSensitive : false);
bool isInt(String typeSpec) => _intRe.hasMatch(typeSpec);
RegExp _tinyIntRe = new RegExp(r'^tinyint(?:\(\d+\))', caseSensitive : false);
bool isTinyInt(String typeSpec) => _tinyIntRe.hasMatch(typeSpec);
RegExp _smallIntRe = new RegExp(r'^smallint(?:\(\d+\))', caseSensitive : false);
bool isSmallInt(String typeSpec) => _smallIntRe.hasMatch(typeSpec);
RegExp _bigIntRe = new RegExp(r'^bigint(?:\(\d+\))', caseSensitive : false);
bool isBigInt(String typeSpec) => _bigIntRe.hasMatch(typeSpec);
RegExp _doubleRe = new RegExp(r'^double', caseSensitive : false);
bool isDouble(String typeSpec) => _doubleRe.hasMatch(typeSpec);
RegExp _dateTimeRe = new RegExp(r'^datetime', caseSensitive : false);
bool isDateTime(String typeSpec) => _dateTimeRe.hasMatch(typeSpec);
RegExp _timeRe = new RegExp(r'^time', caseSensitive : false);
bool isTime(String typeSpec) => _timeRe.hasMatch(typeSpec);
RegExp _varCharRe = new RegExp(r'^varchar(?:\(\d+\))$', caseSensitive : false);
bool isVarChar(String typeSpec) => _varCharRe.hasMatch(typeSpec);
RegExp _fixedVarCharRe = new RegExp(r'^varchar\((\d+)\)$', caseSensitive : false);

Map _mappings = {
  isDouble : Double,
  isInt : Int,
  isTinyInt : TinyInt,
  isSmallInt : SmallInt,
  isBigInt : BigInt,
  isTime : Time,
  isDateTime : DateTime,
  isVarChar : VarChar,
};

DataType mapDataType(String typeSpec) {
  try {
    final match = _mappings
      .keys
      .firstWhere((f) => f(typeSpec),
          orElse: () => throw '$typeSpec mapping is not supported');
    var result = _mappings[match];
    if(result == VarChar) {
      // Check for fixed size varchar
      final fixedSizeMatch = _fixedVarCharRe.firstMatch(typeSpec);
      if(fixedSizeMatch != null) {
        final size = int.parse(fixedSizeMatch.group(1));
        result = new FixedVarchar(size, typeSpec,
            'fcs::utils::Fixed_size_char_array< $size >');
      }
    }
    return result;
  } catch(e) {
    print('Caught $e');
  }
}

Future<Schema> readMysqlSchema(String dsn) {
  try {
    final ini = new OdbcIni();
    final entry = ini.getEntry(dsn);
    final pool = new ConnectionPool(user: entry.user,
        password: entry.password, db: dsn);
    final tables = [];
    return pool
      .query('show tables')
      .then((var tableNames) => tableNames.map((t) => t[0]).toList())
      .then((var tableNames) =>
          tableNames.map((var t) =>
              pool
              .query('describe $t')
              .then((_) => _.toList())
              .then((var describe) =>
                  [
                    t,
                    describe.map(
                      (row) =>
                      new Column()
                      ..name = row[0]
                      ..type = mapDataType(row[1].toString())
                      ..isNull = row[2] != 'NO'
                      ..isPrimaryKey = row[3] == 'PRI'
                      ..defaultValue = row[4]
                      ..extra = row[5]
                      ..isAutoIncrement = row[5] == 'auto_increment'
                                 )]
                    )))
      .then((futures) => Future.wait(futures))
      .then((List tableData) {
        tableData.forEach((List tableData) =>
            tables.add(new Table(tableData[0], tableData[1].toList())));
        pool.close();
        print('Connection pool has closed');
        return new Schema(entry.database, tables);
      });
  } catch(e) {
    print('Caught $e');
  }
}


// end <part mysql>
