part of ebisu_cpp.cpp;

/// A CodeGenerator tied to a c++ installation
abstract class InstallationCodeGenerator implements CodeGenerator {

  Installation installation;

  // custom <class InstallationCodeGenerator>
  // end <class InstallationCodeGenerator>
}

class Installation implements CodeGenerator {

  Installation(this.id);

  Id id;
  /// Fully qualified path to installation
  String get root => _root;
  Map<String, String> get paths => _paths;
  List<Lib> libs = [];
  List<App> apps = [];
  List<Script> scripts = [];
  List<InstallationCodeGenerator> schemaCodeGenerators = [];
  List<Test> tests = [];
  List<Lib> get generatedLibs => _generatedLibs;
  List<App> get generatedApps => _generatedApps;

  // custom <class Installation>

  get name => id.snake;
  get nameShout => id.shout;

  String toString() => '''
Installation($root)
  libs: =>\n${libs.map((l) => l.toString()).join('')}
  apps: => ${apps.map((a) => a.id).join(', ')}
  scripts: => ${scripts.map((s) => s.id).join(', ')}
  tests: => ${tests.map((t) => t.id).join(', ')}
  paths: => [\n    ${paths.keys.map((k) => '$k => ${paths[k]}').join('\n    ')}\n  ]
''';

  addLib(Lib lib) => libs.add(lib..installation = this);
  addLibs(Iterable<Lib> libs) => libs.forEach((l) => addLib(l));
  addApp(App app) => apps.add(app..installation = this);
  addSchemaCodeGenerator(InstallationCodeGenerator scg) =>
    schemaCodeGenerators.add(scg..installation = this);

  generate([bool generateJamConfigs = false]) {
    libs..forEach((l) => _generatedLibs.add(l..generate()))..clear();
    apps..forEach((a) => _generatedApps.add(a..generate()))..clear();
    schemaCodeGenerators..forEach((scg) => scg.generate())..clear();
    if(generateJamConfigs) {
      new SiteConfig(this).generate();
      new UserConfig(this).generate();
      new JamRoot(this).generate();
      new JamFileTop(this).generate();
    }
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
  List<Lib> _generatedLibs = [];
  List<App> _generatedApps = [];
}
// custom <part installation>

App app(Object id) => new App(id is Id? id : new Id(id));
Script script(Object id) => new Script(id is Id? id : new Id(id));

// end <part installation>
