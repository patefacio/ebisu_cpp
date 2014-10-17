part of ebisu_cpp.cpp;

/// A CodeGenerator tied to a c++ installation
abstract class InstallationCodeGenerator implements CodeGenerator {

  Installation installation;

  // custom <class InstallationCodeGenerator>
  // end <class InstallationCodeGenerator>
}

class App extends Entity with InstallationCodeGenerator {

  List<Class> classes = [];

  // custom <class App>

  App(Id id) : super(id);

  get appPath => path.join(installation.root, 'apps', id.snake);

  generate() {
    print('Generating app $id');
    new JamAppBuilder(this).generate();
  }

  // end <class App>
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

  JamAppBuilder(App app) : super(app);

  void generate() {
    final targetFile = path.join(app.appPath, 'Jamfile.v2');
    mergeBlocksWithFile('''
import os ;
project date_time_converter
    :
    :
    ;
ENV_CXXFLAGS = [ os.environ CXXFLAGS ] ;
ENV_LINKFLAGS = [ os.environ LINKFLAGS ] ;
SOURCES =
     date_time_converter_program_options
;

exe date_time_converter
    : date_time_converter.cpp
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

install install_app : date_time_converter :
   <link>static
      <variant>debug:<location>\$(FCS_INSTALL_PATH)/static/debug
      <variant>release:<location>\$(FCS_INSTALL_PATH)/static/release
;

install install_app : date_time_converter :
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

class Script extends Entity with InstallationCodeGenerator {


  // custom <class Script>

  Script(Id id) : super(id);
  void generate() {
    print('Generating script $id');
  }

  // end <class Script>
}

class Test extends Entity with InstallationCodeGenerator {


  // custom <class Test>

  Test(Id id) : super(id);
  void generate() {
    print('Generating test $id');
  }

  // end <class Test>
}

class Installation implements CodeGenerator {

  Installation(this.id);

  Id id;
  /// Fully qualified path to installation
  String get root => _root;
  Map<String, String> get paths => _paths;
  List<App> apps = [];
  List<Script> scripts = [];
  List<InstallationCodeGenerator> schemaCodeGenerators = [];
  List<Lib> libs = [];
  List<Test> tests = [];

  // custom <class Installation>

  String toString() => '''
Installation($root)
  libs: =>\n${libs.map((l) => l.toString()).join('')}
  apps: => ${apps.map((a) => a.id).join(', ')}
  scripts: => ${scripts.map((s) => s.id).join(', ')}
  tests: => ${tests.map((t) => t.id).join(', ')}
  paths: => [\n    ${paths.keys.map((k) => '$k => ${paths[k]}').join('\n    ')}\n  ]
''';

  addLib(Lib lib) => libs.add(lib..installation = this);
  addApp(App app) => apps.add(app..installation = this);
  addSchemaCodeGenerator(InstallationCodeGenerator scg) =>
    schemaCodeGenerators.add(scg..installation = this);

  generate() {
    libs..forEach((l) => l.generate())..clear();
    apps..forEach((a) => a.generate())..clear();
    schemaCodeGenerators..forEach((scg) => scg.generate())..clear();
  }

  set root(String root) {
    _root = root;
    _paths = {
      'usr_lib' : '/usr/lib',
      'usr_include' : 'usr/include',
      'cpp' : '${_root}/cpp',
    };
  }

  get cppPath => _paths['cpp'];

  // end <class Installation>
  String _root;
  Map<String, String> _paths = {};
}
// custom <part installation>

App app(Object id) => new App(id is Id? id : new Id(id));
Script script(Object id) => new Script(id is Id? id : new Id(id));

// end <part installation>
