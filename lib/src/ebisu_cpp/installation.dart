part of ebisu_cpp.ebisu_cpp;

/// Creates builder for an installation (ie ties together all build artifacts)
///
abstract class InstallationBuilder implements CodeGenerator {
  Installation installation;

  // custom <class InstallationBuilder>

  get name => installation.id.snake;
  get rootPath => installation.root;
  get docPath => path.join(rootPath, 'doc');
  get cppPath => path.join(rootPath, 'cpp');
  get testables => installation.testables;
  get apps => installation.apps;
  get libs => installation.libs;

  InstallationBuilder.fromInstallation(this.installation);
  generateBuildScripts() => this.generate();

  // end <class InstallationBuilder>

}

class Installation extends CppEntity implements CodeGenerator {

  /// Fully qualified path to installation
  ///
  String get root => _root;
  Map<String, String> get paths => _paths;
  List<Lib> libs = [];
  List<App> apps = [];
  List<Script> scripts = [];
  /// Provider for generating tests
  ///
  TestProvider testProvider = new CatchTestProvider();
  /// Provider for generating tests
  ///
  LogProvider logProvider = new SpdlogProvider(new EbisuCppNamer());
  /// The builder for this installation
  ///
  InstallationBuilder installationBuilder;
  DoxyConfig doxyConfig = new DoxyConfig();

  // custom <class Installation>

  Installation(Id id) : super(id) {
    root = '/tmp';
  }

  set root(String root) {
    _root = root;
    _paths = {
      'usr_lib': '/usr/lib',
      'usr_include': 'usr/include',
      'doc': '${_root}/doc',
      'cpp': '${_root}/cpp',
    };
  }

  String get name => id.snake;
  String get nameShout => id.shout;

  Iterable<Header> get headers => progeny.where((e) => e is Header);

  get requiresLogging => headers.any((h) => h.requiresLogging);

  get installation => this;

  get testables =>
      progeny.where((e) => e is Testable).where((e) => (e as Testable).hasTest);

  decorateWith(InstallationDecorator decorator) => decorator.decorate(this);

  String toString() => '''
Installation($root)
  libs: =>\n${libs.map((l) => l.toString()).join('')}
  apps: => ${apps.map((a) => a.id).join(', ')}
  scripts: => ${scripts.map((s) => s.id).join(', ')}
  paths: => [\n    ${paths.keys.map((k) => '$k => ${paths[k]}').join('\n    ')}\n  ]
''';

  addLib(Lib lib) => libs.add(lib);
  addLibs(Iterable<Lib> libs) => libs.forEach((l) => addLib(l));
  addApp(App app) => apps.add(app);

  Iterable<CppEntity> get children => concat([apps, libs, scripts]);

  // Generate the installation
  //
  // generateHeaderSmokeTest: If set will generate a single cpp per header that
  //                          includes that header.  If that cpp compiles it is
  //                          an indication the header is doing a proper job of
  //                          including all its dependencies. If there are
  //                          compile errors, revisit the header and add
  //                          required includes
  //
  // generateDoxyFile:        If true generates config file for doxygen
  //
  generate({generateBuildScripts: false, generateHeaderSmokeTest: false,
      generateDoxyFile: false}) {

    /// This assignment triggers the linkup of all children
    owner = null;
    logProvider..installationId = this.id;

    if (_namer == null) {
      _namer = defaultNamer;
    }

    _addApiHeaderForLibsWithLogging();

    progeny.forEach((Entity child) => (child as CppEntity)._namer = _namer);

    concat([libs]).forEach((CodeGenerator cg) => cg.generate());

    if (generateHeaderSmokeTest) {
      final smokeLib = lib('smoke')
        ..namespace = namespace(['smoke'])
        ..impls = progeny
            .where((Entity child) => child is Header)
            .map((Header header) {
          _logger.warning(
              'smoking ${header.id} issues with ns ${header.namespace}');
          final impl = new Impl(idFromString('smoke_${header.id.snake}'))
            ..namespace = namespace(['smoke'])
            ..setLibFilePathFromRoot(root)
            ..includes = [header.includeFilePath];
          return impl;
        }).toList();
      smokeLib.owner = this;
      smokeLib.generate();
    }

    concat([apps]).forEach((CodeGenerator cg) => cg.generate());

    testProvider.generateTests(this);

    if (generateBuildScripts) {
      if (installationBuilder == null) {
        installationBuilder =
            new CmakeInstallationBuilder.fromInstallation(this);
      }
      installationBuilder.generateBuildScripts();
    }

    if (generateDoxyFile) {
      final docPath = path.join(_root, 'doc');
      mergeWithFile((doxyConfig
        ..projectName = id.snake
        ..projectBrief = doc
        ..input = cppPath
        ..outputDirectory = path.join(docPath, 'doxydoc')).config,
          path.join(docPath, '${id.snake}.doxy'));
    }
  }

  /// Any library requiring logging support needs access to a logger That logger
  /// could go in the [App], but then you would not have a self-contained [Lib]
  /// as there would be dependencies on the [App] like create the logger. Rather
  /// than that approach, if a logger requires logging ensure that it has an
  /// ApiHeader. If it does not have one, provide one of the same name as the
  /// [Lib]. Then inject the log variable in that.
  _addApiHeaderForLibsWithLogging() => libs
      .where((lib) => lib.requiresLogging)
      .forEach((Lib lib) {
    if (lib.apiHeader == null) {
      final apiHeader = header(lib.id)
        ..namespace = lib.namespace
        ..isApiHeader = true
        ..includes.addAll(logProvider.includeRequirements.included)
        ..owner = lib;

      apiHeader.getCodeBlock(fcbEndNamespace).snippets
          .add(logProvider.createLibLogger(lib));

      _logger.info('${lib.id} requires logging but has no apiHeader - '
          'adding ${apiHeader.id} with ns ${apiHeader.namespace}');

      lib.headers.add(apiHeader);
      assert(lib.apiHeader != null);
    }
  });

  String _pathLookup(String key) {
    var result = getPath(key);

    if (result == null) {
      result = _paths[key];
    }

    if (result == null) {
      _logger.warning('Do not recognize path $key');
    }
    return result;
  }

  get cppPath => _pathLookup('cpp');

  // end <class Installation>

  String _root;
  Map<String, String> _paths = {};
}

class PathLocator {

  /// Environment variable specifying location of path, if set this path is used
  ///
  final String envVar;
  /// Default path for the item in question
  ///
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
