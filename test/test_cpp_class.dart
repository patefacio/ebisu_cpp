library ebisu_cpp.test.test_cpp_class;

import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:ebisu_cpp/cpp_class.dart';
// end <additional imports>

// custom <library test_cpp_class>
// end <library test_cpp_class>
main() {
// custom <main>

  test('basic', () {
    print(cppClass('c_1').definition);
  });
// end <main>

}
