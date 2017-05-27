part of ebisu_cpp.ebisu_cpp;

/// Cmake file for a library
class LibCmake {
  Lib lib;
  List libSourceFilenames = [];
  List targetIncludeDirnames = [];
  CodeBlock setStatements = new ScriptCodeBlock('set_statements')
    ..hasSnippetsFirst = true;
  CodeBlock addLibrary = new ScriptCodeBlock('add_library')
    ..hasSnippetsFirst = true;
  CodeBlock targetIncludeDirectories =
      new ScriptCodeBlock('target_include_directories')
        ..hasSnippetsFirst = true;
  CodeBlock targetCompileOptions = new ScriptCodeBlock('target_compile_options')
    ..hasSnippetsFirst = true;

  // custom <class LibCmake>

  LibCmake(this.lib) {
    libSourceFilenames =
        lib.impls.map((var impl) => path.basename(impl.filePath)).toList();

    setStatements.snippets.addAll([
      'set(CMAKE_VERBOSE_MAKEFILE ON)',
    ]);

    addLibrary.tag = null;
  }

  get definition => _definition == null
      ? (_definition = br([
          setStatements,
          addLibrary
            ..snippets.addAll([
              brCompact([
                'add_library(${lib.id.snake}',
                indentBlock(brCompact(libSourceFilenames)),
                ')',
              ]),
              targetIncludeDirectories,
              targetCompileOptions,
              '\ninstall(TARGETS ${lib.id.snake} ARCHIVE DESTINATION \${DESTDIR}lib/static)',
            ]),
        ], '\n\n'))
      : _definition;

  // end <class LibCmake>

  String _definition;
}

/// Cmake file for the installation
class InstallationCmake {
  Installation installation;
  String minimumRequiredVersion = '2.8';
  List includeDirectories = [];
  List linkDirectories = [];
  bool autoIncludeBoost = false;
  CodeBlock includesCodeBlock = new ScriptCodeBlock('includes')
    ..hasSnippetsFirst = true;
  CodeBlock setStatementsCodeBlock = new ScriptCodeBlock('set_statements')
    ..hasSnippetsFirst = true;
  CodeBlock boostSupportCodeBlock = new ScriptCodeBlock('boost_support')
    ..hasSnippetsFirst = true;
  CodeBlock findPackagesCodeBlock = new ScriptCodeBlock('find_packages')
    ..hasSnippetsFirst = true;
  CodeBlock libPublicHeadersCodeBlock =
      new ScriptCodeBlock('lib_public_headers')..hasSnippetsFirst = true;

  // custom <class InstallationCmake>

  InstallationCmake(this.installation) {
    includesCodeBlock.snippets.add('include(CheckCXXCompilerFlag)');

    if (autoIncludeBoost) {
      includeDirectories
          .addAll([r'${CMAKE_CURRENT_LIST_DIR}', r'${Boost_INCLUDE_DIRS}']);
    }

    setStatementsCodeBlock.snippets.addAll([
      r'set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")',
      r'set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -DDEBUG")',
      r'set(CMAKE_INCLUDE_CURRENT_DIR ON)',
    ]);

    boostSupportCodeBlock.snippets.addAll([
      'set(Boost_USE_STATIC_LIBS OFF)',
      'set(Boost_USE_MULTITHREADED ON)',
      'set(Boost_USE_STATIC_RUNTIME OFF)',
      '''
find_package(Boost 1.54.0 COMPONENTS program_options system thread
${scriptCustomBlock("boost lib components")}
)
'''
    ]);

    libPublicHeadersCodeBlock.snippets.addAll(concat([
      installation.libs.map((lib) => lib.headers.map(
          (header) => 'install(FILES ${header.includeFilePath} DESTINATION '
              '\${DESTDIR}include/${path.dirname(header.includeFilePath)})'))
    ]));
  }

  get definition => _definition == null
      ? (_definition = brCompact([
          'cmake_minimum_required (VERSION $minimumRequiredVersion)',
          includesCodeBlock,
          setStatementsCodeBlock,
          autoIncludeBoost ? boostSupportCodeBlock : null,
          '''

include_directories(\n${chomp(indentBlock(brCompact(includeDirectories)))}
${scriptCustomBlock("include directories")})
''',
          '''

link_directories(\n${chomp(indentBlock(brCompact(linkDirectories)))}
${scriptCustomBlock("link directories")})
''',
          scriptCustomBlock('misc section'),
          'enable_testing()',

          /// traditional libs
          installation.libs.where((Lib lib) => !lib.isHeaderOnly).map((Lib
                  lib) =>
              'add_subdirectory(${path.relative(lib.implPath, from: installation.cppPath)})'),

          /// header-only libs
          installation.libs
              .where((Lib lib) => lib.isHeaderOnly)
              .map((Lib lib) => brCompact([
                    'add_library(lib_${lib.id.snake} INTERFACE)',
                    'target_sources(lib_${lib.id.snake} INTERFACE',
                    lib.headers.map((header) => ' ${header.includeFilePath}'),
                    ')',
                  ])),

          /// allow for custom header additions
          libPublicHeadersCodeBlock,

          /// apps
          installation.apps.map((App app) {
            final relPath = path.relative(path.dirname(app.filePath),
                from: installation.cppPath);
            final requiredLibs = app.requiredLibs;
            if (app.hasSignalHandler && !requiredLibs.contains('pthread')) {
              requiredLibs.add('pthread');
            }

            return brCompact([
              '''
add_executable(${app.name}
  ${app.sources.map((src) => '$relPath/$src.cpp').join('\n  ')}
)

${chomp(scriptCustomBlock('${app.name} exe additions'))}

target_link_libraries(${app.name}
${chomp(scriptCustomBlock('${app.name} libs'))}
  boost_program_options
  boost_system
  boost_regex
  boost_filesystem
  boost_thread
''',
              requiredLibs.map(
                  (l) => indentBlock(l.contains(_isMacroRe) ? l : '-${l}')),
              ')'
            ]);
          }),
          installation.testables.map(_testCmake),
          installation.benchmarkApps
              .map((bma) => _benchmarkCmake(bma as BenchmarkApp)),
        ]))
      : _definition;

