part of ebisu_cpp.ebisu_cpp;

/// Set of argument types supported by command line option processing.
///
class ArgType implements Comparable<ArgType> {
  static const INT = const ArgType._(0);
  static const DOUBLE = const ArgType._(1);
  static const STRING = const ArgType._(2);
  static const FLAG = const ArgType._(3);

  static get values => [INT, DOUBLE, STRING, FLAG];

  final int value;

  int get hashCode => value;

  const ArgType._(this.value);

  copy() => this;

  int compareTo(ArgType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case INT:
        return "Int";
      case DOUBLE:
        return "Double";
      case STRING:
        return "String";
      case FLAG:
        return "Flag";
    }
    return null;
  }

  static ArgType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "Int":
        return INT;
      case "Double":
        return DOUBLE;
      case "String":
        return STRING;
      case "Flag":
        return FLAG;
      default:
        return null;
    }
  }
}

/// Metadata associated with an argument to an application.  Requires and
/// geared to features supported by boost::program_options. The supporting
/// code for arguments is spread over a few places in the main file of an
/// [App]. Examples of declarations follow:
///
///       print(br([
///         appArg('filename')
///         ..shortName = 'f',
///
///         appArg('in_file')
///         ..shortName = 'f'
///         ..defaultValue = 'input.txt',
///
///         appArg('pi')
///         ..shortName = 'p'
///         ..isRequired = true
///         ..defaultValue = 3.14,
///
///         appArg('source_file')
///         ..shortName = 's'
///         ..isMultiple = true
///       ]));
///
/// Prints:
///
///     AppArg(filename)
///       argType: String
///       cppType: std::string
///       flagDecl: "filename,f"
///       isRequired: false
///       isMultiple: false
///       defaultValue: null
///
///     AppArg(in_file)
///       argType: String
///       cppType: std::string
///       flagDecl: "in-file,f"
///       isRequired: false
///       isMultiple: false
///       defaultValue: input.txt
///
///     AppArg(pi)
///       argType: Double
///       cppType: double
///       flagDecl: "pi,p"
///       isRequired: true
///       isMultiple: false
///       defaultValue: 3.14
///
///     AppArg(source_file)
///       argType: String
///       cppType: std::vector< std::string >
///       flagDecl: "source-file,s"
///       isRequired: false
///       isMultiple: true
///       defaultValue: null
///
///
/// For an [App], if no [Arg] in [args] is named *help* or has [shortName]
/// of *h* then the following *help* argument is provided. The help text
/// will include the doc string of the [App].
///
///       args.insert(0, new AppArg(new Id('help'))
///         ..shortName = 'h'
///         ..defaultValue = false
///         ..descr = 'Display help information');
///
///
/// Example: Here are the [AppArg]s of an simple application:
///
///     arg('timestamp')
///     ..shortName = 't'
///     ..descr = 'Some form of timestamp'
///     ..isMultiple = true
///     ..type = ArgType.STRING,
///     arg('date')
///     ..shortName = 'd'
///     ..descr = 'Some form of date'
///     ..isMultiple = true
///     ..type = ArgType.STRING,
///
/// When run, the help looks something like:
///
///     App for converting between various forms of date/time
///
///     AllowedOptions:
///       -h [ --help ]          Display help information
///       -t [ --timestamp ] arg Some form of timestamp
///       -d [ --date ] arg      Some form of date
class AppArg extends CppEntity {
  ArgType type = ArgType.STRING;
  String shortName;
  bool isMultiple = false;
  bool isRequired = false;
  Object get defaultValue => _defaultValue;

  // custom <class AppArg>

  AppArg(Id id) : super(id);

  // Name as variable
  get name => namer.nameApp(id);

  // Name as used in command
  get optName => id.emacs;

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  set defaultValue(Object defaultValue) {
    type = defaultValue is String
        ? ArgType.STRING
        : defaultValue is int
            ? ArgType.INT
            : defaultValue is double
                ? ArgType.DOUBLE
                : defaultValue is bool ? ArgType.FLAG : null;

    _defaultValue = defaultValue;
  }

  get vname => namer.nameMemberVar(id, false);
  get isString => type == ArgType.STRING;
  get defaultValueLit => isString ? doubleQuote(defaultValue) : defaultValue;

