#!/usr/bin/env dart

/// Finds includes that look like classes
import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
// custom <additional imports>

import 'package:ebisu_cpp/qt_support.dart';
import 'package:path/path.dart';
import 'package:ebisu/ebisu.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>
//! The parser for this script
ArgParser _parser;
//! The comment and usage associated with this script
void _usage() {
  print(r'''
Finds includes that look like classes
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
    _parser.addFlag('help',
        help: r'''
Display this help screen
''',
        abbr: 'h',
        defaultsTo: false);

    _parser.addOption('qt-include-path',
        help: r'''
Where to find includes
''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: 'p',
        allowed: null);
    _parser.addOption('log-level',
        help: r'''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]

''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: null,
        allowed: null);

    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    if (argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
    result['qt-include-path'] = argResults['qt-include-path'];
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

final _logger = new Logger('qtClassFinder');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
  // custom <qtClassFinder main>

  Logger.root.level = Level.WARNING;
  final headerPath = options['qt-include-path'];
  final headerDir = new Directory(headerPath);
  final qtHeaders = headerDir
      .listSync(recursive: true)
      .where((fe) => fe is File && looksLikeQtHeader(fe.path));

  final results = {};
  final byCategory = {};

  qtHeaders.forEach((var fe) {
    final headerPath = fe.path;
    final headerBasename = basename(fe.path);
    final namespace = basename(dirname(headerPath));
    if (results[headerBasename] != null) {
      _logger.warning(
          '$headerBasename already => ${results[headerBasename]} changing to $namespace');
    }
    results[headerBasename] = namespace;
    byCategory.putIfAbsent(namespace, () => []).add(headerBasename);
  });

  final literal = brCompact([
    'final qtClassToNamespace = {',
    enumerate(results.keys)
        .map((iv) => (iv.index % 4) == 3
            ? '  "${iv.value}" : "${results[iv.value]}",\n'
            : '  "${iv.value}" : "${results[iv.value]}", ')
        .join(),
    '}'
  ]);

  print(literal);

  // end <qtClassFinder main>
}

// custom <qtClassFinder global>
// end <qtClassFinder global>
