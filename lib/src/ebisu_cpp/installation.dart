part of ebisu_cpp.ebisu_cpp;

/// Creates builder for an installation (ie ties together all build artifacts)
///
abstract class InstallationBuilder implements CodeGenerator {
  Installation installation;

  // custom <class InstallationBuilder>

  get name => installation.id.snake;
  get rootPath => installation.root;
  get cppPath => path.join(rootPath, 'cpp');
  get tests => installation.allTests;
  get apps => installation.apps;
  get libs => installation.libs;

  InstallationBuilder.fromInstallation(this.installation);
  InstallationBuilder();

  generateInstallationBuilder(Installation installation) {
    this.installation = installation;
    this.generate();
  }

  // end <class InstallationBuilder>

}

class Installation extends Entity implements CodeGenerator {

  /// Fully qualified path to installation
  String get root => _root;
  Map<String, String> get paths => _paths;
  List<Lib> libs = [];
  List<App> apps = [];
  List<Test> tests = [];
  List<Script> scripts = [];
  /// Provider for generating tests
  TestProvider testProvider = new CatchTestProvider();
  /// List of builders for the installation (cmake is only one supported at this time)
  List<InstallationBuilder> builders = [];

  // custom <class Installation>

  Installation(Id id, [this._root = '/tmp']) : super(id);

  String get name => id.snake;
  String get nameShout => id.shout;

  Iterable<Testable> get testables => progeny.where(
      (offspring) => offspring is Testable &&
          (offspring as Testable).testScenarios.isNotEmpty);

  get allTests {
    final result = libs.fold([], (prev, l) => prev..addAll(l.allTests));

    print('Getting all tests - mainly to get good make representation');

    return result..addAll(tests);
  }

  decorateWith(InstallationDecorator decorator) => decorator.decorate(this);

  String toString() => '''
Installation($root)
  libs: =>\n${libs.map((l) => l.toString()).join('')}
  apps: => ${apps.map((a) => a.id).join(', ')}
  scripts: => ${scripts.map((s) => s.id).join(', ')}
  tests: => ${tests.map((t) => t.id).join(', ')}
  paths: => [\n    ${paths.keys.map((k) => '$k => ${paths[k]}').join('\n    ')}\n  ]
''';

  addLib(Lib lib) => libs.add(lib);
  addLibs(Iterable<Lib> libs) => libs.forEach((l) => addLib(l));
  addApp(App app) => apps.add(app);

  generate() {
    owner = null;

    if (_namer == null) {
      _namer = defaultNamer;
    }

    progeny.forEach((Entity child) => child._namer = _namer);

    concat([libs, apps]).forEach((CodeGenerator cg) => cg.generate());

    testProvider.generateTests(testables);

    for (var builder in builders) {
      builder.generateInstallationBuilder(this);
    }
  }

  set root(String root) {
    _root = root;
    _paths = {
      'usr_lib': '/usr/lib',
      'usr_include': 'usr/include',
      'cpp': '${_root}/cpp',
    };
  }

  String path(String key) {
    var result = getPath(key);

    if (result == null) {
      result = _paths[key];
    }

    if (result == null) {
      _logger.warning('Do not recognize path $key');
    }
    return result;
  }

  get cppPath => path('cpp');

  Iterable<Entity> get children => concat([apps, libs, tests, scripts]);

  // end <class Installation>

  String _root;
  Map<String, String> _paths = {};
}

class PathLocator {

  /// Environment variable specifying location of path, if set this path is used
  final String envVar;
  /// Default path for the item in question
  final String defaultPath;
  String get path => _path;

  // custom <class PathLocator>

  PathLocator(this.envVar, this.defaultPath) {
    if (envVar == null &&
        defaultPath ==
            null) throw 'Valid PathLocator requires envVar and/or defaultPath';

    if (envVar != null) {
      _path = Platform.environment[envVar];
    }

    if (_path == null) {
      _path = defaultPath;
    }

    if (path == null) {
      _logger
          .warning('$envVar must be set as there is no established default!');
    } else {
      var fileType = FileSystemEntity.typeSync(path);
      if (fileType == FileSystemEntityType.NOT_FOUND) {
        _logger
            .warning('Required path ($envVar, $defaultPath, $path) not found');
      }
    }
  }

  // end <class PathLocator>

  String _path;
}

// custom <part installation>

_asId(id) => id is Id ? id : new Id(id);
Installation installation(Object id) => new Installation(_asId(id));
App app(Object id) => new App(_asId(id));
Script script(Object id) => new Script(_asId(id));

get _home => Platform.environment["HOME"];

var _locatorPaths = {
  'boost_build': new PathLocator(
      'BOOST_BUILD_PATH', path.join(_home, 'install', 'boost-build')).path,
  'boost_install': new PathLocator('BOOST_INSTALL_PATH', null).path,
  'cpp_install': new PathLocator(
      'CPP_INSTALL_PATH', path.join(_home, 'install', 'cpp')).path,
};

var _functorPaths = {
  'cpp_include': path.join(_locatorPaths['cpp_install'], 'include'),
};

String getPath(String key) {
  var result = _locatorPaths.containsKey(key)
      ? _locatorPaths[key]
      : _functorPaths.containsKey(key) ? _functorPaths[key] : null;
  return result;
}

// end <part installation>
