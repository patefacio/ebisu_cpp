library ebisu_cpp.test_cpp_file;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_file');

// custom <library test_cpp_file>
// end <library test_cpp_file>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('include stack trace', () {
    Header h = header('h')..namespace = namespace([])
      ..includeStackTrace = true;

    var generatedText = 'This file was generated';
    var stackTraceText = 'Stack trace associated with generated code';
    expect(h.wrappedContents.contains(generatedText), true);
    expect(h.wrappedContents.contains(stackTraceText), true);
  });

// end <main>
}
