library ebisu_cpp.test_build_parser;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'dart:io';
import 'package:ebisu_cpp/build_parser.dart';
import 'package:path/path.dart';

// end <additional imports>

final Logger _logger = new Logger('test_build_parser');

// custom <library test_build_parser>
// end <library test_build_parser>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  Logger.root.level = Level.OFF;

  test('parse example', () {
    final here = Platform.script.path;
    final logFile = join(dirname(here), 'data', 'build_log.txt');
    final buildParser = new BuildParser(logFile);
  });

// end <main>
}
