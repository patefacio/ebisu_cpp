#!/usr/bin/env dart
/// Creates an ebisu_cpp setup
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart' as ebisu;
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

//! The parser for this script
ArgParser _parser;
//! The comment and usage associated with this script
void _usage() {
  print(r'''
Creates an ebisu_cpp setup
''');
  print(_parser.getUsage());
}
//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs(List<String> args) {
  ArgResults argResults;
  Map result = {};
  List remaining = [];

  _parser = new ArgParser();
  try {
    /// Fill in expectations of the parser
    _parser.addFlag('help', help: r'''
Display this help screen
''', abbr: 'h', defaultsTo: false);

    _parser.addOption('project-path', help: r'''
Path to top level of desired ebisu project
''', defaultsTo: null, allowMultiple: false, abbr: 'p', allowed: null);
    _parser.addOption('add-app', help: r'''
Add library to project
''', defaultsTo: null, allowMultiple: false, abbr: 'a', allowed: null);
    _parser.addOption('add-lib', help: r'''
Add library to project
''', defaultsTo: null, allowMultiple: false, abbr: 'l', allowed: null);
    _parser.addOption('add-script', help: r'''
Add script to project
''', defaultsTo: null, allowMultiple: false, abbr: 's', allowed: null);
    _parser.addOption('log-level', help: r'''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]

''', defaultsTo: null, allowMultiple: false, abbr: null, allowed: null);

    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    if (argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
    result['project-path'] = argResults['project-path'];
    result['add-app'] = argResults['add-app'];
    result['add-lib'] = argResults['add-lib'];
    result['add-script'] = argResults['add-script'];
    result['help'] = argResults['help'];
    result['log-level'] = argResults['log-level'];

    if (result['log-level'] != null) {
      const choices = const {
        'all': Level.ALL,
        'config': Level.CONFIG,
        'fine': Level.FINE,
        'finer': Level.FINER,
        'finest': Level.FINEST,
        'info': Level.INFO,
        'levels': Level.LEVELS,
        'off': Level.OFF,
        'severe': Level.SEVERE,
        'shout': Level.SHOUT,
        'warning': Level.WARNING
      };
      final selection = choices[result['log-level'].toLowerCase()];
      if (selection != null) Logger.root.level = selection;
    }

    return {'options': result, 'rest': argResults.rest};
  } catch (e) {
    _usage();
    throw e;
  }
}
final _logger = new Logger('bootstrapEbisuCpp');
class Project {
  Project._default();

  Id id;
  String rootPath;
  String codegenPath;
  String scriptName;
  String ebisuFilePath;
  String cppFilePath;

  // custom <class Project>
  // end <class Project>

  toString() => '(${runtimeType}) => ${ebisu.prettyJsonMap(toJson())}';

  Map toJson() => {
    "id": ebisu.toJson(id),
    "rootPath": ebisu.toJson(rootPath),
    "codegenPath": ebisu.toJson(codegenPath),
    "scriptName": ebisu.toJson(scriptName),
    "ebisuFilePath": ebisu.toJson(ebisuFilePath),
    "cppFilePath": ebisu.toJson(cppFilePath),
  };

  static Project fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Project._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    id = Id.fromJson(jsonMap["id"]);
    rootPath = jsonMap["rootPath"];
    codegenPath = jsonMap["codegenPath"];
    scriptName = jsonMap["scriptName"];
    ebisuFilePath = jsonMap["ebisuFilePath"];
    cppFilePath = jsonMap["cppFilePath"];
  }
}
main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  // custom <bootstrapEbisuCpp main>
  // end <bootstrapEbisuCpp main>

}

// custom <bootstrapEbisuCpp global>
// end <bootstrapEbisuCpp global>
