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

  test('get_schema', () {
    final schema = new Schema.fromDatabase('code_metrics');
  });

// end <main>

}