  get cppType => isMultiple
      ? (type == ArgType.INT
          ? 'std::vector< int >'
          : type == ArgType.DOUBLE
              ? 'std::vector< double >'
              : type == ArgType.STRING
                  ? 'std::vector< std::string >'
                  : 'std::vector< bool >')
      : (type == ArgType.INT
          ? 'int'
          : type == ArgType.DOUBLE
              ? 'double'
              : type == ArgType.STRING ? 'std::string' : 'bool');

  get flagDecl =>
      shortName == null ? '"${id.emacs}"' : '"${id.emacs},$shortName"';

  get _defaultValueSet =>
      _defaultValue == null ? '' : '->default_value($defaultValueLit)';

  get addOptionDecl => type == ArgType.FLAG
      ? '($flagDecl, "$descr")'
      : '($flagDecl, value< $cppType >()$_defaultValueSet,\n  "${descr}")';

  toString() => '''
AppArg(${id.snake})
  argType: $type
  cppType: $cppType
  flagDecl: $flagDecl
  isRequired: $isRequired
  isMultiple: $isMultiple
  defaultValue: $defaultValue
''';

  // end <class AppArg>

  Object _defaultValue;
}

///
/// A C++ application. Application related files are generated in location based on
/// [namespace] the namespace. For example, the following code:
///
///     app('date_time_converter')
///       ..namespace = namespace(['fcs'])
///       ..args = [
///         arg('timestamp')
///         ..shortName = 't'
///         ..descr = 'Some form of timestamp'
///         ..isMultiple = true
///         ..type = ArgType.STRING,
///         arg('date')
///         ..shortName = 'd'
///         ..descr = 'Some form of date'
///         ..isMultiple = true
///         ..type = ArgType.STRING,
///       ];
///
/// will generate a C++ file containing *main* at location:
///
///     $root/cpp/app/date_time_converter/date_time_converter.cpp
///
/// Since [App] extends [Impl] it supports local instances of
/// [constExprs] [usings], [enums], [forwardDecls], and [classes],
/// as well as [headers] and [impls] which may be part of the
/// application and not necessarily suited for a separate library.
class App extends Impl implements CodeGenerator {

  /// Command line arguments specific to this application
  List<AppArg> args = [];
  /// Additional headers that are associated with the application itself, as
  /// opposed to belonging to a reusable library.
  List<Header> headers = [];
  /// Additional implementation files associated with the
  /// application itself, as opposed to belonging to a reusable
  /// library.
  List<Impl> impls = [];
  /// Libraries required to build this executable. *Warning* potentially
  /// deprecated in the future. Originally when generating boost jam files
  /// it was convenient to associate the required libraries directly in the
  /// code generation scripts. With cmake it was simpler to just incorporate
  /// protect blocks where the required libs could be easily added.
  List<String> requiredLibs = [];
  /// An App is an Impl and therefore contains accesors to FileCodeBlock
  /// sections (e.g. fcbBeginNamespace, fcbPostNamespace, ...). The heart of
  /// an application impl file is the main, so this [CodeBlock] supports
  /// injecting code in main
  CodeBlock mainCodeBlock = new CodeBlock('main');
  /// If true adds --log-level to the set of options for the app. This app
  /// argument will default the app to having no logging, but allow user
  /// control.
  bool hasLogLevel = false;
  /// If true support for handling signals included in app
  bool hasSignalHandler = false;
  /// If true adds quit loop at end of main.
  ///
  /// The quit loop loops as:
  ///
  ///     do {
  ///       std::cout << "Enter 'q' or 'Q' to quit'" << std::endl;
  ///       if(c == 'q' || c == 'Q') {
  ///         break;
  ///       }
  ///     } while(std::cin >> c);
  bool hasQuitLoop = false;

  // custom <class App>

  App(Id id) : super(id);

  Iterable<Entity> get children =>
      concat([super.children, args, headers, impls]);

  /// Name of the application in *snake* case
  get name => id.snake;
  /// Path to the directory containing C++ code. Determined by [Installation] root path
  get cppPath => path.join(this.installation.rootFilePath, 'cpp');
  /// Path to the app directory containing all apps generated by this [Installation]
  get appPath => path.join(cppPath, 'app', name);
  /// Namespace for application code
  get namespace => super.namespace;
  /// List of sources names *snake case* required for this application.
  /// Primarily here for determining what to put in build scripts
  get sources => [id.snake]..addAll(impls.map((i) => i.id.snake));

