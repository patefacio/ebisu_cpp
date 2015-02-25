import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'test_cpp_enum.dart' as test_cpp_enum;
import 'test_cpp_member.dart' as test_cpp_member;
import 'test_cpp_class.dart' as test_cpp_class;
import 'test_cpp_method.dart' as test_cpp_method;
import 'test_cpp_utils.dart' as test_cpp_utils;
import 'test_cpp_namer.dart' as test_cpp_namer;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_cpp_enum.main();
  test_cpp_member.main();
  test_cpp_class.main();
  test_cpp_method.main();
  test_cpp_utils.main();
  test_cpp_namer.main();
}
