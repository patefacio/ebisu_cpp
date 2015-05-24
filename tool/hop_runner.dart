library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_docgen/hop_docgen.dart';
import 'package:path/path.dart' as path;
import '../test/runner.dart' as runner;

void main(List<String> args) {
  Directory.current = path.dirname(path.dirname(Platform.script.toFilePath()));

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  //TODO: Figure this out: addTask('docs', createDocGenTask(_getLibs));
  addTask('analyze_test', createAnalyzerTask([
    "test/test_cpp_enum.dart",
    "test/test_cpp_member.dart",
    "test/test_cpp_class.dart",
    "test/test_cpp_opout.dart",
    "test/test_cpp_method.dart",
    "test/test_cpp_utils.dart",
    "test/test_cpp_namer.dart",
    "test/test_cpp_generic.dart",
    "test/test_cpp_test_provider.dart",
    "test/test_cpp_exception.dart",
    "test/test_cpp_versioning.dart",
    "test/test_hdf5_support.dart",
    "test/test_enumerated_dispatcher.dart"
  ]));

  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib')
      .list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