  get installation => super.installation;

  onOwnershipEstablished() {
    if (namespace == null) throw new Exception('App $id requires a namespace');

    _checkAddLogLevel();
    _checkAddHelp();
    _includes.add('iostream');
    if (hasSignalHandler) _includes
        .add('ebisu/linux_specific/application_signal_handler.hpp');
    if (args.isNotEmpty) _includes.add('boost/program_options.hpp');
    setAppFilePathFromRoot(cppPath);

    getCodeBlock(fcbBeginNamespace).snippets.add(brCompact([
      '''
namespace {
  char const* app_descr = R"(''',
      br([brief, descr]),
      '''

AllowedOptions)";
}'''
    ]));

    getCodeBlock(fcbPostNamespace).snippets.add(_cppContents);
    classes.add(_programOptions);

    if (_hasMultiple) {
      _includes.addAll(['vector', 'ebisu/utils/streamers/containers.hpp']);
    }

    if (_hasString) _includes.add('string');
  }

  void _checkAddHelp() {
    if (!args.any((a) => _isHelpArg(a) || a.shortName == 'h')) {
      args.insert(0, new AppArg(new Id('help'))
        ..shortName = 'h'
        ..defaultValue = false
        ..descr = 'Display help information');
    }
  }

  void _checkAddLogLevel() {
    if (hasLogLevel) {
      args.add(arg('log_level')
        ..type = ArgType.STRING
        ..doc = '''
Specify log level [trace, debug, info, notice, warn, err, critical, alert, emerg, off]'''
        ..defaultValue = 'off');
      _includes.addAll(root.logProvider.includeRequirements.included);
    } else {
      args.removeWhere((arg) => arg.id.snake == 'log_level');
    }
  }

  get _hasMultiple => args.any((a) => a.isMultiple);
  get _hasString => args.any((a) => ArgType.STRING == a.type);
  get _hasHelp => args.any((a) => _isHelpArg(a));

  get _programOptions => class_('program_options')
    ..isStruct = true
    ..isStreamable = true
    ..usesStreamers = _hasMultiple
    ..members = args.map((a) => member(a.id)
      ..isByRef = a.isMultiple || a.isString
      ..type = a.cppType
      ..access = ro).toList()
    ..getCodeBlock(clsOpen).snippets.add(_argvCtor);

  get _argvCtor => '''
Program_options(int argc, char** argv) {
  using namespace boost::program_options;
  variables_map parsed_options;
  store(parse_command_line(argc, argv, description()), parsed_options);
${
indentBlock(combine(_orderedArgs.map((a) => br(_pullOption(a)))))
}
}

static boost::program_options::options_description const& description() {
  using namespace boost::program_options;
  static options_description options { app_descr };

  if(options.options().empty()) {
    options.add_options()
${
  indentBlock(combine(args.map((a) => a.addOptionDecl)), '    ')
};
  }
  return options;
}

static void show_help(std::ostream& out) {
  out << description();
  out.flush();
}
''';

  get _orderedArgs => concat(
      [args.where((a) => _isHelpArg(a)), args.where((a) => !_isHelpArg(a))]);

  bool _isHelpArg(AppArg arg) => arg.optName == 'help';
  get _helpArg => args.where((a) => _isHelpArg(a));

  _readFlag(AppArg arg) => 'parsed_options.count("${arg.optName}") > 0';

  _pullOption(AppArg arg) => _isHelpArg(arg)
      ? '''
if(parsed_options.count("${arg.optName}") > 0) {
  help_ = true;
  return;
}'''
      : arg == null
          ? null
          : arg.type == ArgType.FLAG
              ? '''
${arg.vname} = ${_readFlag(arg)};
'''
      : (arg.defaultValue != null
          ? '''
${arg.vname} = parsed_options["${arg.optName}"]
  .as< ${arg.cppType} >();'''
      : '''
if(parsed_options.count("${arg.optName}") > 0) {
  ${arg.vname} = parsed_options["${arg.optName}"]
    .as< ${arg.cppType} >();
}${_failIfRequired(arg)}''');

