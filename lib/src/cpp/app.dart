part of ebisu_cpp.cpp;

/// Set of argument types supported by command line option processing
class ArgType implements Comparable<ArgType> {
  static const INT = const ArgType._(0);
  static const DOUBLE = const ArgType._(1);
  static const STRING = const ArgType._(2);
  static const FLAG = const ArgType._(3);

  static get values => [
    INT,
    DOUBLE,
    STRING,
    FLAG
  ];

  final int value;

  int get hashCode => value;

  const ArgType._(this.value);

  copy() => this;

  int compareTo(ArgType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case INT: return "Int";
      case DOUBLE: return "Double";
      case STRING: return "String";
      case FLAG: return "Flag";
    }
    return null;
  }

  static ArgType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Int": return INT;
      case "Double": return DOUBLE;
      case "String": return STRING;
      case "Flag": return FLAG;
      default: return null;
    }
  }

}


/// Metadata associated with an argument to an application.  Requires and
/// geared to features supported by boost::program_options.
///
class AppArg extends Entity {
  ArgType type = ArgType.STRING;
  String shortName;
  bool isMultiple = false;
  bool isRequired = false;
  Object get defaultValue => _defaultValue;
  // custom <class AppArg>

  // Name as variable
  get name => id.snake;

  // Name as used in command
  get optName => id.emacs;

  AppArg(Id id) : super(id);

  set defaultValue(Object defaultValue) {
    type =
      defaultValue is String? ArgType.STRING :
      defaultValue is double? ArgType.DOUBLE :
      defaultValue is int? ArgType.INT :
      defaultValue is bool? ArgType.FLAG : null;

    _defaultValue = defaultValue;
  }

  get vname => '${name}_';
  get isString => type == ArgType.STRING;
  get defaultValueLit => isString? quote(defaultValue) : defaultValue;

  get cppType =>
    isMultiple ? (type == ArgType.INT ? 'std::vector< int >' :
        type == ArgType.DOUBLE ? 'std::vector< double >' :
        type == ArgType.STRING ? 'std::vector< std::string >' : 'std::vector< bool >') :
    (type == ArgType.INT ? 'int' :
        type == ArgType.DOUBLE ? 'double' :
        type == ArgType.STRING ? 'std::string' : 'bool');

  get flagDecl =>
    shortName == null?
    '"${id.emacs}"' : '"${id.emacs},$shortName"';

  get _defaultValueSet =>
    _defaultValue == null?
    '' :
    '->default_value($defaultValueLit)';

  get addOptionDecl =>
    type == ArgType.FLAG?
    '($flagDecl, "$descr")' :
    '($flagDecl, value< $cppType >()$_defaultValueSet,\n  "${descr}")';

  // end <class AppArg>
  Object _defaultValue;
}

/// A c++ application
class App extends Impl with InstallationCodeGenerator {
  /// Command line arguments specific to this application
  List<AppArg> args = [];
  /// Additional headers that are associated with the application itself, as
  /// opposed to belonging to a reusable library.
  List<Header> headers = [];
  /// Additional implementation files associated with the application
  /// itself, as opposed to belonging to a reusable library.
  List<Impl> impls = [];
  /// Libraries required to build this executable. *Warning* potentially
  /// deprecated in the future. Originally when generating boost jam files
  /// it was convenient to associate the required libraries directly in the
  /// code generation scripts. With cmake it was simpler to just incorporate
  /// protect blocks where the required libs could be easily added.
  List<String> requiredLibs = [];
  /// List of builders to generate build scripts of a desired flavor (bjam,...)
  List<AppBuilder> builders = [];
  // custom <class App>

  App(Id id) : super(id);

  get name => id.snake;
  get cppPath => path.join(installation.root, 'cpp');
  get appPath => path.join(cppPath, 'app', name);
  get namespace => super.namespace;
  get sources => [ id.snake ]..addAll(impls.map((i) => i.id.snake));
  get allIncludes =>
    new Includes(_includes.includeEntries)
    ..addAll(concat(headers.map((h) => h.includes.includeEntries)))
    ..addAll(concat(impls.map((i) => i.includes.includeEntries)));

