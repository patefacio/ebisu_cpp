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
    final env = header('q_environment')
      ..namespace = namespace(['ebisu', 'gui', 'environment'])
      ..classes = [
        qtClass('tree_path_model')
          ..bases = [base('QAbstractItemModel')]
          ..members = [
            member('column_headers')..type = 'Header_array_t',
            member('column_count')..type = 'size_t',
          ],
        qtClass('q_environment')
          ..bases = [base('QWidget')]
          ..members = [
            member('variable_list_table')..type = 'QTableWidget *',
            member('spitter')..type = 'QSplitter *',
            member('tree_path_model')..type = 'Tree_path_model *',
            member('path_splitter')..type = 'QSplitter *',
            member('problem_table')..type = 'QTableWidget *',
          ]
      ]
      ..setAsRoot();

    print(env.contents);
  });

// end <main>
}
