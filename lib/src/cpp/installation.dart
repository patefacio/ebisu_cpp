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

  String path(String key) {
    var result = getPath(key);

    if(result == null) {
      result = _paths[key];
    }

    if(result == null) {
      _logger.warning('Do not recognize path $key');
    }
    return result;
  }

  get cppPath => path('cpp');

  // end <class Installation>
  String _root;
  Map<String, String> _paths = {};
  List<Lib> _generatedLibs = [];
  List<App> _generatedApps = [];
}

class PathLocator {

  /// Environment variable specifying location of path, if set this path is used
  final String envVar;
  /// Default path for the item in question
  final String defaultPath;
  String get path => _path;

  // custom <class PathLocator>

  PathLocator(this.envVar, this.defaultPath) {
    if(envVar == null && defaultPath == null)
      throw 'Valid PathLocator requires envVar and/or defaultPath';

    if(envVar != null) {
      _path = Platform.environment[envVar];
    }

    if(_path == null) {
      _path = defaultPath;
    }

    var fileType = FileSystemEntity.typeSync(path);
    if(fileType == FileSystemEntityType.NOT_FOUND) {
      _logger.warning('Required path ($envVar, $defaultPath, $path) not found');
    }
  }

  // end <class PathLocator>
  String _path;
}
// custom <part installation>

App app(Object id) => new App(id is Id? id : new Id(id));
Script script(Object id) => new Script(id is Id? id : new Id(id));

get _home => Platform.environment["HOME"];

var _locatorPaths = {
  'boost_build' : new PathLocator('BOOST_BUILD_PATH',
      path.join(_home, 'install', 'boost-build')).path,
  'boost_install' : new PathLocator('BOOST_INSTALL_PATH', null).path,
  'cpp_install' : new PathLocator('CPP_INSTALL_PATH',
      path.join(_home, 'install', 'cpp')).path,
};

var _functorPaths = {
  'cpp_include' : path.join(_locatorPaths['cpp_install'], 'include'),
};

String getPath(String key) {
  var result = _locatorPaths.containsKey(key)? _locatorPaths[key] :
    _functorPaths.containsKey(key)? _functorPaths[key] : null;
  return result;
}

// end <part installation>
