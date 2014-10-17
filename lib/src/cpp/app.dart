part of ebisu_cpp.cpp;

class ArgType implements Comparable<ArgType> {
  static const INT = const ArgType._(0);
  static const DOUBLE = const ArgType._(1);
  static const STRING = const ArgType._(2);

  static get values => [
    INT,
    DOUBLE,
    STRING
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
    }
    return null;
  }

  static ArgType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Int": return INT;
      case "Double": return DOUBLE;
      case "String": return STRING;
      default: return null;
    }
  }

}

class AppArg extends Entity {

  ArgType type;
  String shortName;
  bool isMultiple = false;
  bool isRequired = false;
  Object get defaultValue => _defaultValue;

  // custom <class AppArg>

  get name => id.snake;

  AppArg(Id id) : super(id);

  set defaultValue(Object defaultValue) {
    if(type == null) {
      type =
        defaultValue is String? String :
        defaultValue is double? Double :
        defaultValue is int? Int;
    }
    _defaultValue = defaultValue;
  }

  // end <class AppArg>
  Object _defaultValue;
}

class App extends Entity with InstallationCodeGenerator {

  List<AppArg> args = [];
  List<Class> classes = [];

  // custom <class App>

  App(Id id) : super(id);

  get name => id.snake;
  get appPath => path.join(installation.root, 'app', name);

  generate() {
    _namespace = namespace([ 'fcs', 'app', id.snake ]);
    print('Generating app $id');
    final cppMain = new Impl(id)
      ..namespace = _namespace
      ..setAppFilePathFromRoot(installation.root)
      ..getCodeBlock(fcbPostNamespace).snippets.add(_cppContents)
      ..generate();

    new JamAppBuilder(this).generate();
  }

  get _cppContents => '''

int main(int argc, char** argv) {
  ${_namespace.using};

  return 0;
}
''';

  // end <class App>
  Namespace _namespace;
}

/// Creates builder for an application
abstract class AppBuilder implements CodeGenerator {

  AppBuilder(this.app);

  App app;

  // custom <class AppBuilder>
  // end <class AppBuilder>
}

class JamAppBuilder extends AppBuilder {


  // custom <class JamAppBuilder>

  get app => super.app;
  get appName => app.name;

  JamAppBuilder(App app) : super(app);

  void generate() {
    final targetFile = path.join(app.appPath, 'Jamfile.v2');
    mergeBlocksWithFile('''
import os ;
project $appName
    :
    :
    ;
ENV_CXXFLAGS = [ os.environ CXXFLAGS ] ;
ENV_LINKFLAGS = [ os.environ LINKFLAGS ] ;
SOURCES =
     date_time_converter_program_options
;

exe date_time_converter
    : $appName.cpp
      \$(SOURCES).cpp
      /site-config//boost_program_options
      /site-config//boost_date_time
      /site-config//boost_regex
      \$(PANTHEIOS_LIBS)
    : <define>DEBUG_FCS_STARTUP
      <cxxflags>\$(ENV_CXXFLAGS)
      <linkflags>\$(ENV_LINKFLAGS)
      <variant>debug:<define>DEBUG
      <variant>release:<define>NDEBUG
    ;

install install_app : $appName :
   <link>static
      <variant>debug:<location>\$(FCS_INSTALL_PATH)/static/debug
      <variant>release:<location>\$(FCS_INSTALL_PATH)/static/release
;

install install_app : $appName :
   <link>shared
      <variant>debug:<location>\$(FCS_INSTALL_PATH)/shared/debug
      <variant>release:<location>\$(FCS_INSTALL_PATH)/shared/release
;

explicit install_app ;

''', targetFile);
    print('...Generating Jamfile for ${app.id} at $targetFile');
  }

  // end <class JamAppBuilder>
}
// custom <part app>

AppArg arg(Object name) =>
  new AppArg(name is String? new Id(name) : name);

// end <part app>
