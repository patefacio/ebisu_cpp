library ebisu_cpp.test_qt_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/qt_support.dart';

// end <additional imports>

final _logger = new Logger('test_qt_support');

// custom <library test_qt_support>
// end <library test_qt_support>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('qt class', () {
    expect(qtClass('tree_path_model').definition.contains('Q_OBJECT'), true);
  });

// end <main>
}
