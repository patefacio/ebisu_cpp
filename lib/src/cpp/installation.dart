part of ebisu_cpp.cpp;

/// A CodeGenerator tied to a c++ installation
abstract class InstallationCodeGenerator implements CodeGenerator {

  Installation installation;

  // custom <class InstallationCodeGenerator>
  // end <class InstallationCodeGenerator>
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
  addLibs(Iterable<Lib> libs) => libs.forEach((l) => addLib(l));
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
