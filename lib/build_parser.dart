library ebisu_cpp.build_parser;

import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:quiver/iterables.dart';

// end <additional imports>

final _logger = new Logger('build_parser');

class Flag {
  const Flag(this.name, this.value);

  final String name;
  final String value;

  // custom <class Flag>

  toString() => 'Flag($name=$value)';

  // end <class Flag>

}

class Define {
  const Define(this.id, this.value);

  final String id;
  final String value;

  // custom <class Define>

  toString() => 'Define($id=$value)';

  // end <class Define>

}

class IncludePath {
  const IncludePath(this.path, this.isSystem);

  final String path;
  final bool isSystem;

  // custom <class IncludePath>

  toString() => 'Include($path:system=$isSystem)';

  // end <class IncludePath>

}

class Library {
  const Library(this.name);

  final String name;

  // custom <class Library>
  // end <class Library>

}

class CompileCommand {
  CompileCommand(
      {command,
      sourcePaths,
      defines,
      includePaths,
      compileWarningFlags,
      compileFlags,
      isLinked,
      outputFile})
      : _command = command,
        _sourcePaths = sourcePaths ?? [],
        _defines = defines ?? [],
        _includePaths = includePaths ?? [],
        _compileWarningFlags = compileWarningFlags ?? [],
        _compileFlags = compileFlags ?? [],
        _isLinked = isLinked ?? false,
        _outputFile = outputFile;

  String get command => _command;
  List<String> get sourcePaths => _sourcePaths;
  List<Define> get defines => _defines;
  List<IncludePath> get includePaths => _includePaths;
  List<Flag> get compileWarningFlags => _compileWarningFlags;
  List<Flag> get compileFlags => _compileFlags;

  /// -c is *not* specified
  bool get isLinked => _isLinked;

  /// -o file flag
  String get outputFile => _outputFile;

  // custom <class CompileCommand>
  // end <class CompileCommand>

  String _command;
  List<String> _sourcePaths = [];
  List<Define> _defines = [];
  List<IncludePath> _includePaths = [];
  List<Flag> _compileWarningFlags = [];
  List<Flag> _compileFlags = [];
  bool _isLinked = false;
  String _outputFile;
}

class CompileCommandParser {
  CompileCommandParser(this._compileCommand) {
    // custom <parse compile command>

    _commandLineParser = new CommandLineParser(compileCommand);

    final defines = [];
    final includePaths = [];
    final compileWarningFlags = [];
    final compileFlags = [];
    bool isLinked = true;
    String outputFile;

    _commandLineParser.argDetails
        .where((ad) => ad.parsedOption != null)
        .forEach((ArgDetails argDetails) {
      final parsedOption = argDetails.parsedOption;
      final optName = parsedOption.name;
      if (optName.startsWith('-D')) {
        defines.add(new Define(optName.substring(2), parsedOption.value));
      } else if (optName.startsWith('-I')) {
        includePaths.add(new IncludePath(optName.substring(2), false));
      } else if (optName.startsWith('-isystem')) {
        includePaths.add(new IncludePath(optName.substring(8), true));
      } else if (optName.startsWith('-W')) {
        compileWarningFlags
            .add(new Flag(optName.substring(2), parsedOption.value));
      } else if (optName == '-c') {
        isLinked = false;
      } else if (optName == '-o') {
        outputFile = parsedOption.value;
      } else {
        compileFlags.add(new Flag(optName, parsedOption.value));
      }
    });

    _logger.info('''
----- Original -----
$compileCommand
--------------------
Defines are\n${indentBlock(brCompact(defines))}
Includes are\n${indentBlock(brCompact(includePaths))}
Warnings are\n${indentBlock(brCompact(compileWarningFlags))}
Remaining flags are\n${indentBlock(brCompact(compileFlags))}
isLinked => $isLinked
outputFile => $outputFile
''');

    // end <parse compile command>
  }

  String get compileCommand => _compileCommand;
  CommandLineParser get commandLineParser => _commandLineParser;

  // custom <class CompileCommandParser>

  toString() => _commandLineParser;

  // end <class CompileCommandParser>

  String _compileCommand;
  CommandLineParser _commandLineParser;
}

class ArCommand {
  ArCommand({command, sourcePath, arFlags})
      : _command = command,
        _sourcePath = sourcePath,
        _arFlags = arFlags ?? [];

  String get command => _command;
  String get sourcePath => _sourcePath;
  List<Flag> get arFlags => _arFlags;

  // custom <class ArCommand>
  // end <class ArCommand>

  String _command;
  String _sourcePath;
  List<Flag> _arFlags = [];
}

class ArCommandParser {
  // custom <class ArCommandParser>

  ArCommand parseCompile(String arCommand) {}

  // end <class ArCommandParser>

}

class LinkCommand {
  LinkCommand({command, sourcePath, linkFlags, libPaths, libraries})
      : _command = command,
        _sourcePath = sourcePath,
        _linkFlags = linkFlags ?? [],
        _libPaths = libPaths ?? [],
        _libraries = libraries ?? [];

  String get command => _command;
  String get sourcePath => _sourcePath;
  List<Flag> get linkFlags => _linkFlags;
  List<String> get libPaths => _libPaths;
  List<Library> get libraries => _libraries;

  // custom <class LinkCommand>
  // end <class LinkCommand>

  String _command;
  String _sourcePath;
  List<Flag> _linkFlags = [];
  List<String> _libPaths = [];
  List<Library> _libraries = [];
}

class LinkCommandParser {
  // custom <class LinkCommandParser>
  // end <class LinkCommandParser>

}

class BuildParser {
  BuildParser(this._inputFile, [compileMatcher])
      : _compileMatcher = compileMatcher ??
            new RegExp(r"^\s*[\w/.]*(?:g(?:\+\+|cc)|clang)-?[\w.]*\s+(.*)") {
    // custom <parse build log>

    _logContents = new File(_inputFile).readAsLinesSync();

    _logContents.forEach((var line) {
      var match;
      if ((match = _compileMatcher.firstMatch(line)) != null) {
        final remainder = match.group(1);
        final commandParser = new CompileCommandParser(remainder);
      }
    });

    // end <parse build log>
  }

  String get inputFile => _inputFile;
  RegExp get compileMatcher => _compileMatcher;
  List<String> get logContents => _logContents;

  // custom <class BuildParser>
  // end <class BuildParser>

  String _inputFile;
  RegExp _compileMatcher =
      new RegExp(r"^\s*[\w/.]*(?:g(?:\+\+|cc)|clang)-?[\w.]*\s+(.*)");
  List<String> _logContents = [];
}

// custom <library build_parser>

// end <library build_parser>