  generate() {
    if(namespace == null) throw Exception('App $id requires a namespace');
    if(!args.any((a) => _isHelpArg(a) || a.shortName == 'h')) {
      args.insert(0,
          new AppArg(new Id('help'))
          ..shortName = 'h'
          ..defaultValue = false
          ..descr = 'Display help information');
    }
    _includes.add('iostream');
    if(args.isNotEmpty)
      _includes.add('boost/program_options.hpp');

    setAppFilePathFromRoot(cppPath);
    getCodeBlock(fcbPostNamespace).snippets.add(_cppContents);
    classes.add(_programOptions);

    if(_hasMultiple) {
      _includes.addAll(['vector', 'fcs/utils/streamers/containers.hpp']);
    }

    if(_hasString)
      _includes.add('string');

    super.generate();

    if(installation.wantsJam) {
      builders.add(new JamAppBuilder.fromApp(this));
    }

    for(var appBuilder in builders) {
      appBuilder.generateBuildScripts(this);
    }
  }

  get _hasMultiple => args.any((a) => a.isMultiple);
  get _hasString => args.any((a) => ArgType.STRING == a.type);
  get _hasHelp => args.any((a) => _isHelpArg(a));

  get _programOptions =>
    class_('program_options')
    ..struct = true
    ..streamable = true
    ..usesStreamers = _hasMultiple
    ..members = args.map((a) =>
        member(a.id)
        ..byRef = a.isMultiple || a.isString
        ..type = a.cppType
        ..access = ro).toList()
    ..getCodeBlock(clsPublic).snippets.add(_argvCtor);

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
  char const* descr = R"(
$descr

AllowedOptions)";

  static options_description options { descr };

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

  get _orderedArgs =>
    concat([
      args.where((a) => _isHelpArg(a)),
      args.where((a) => !_isHelpArg(a))]);

  bool _isHelpArg(AppArg arg) => arg.optName == 'help';
  get _helpArg => args.where((a) => _isHelpArg(a));

  _readFlag(AppArg arg) =>
    'parsed_options.count("${arg.optName}") > 0';

  _pullOption(AppArg arg) => _isHelpArg(arg)?
    '''
if(parsed_options.count("${arg.optName}") > 0) {
  help_ = true;
  return;
}''' : arg == null? null :
    arg.type == ArgType.FLAG? '''
${arg.vname} = ${_readFlag(arg)};
''' :
    (arg.defaultValue != null?
    '''
${arg.vname} = parsed_options["${arg.optName}"]
  .as< ${arg.cppType} >();''' :
    '''
if(parsed_options.count("${arg.optName}") > 0) {
  ${arg.vname} = parsed_options["${arg.optName}"]
    .as< ${arg.cppType} >();
}${_failIfRequired(arg)}''');

  String _failIfRequired(AppArg arg) =>
    arg.isRequired ? '''
 else {
  std::ostringstream msg;
  msg << "$id option '${arg.optName}' is required";
  throw std::runtime_error(msg.str());
}''' : '';


  get _cppContents => '''

int main(int argc, char** argv) {
${
  combine([
    indentBlock(namespace.using) + ';',
    indentBlock('''
try{
${indentBlock(_readProgramOptions)}
${indentBlock(customBlock('main'))}
} catch(std::exception const& e) {
  std::cout << "Caught exception: " << e.what() << std::endl;
  Program_options::show_help(std::cout);
  return -1;
}
'''),
  ])
}
  return 0;
}
''';

  get _showHelp => _hasHelp? '''
if(options.help()) {
  Program_options::show_help(std::cout);
  return 0;
}
''' : null;

  get _readProgramOptions => args.isEmpty? null :
    combine([
      'Program_options options = { argc, argv };',
      _showHelp,
    ]);

  // end <class App>
  /// Namespace associated with application code
  Namespace _namespace;
}

/// Base class establishing interface for generating build scripts for
/// libraries, apps, and tests
abstract class AppBuilder
  implements CodeGenerator {
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
        if(include.contains(header)) found.add(requirement);
      });
    });
    return found;
  }

  generateBuildScripts(App app) {
    this.app = app;
    generate();
  }

  static const Map _headerToLibRequirement = const {
    'boost/program_options.hpp' : 'boost_program_options',
    'boost/date_time' : 'boost_date_time',
    'boost/regex' : 'boost_regex',
  };

  // end <class AppBuilder>
}
// custom <part app>

AppArg arg(Object name) =>
  new AppArg(name is String? new Id(name) : name);

// end <part app>
