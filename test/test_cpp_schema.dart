library ebisu_cpp.test.test_cpp_schema;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:ebisu_cpp/db_schema.dart';
// end <additional imports>

// custom <library test_cpp_schema>
// end <library test_cpp_schema>
main() {
// custom <main>


  test('read_ini', () {
    final odbcIni = new OdbcIni();
    print(odbcIni);
  });

  test('read_mysql_schema', () {
    final f = readMysqlSchema('code_metrics')
      .then((s) => print(s));
  });

  test('table_filter', () {
    final f = readMysqlSchema('code_metrics')
      .then((Schema s) {
        final g = new SchemaCodeGenerator(s)
          ..tableFilter = TableNameFilter(['rusage_delta'])
          ..generate();
        print('done');
      });
  });

// end <main>

}
