import 'package:test/test.dart';
import 'package:logging/logging.dart';
import 'test_cpp_enum.dart' as test_cpp_enum;
import 'test_cpp_member.dart' as test_cpp_member;
import 'test_cpp_class.dart' as test_cpp_class;
import 'test_cpp_opout.dart' as test_cpp_opout;
import 'test_cpp_method.dart' as test_cpp_method;
import 'test_cpp_utils.dart' as test_cpp_utils;
import 'test_cpp_namer.dart' as test_cpp_namer;
import 'test_cpp_generic.dart' as test_cpp_generic;
import 'test_cpp_test_provider.dart' as test_cpp_test_provider;
import 'test_cpp_exception.dart' as test_cpp_exception;
import 'test_cpp_versioning.dart' as test_cpp_versioning;
import 'test_hdf5_support.dart' as test_hdf5_support;
import 'test_enumerated_dispatcher.dart' as test_enumerated_dispatcher;

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
  test_cpp_opout.main();
  test_cpp_method.main();
  test_cpp_utils.main();
  test_cpp_namer.main();
  test_cpp_generic.main();
  test_cpp_test_provider.main();
  test_cpp_exception.main();
  test_cpp_versioning.main();
  test_hdf5_support.main();
  test_enumerated_dispatcher.main();
}