  _testCmake(Testable testable) {
    final test = testable.test;
    final basename = path.basenameWithoutExtension(testable.testFileName);
    final owningLib = testable.owningLib.id.snake;
    final testBaseName = 'test.$owningLib.$basename';
    final relPath =
        path.relative(path.dirname(test.filePath), from: installation.cppPath);
    final isCatchDecl =
        installation.testProvider is CatchTestProvider ? 'catch ' : '';

    return '''

${scriptComment("test for ${test.name}\n${indentBlock(test.detailedPath)}")}
add_executable($testBaseName
  ${test.sources.map((src) => '$relPath/$src').join('\n  ')}
)

${chomp(scriptCustomBlock('${test.name} test additions'))}

target_link_libraries($testBaseName
${chomp(scriptCustomBlock('${isCatchDecl}${test.name} link requirements'))}
  boost_system
  boost_regex
  boost_filesystem
  boost_thread
  pthread
)

add_test(
  $testBaseName
  $testBaseName)

install(TARGETS $testBaseName RUNTIME DESTINATION \${DESTDIR}bin)
''';
  }

  _benchmarkCmake(BenchmarkApp app) {
    relPath(String p) => path.relative(p, from: installation.cppPath);
    final benchName = 'bench_${app.id.snake}';
    return '''
add_executable($benchName
  ${concat([[relPath(app.filePath)], app.impls.map((i) => relPath(i.filePath))]).join('\n  ')}
)

${chomp(scriptCustomBlock('${app.id.snake} bench additions'))}

target_link_libraries(bench_${app.id.snake}
${chomp(scriptCustomBlock('benchmark ${app.id} link requirements'))}
  benchmark
  pthread
)

install(TARGETS $benchName RUNTIME DESTINATION \${DESTDIR}bin)

''';
  }

  // end <class InstallationCmake>

  String _definition;
}

/// Responsible for generating a suitable CMakeLists.txt file
class CmakeInstallationBuilder extends InstallationBuilder {
  /// An opportunity to update the [InstallationCmake] prior to its generation
  OnInstallationCmake onInstallationCmake;

  /// An opportunity to update the [LibCmake] prior to its generation
  OnInstallationCmake onLibCmake;
  bool autoIncludeBoost = false;

  // custom <class CmakeInstallationBuilder>

  /// Construct a [CmakeInstallationBuilder] from an [Installation]
  ///
  /// Installation is required for the build script construction since it holds
  /// the root path and is the top node of the [Entity] tree
  CmakeInstallationBuilder.fromInstallation(installation)
      : super.fromInstallation(installation);

  get installation => super.installation;
  get testProvider => installation.testProvider;

  libCmakeHeaders(lib) {
    final libName = lib.namespace.names.map((n) => n.toUpperCase()).join('_');
    final srcMacro = '${libName}_SOURCES';
    final installDirectives = lib.headers.map((Header h) {
      return '''
install(FILES ${h.includeFilePath}
  DESTINATION \${DESTDIR}include/${path.dirname(h.includeFilePath)})''';
    });

    return brCompact([
      '''
set ($srcMacro
${indentBlock(brCompact(lib.headers.map((h) => h.includeFilePath)))})
${brCompact(installDirectives)}
'''
    ]);
  }

  void generate([bool autoIncludeBoost = false]) {
    final cmakeRoot = installationCmakeRoot(installation);

    final installationCmake = new InstallationCmake(installation)
      ..autoIncludeBoost = autoIncludeBoost;

    if (onInstallationCmake != null) {
      onInstallationCmake(installationCmake);
    }

    scriptMergeWithFile(installationCmake.definition, cmakeRoot);

    libs.where((var lib) => lib.impls.isNotEmpty).forEach((Lib lib) {
      final implPath = lib.implPath;
      final libCmakePath = path.join(implPath, 'CMakeLists.txt');
      final libCmake = new LibCmake(lib);
      if (onLibCmake != null) {
        onLibCmake(libCmake);
      }
      scriptMergeWithFile(libCmake.definition, libCmakePath);
    });

    final cmakeGenerator = path.join(path.dirname(cmakeRoot), '.cmake.gen.sh');
    scriptMergeWithFile(
        '''
#!/bin/bash
${scriptCustomBlock('additional exports')}
\$CMAKE \\
  -DCMAKE_BUILD_TYPE=Release \\
  -DCMAKE_VERBOSE_MAKEFILE=ON \\
  -DCMAKE_PREFIX_PATH=/usr/include/qt5 \\
  -B../cmake_build/release \\
  -H.

\$CMAKE \\
  -DCMAKE_BUILD_TYPE=Debug \\
  -DCMAKE_VERBOSE_MAKEFILE=ON \\
  -DCMAKE_PREFIX_PATH=/usr/include/qt5 \\
  -B../cmake_build/debug \\
  -H.
''',
        cmakeGenerator);
  }

  // end <class CmakeInstallationBuilder>

}

// custom <part cmake_support>

typedef OnLibCmake(LibCmake);
typedef OnInstallationCmake(InstallationCmake);

installationCmakeRoot(Installation installation) =>
    path.join(installation.rootFilePath, 'cpp', 'CMakeLists.txt');

final _isMacroRe = new RegExp(r'^\s*\$');

// end <part cmake_support>