  String _failIfRequired(AppArg arg) => arg.isRequired
      ? '''
 else {
  std::ostringstream msg;
  msg << "$id option '${arg.optName}' is required";
  throw boost::program_options::error(msg.str());
}'''
      : '';

  get _quitLoop => hasQuitLoop
      ? '''

    //////////////////////////////////////////////////////////////////////
    // Basic loop until q or Q is entered
    //////////////////////////////////////////////////////////////////////
    char c {0};
    do {
      if(c == \'q\' || c == \'Q\') {
        break;
      } else if(c != 0) {
        std::cout << "Invalid input to quit loop: " << c << std::endl;
      }
      std::cout << "Enter \'q\' or \'Q\' to quit" << std::endl;
    } while(std::cin >> c);

    //////////////////////////////////////////////////////////////////////
    // Any cleanup work required after quit loop exit
    //////////////////////////////////////////////////////////////////////
${indentBlock(customBlock('$name post quit loop'), '    ')}
'''
      : null;

  get _cppContents => brCompact([
    'int main(int argc, char** argv) {',
    combine([
      namespace.using + ';',
      hasSignalHandler
          ? '''

////////////////////////////////////////////////////////////////////////////
// Ensure RAII clean up of signal handler thread
////////////////////////////////////////////////////////////////////////////
ebisu::linux_specific::Application_signal_handler_exit signal_handler_cleanup__;

////////////////////////////////////////////////////////////////////////////
// Add signal handlers
////////////////////////////////////////////////////////////////////////////
{
  auto &signal_handler = ebisu::linux_specific::Application_signal_handler<>::instance();
${indentBlock(customBlock('$name add signal handlers'))}
}
'''
          : null,
      '''
try{
${_readProgramOptions}
''',
      hasLogLevel ? root.logProvider.setLogLevel('options.log_level()') : null,
      '''
//////////////////////////////////////////////////////////////////////
// User supplied $name protect block
//////////////////////////////////////////////////////////////////////
${indentBlock(mainCodeBlock.toString())}
''',
      _quitLoop,
      '''
} catch(boost::program_options::error const& e) {
  std::cerr << "Caught boost program options exception: " << e.what() << std::endl;
  Program_options::show_help(std::cout);
  return -1;
} catch(std::exception const& e) {
  std::cerr << "Caught exception: " << e.what() << std::endl;
  return -1;
}''',
      '''
return 0;
}
'''
    ])
  ]);

  get _showHelp => _hasHelp
      ? '''
if(options.help()) {
  Program_options::show_help(std::cout);
  return 0;
}
'''
      : null;

  get _readProgramOptions => args.isEmpty
      ? null
      : combine([
    '''
//////////////////////////////////////////////////////////////////////
// Read program options and display help if requested
//////////////////////////////////////////////////////////////////////
''',
    'Program_options options = { argc, argv };',
    _showHelp,
  ]);

  // end <class App>

}

/// Base class establishing interface for generating build scripts for
/// libraries, apps, and tests
abstract class AppBuilder implements CodeGenerator {
  App app;

  // custom <class AppBuilder>

  AppBuilder();
  AppBuilder.fromApp(this.app);

  get installation => app.installation;
  get appName => app.name;
  get appPath => app.appPath;
  get sources => app.sources;

  get libs => detectLibsFromIncludes()..addAll(app.requiredLibs);

  Set<String> detectLibsFromIncludes() {
    final found = new Set<String>();
    app.allIncludes.includeEntries.forEach((String include) {
      _headerToLibRequirement.forEach((String header, String requirement) {
        if (include.contains(header)) found.add(requirement);
      });
    });
    return found;
  }

  generateBuildScripts(App app) {
    this.app = app;
    this.generate();
  }

  static const Map _headerToLibRequirement = const {
    'boost/program_options.hpp': 'boost_program_options',
    'boost/date_time': 'boost_date_time',
    'boost/regex': 'boost_regex',
  };

  // end <class AppBuilder>

}

// custom <part app>

/// Alias for [appArg]
AppArg arg(Object name) => new AppArg(name is String ? new Id(name) : name);

/// Convenience function for creating an [AppArg]
///
/// All [AppArg]s must be named wiht an [Id]. This method accepts an [Id] or
/// creates one. Creation of [Id] requires a string in *snake case*
AppArg appArg(name) => arg(name);

// end <part app>
