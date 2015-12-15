part of ebisu_cpp.ebisu_cpp;

/// Creates builder for an installation (ie ties together all build artifacts)
abstract class InstallationBuilder implements CodeGenerator {
  Installation installation;

  // custom <class InstallationBuilder>

  get name => installation.id.snake;
  get rootFilePath => installation.rootFilePath;
  get docPath => path.join(rootFilePath, 'doc');
  get cppPath => path.join(rootFilePath, 'cpp');
  get testables => installation.testables;
  get libs => installation.libs;
  get apps => installation.apps;
  Iterable<App> get benchmarkApps => installation._benchmarkApps;

  InstallationBuilder.fromInstallation(this.installation);
  generateBuildScripts() => this.generate();

  // end <class InstallationBuilder>

}

/// The to level [CppEntity] representing the root of a C++ installation.
///
/// The composition of generatable [CppEntity] items starts here. This is
/// where the [root] (i.e. target root path) is defined, dictating
/// locations of the tree of C++. This is the object to configure *global*
/// type features like:
///
///  - Provide a [Namer] to control the naming conventions
///
///  - Provide a [TestProvider] to control how tests are provided
///
///  - Provide a [LogProvider] to control what includes are required for
///    the desired logging solution and how certain [Loggable] entities
///    should log
///
///  - Should support for logging api initialization be generated
class Installation extends CppEntity implements CodeGenerator {
  /// Fully qualified file path to installation
  String get rootFilePath => _rootFilePath;
  Map<String, String> get paths => _paths;
  List<CppLogger> cppLoggers = [];

  /// Libs in this [Installation].
  List<Lib> libs = [];

  /// Apps in this [Installation].
  List<App> apps = [];

  /// Provider for generating tests
  TestProvider testProvider = new CatchTestProvider();

  /// Provider for generating tests
  LogProvider logProvider = new SpdlogProvider(new EbisuCppNamer());

  /// The builder for this installation
  InstallationBuilder installationBuilder;
  DoxyConfig doxyConfig = new DoxyConfig();

  /// If true logs initialization of libraries - useful for tracking
  /// down order of initialization issues.
  bool logsApiInitializations = false;

  /// All *stand-alone* modeled benchmarks in the installation
  List<Benchmark> benchmarks = [];

  /// All [BenchmarkGroup]s in this [Installation]
  List<BenchmarkGroup> benchmarkGroups = [];

  /// If true includes comments about code being generated as well as a
  /// stack trace to help find the dart code that generated the source.
  bool includeStackTrace = false;

  // custom <class Installation>

  Installation(Id id) : super(id) {
    rootFilePath = '/tmp';
  }

  set rootFilePath(String rfp) {
    _rootFilePath = rfp;
    _paths = {
      'usr_lib': '/usr/lib',
      'usr_include': 'usr/include',
      'doc': '${_rootFilePath}/doc',
      'cpp': '${_rootFilePath}/cpp',
    };
  }

  String get contents {
    setAsRoot();
    return br([
      '<<<< INSTALLATION($id) >>>>',
      indentBlock(br(concat([libs, apps, benchmarks,]).map((f) {
        return f.contents;
      })))
    ]);
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
Installation($rootFilePath)
  libs: =>\n${libs.map((l) => l.toString()).join('')}
  apps: => ${apps.map((a) => a.id).join(', ')}
  scripts: => ${scripts.map((s) => s.id).join(', ')}
  paths: => [\n    ${paths.keys.map((k) => '$k => ${paths[k]}').join('\n    ')}\n  ]
''';

  addLib(Lib lib) => libs.add(lib);
  addLibs(Iterable<Lib> libs) => libs.forEach((l) => addLib(l));
  addApp(App app) => apps.add(app);

  Iterable<CppEntity> get children =>
      concat([benchmarks, benchmarkGroups, apps, libs, cppLoggers]);

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
  generate(
      {generateBuildScripts: false,
      generateHeaderSmokeTest: false,
      generateDoxyFile: false,
      generateEmacs: false}) {
    /// This assignment triggers the linkup of all children
    setAsRoot();

    progeny.forEach((Entity child) => (child as CppEntity)._namer = _namer);

    concat([libs]).forEach((Lib lib) => (lib as CodeGenerator).generate());

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
            ..setLibFilePathFromRoot(rootFilePath)
            ..includes = [header.includeFilePath];
          return impl;
        }).toList();
      smokeLib.owner = this;
      smokeLib.generate();
    }

    concat([apps]).forEach((App app) => (app as CodeGenerator).generate());

    _generateBenchmarkApps();

    testProvider.generateTests(this);

    if (generateBuildScripts) {
      if (installationBuilder == null) {
        installationBuilder =
            new CmakeInstallationBuilder.fromInstallation(this);
      }
      installationBuilder.generateBuildScripts();
    }

    if (generateDoxyFile) {
      final docPath = path.join(rootFilePath, 'doc');
      mergeWithFile((doxyConfig
            ..projectName = id.snake
            ..projectBrief = doc
            ..input = cppPath
            ..outputDirectory = path.join(docPath, 'doxydoc')).config,
          path.join(docPath, '${id.snake}.doxy'));
    }

    if (generateEmacs) {
      new InstallationWalker(this).generate();
    }

    _logger.info(brCompact(progeny.map((e) => e.detailedPath)));
  }

  @override setAsRoot() {
    super.setAsRoot();
    _addStandardizedHeaders();
    _patchHeaderNamespaces();
  }

  _generateBenchmarkApps() {
    concat([
      benchmarkGroups.map((bg) => bg.benchmarkApp),
      benchmarks.map((bm) => bm.benchmarkApp)
    ]).forEach((BenchmarkApp app) {
      app
        ..setBenchmarkFilePathFromRoot(cppPath)
        ..generate();
      _benchmarkApps.add(app);
    });
  }

  onOwnershipEstablished() {
    final allBenchmarks = concat(
        [benchmarks, concat(benchmarkGroups.map((bg) => bg.benchmarks))]);

    // All benchmarks at [Installation] or within [BenchmarkGroup] get a lib
    libs.addAll(allBenchmarks.map((Benchmark bm) => bm.benchmarkLib));
  }

  _addStandardizedHeaders() =>
      libs.forEach((Lib lib) => lib._addStandardizedHeaders());

  _patchHeaderNamespaces() => libs.forEach((Lib lib) {
        assert(lib.namespace != null);
        lib.headers
            .where((Header h) => h.namespace == null)
            .forEach((Header h) {
          h.namespace = lib.namespace;
        });
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

  String _rootFilePath;
  Map<String, String> _paths = {};

  /// Benchmark Apps in this [Installation].
  ///
  /// Benchmark apps are just [App] instances with some generated benchmark code
  /// (i.e. using [benchmark](https://github.com/google/benchmark)) kept separate from
  /// [apps], but tied into the build scripts.
  List<App> _benchmarkApps = [];

  /// Namer to be used when generating names during generation. There is a
  /// default namer, [EbisuCppNamer] that is used if one is not provide. To
  /// create your own naming conventions, provide an implementation of
  /// [Namer] and set an assign that namer to a top-level [Entity], such as
  /// the [Installation]. The assigned namer will be propogated to all
  /// genration utilities.
  Namer _namer = defaultNamer;
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
  'cpp_install':
      new PathLocator('CPP_INSTALL_PATH', path.join(_home, 'install', 'cpp'))
          .path,
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
