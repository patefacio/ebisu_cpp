library ebisu_cpp.test_cpp_versioning;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu_cpp/ebisu_cpp.dart';
// end <additional imports>

final _logger = new Logger('test_cpp_versioning');

// custom <library test_cpp_versioning>

// end <library test_cpp_versioning>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('semantic versioning', () {
    print(new SemanticVersion.fromString("1.32.2"));
  });

// end <main>

}
