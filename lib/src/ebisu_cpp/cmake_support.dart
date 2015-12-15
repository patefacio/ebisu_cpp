part of ebisu_cpp.ebisu_cpp;

/// Responsible for generating a suitable CMakeLists.txt file
class CmakeInstallationBuilder extends InstallationBuilder {
  // custom <class CmakeInstallationBuilder>

  /// Construct a [CmakeInstallationBuilder] from an [Installation]
  ///
  /// Installation is required for the build script construction since it holds
  /// the root path and is the top node of the [Entity] tree
  CmakeInstallationBuilder.fromInstallation(installation)
      : super.fromInstallation(installation);

  get installation => super.installation;
  get testProvider => installation.testProvider;

  get _isCatchDecl => testProvider is CatchTestProvider ? 'catch ' : '';

  void generate() {
    final cmakeRoot = installationCmakeRoot(installation);

    final installTargets = [];

    libCmake(lib) {
      final libName = lib.namespace.names.map((n) => n.toUpperCase()).join('_');
      final srcMacro = '${libName}_SOURCES';
      final installDirectives = lib.headers.map((Header h) {
        final relPath =
            path.relative(h.includeFilePath, from: installation.cppPath);
        return '''
install(FILES ${h.includeFilePath}
  DESTINATION \${DESTDIR}/include/${path.dirname(h.includeFilePath)})''';
      });

      return brCompact([
        '''
set ($srcMacro
${indentBlock(brCompact(lib.headers.map((h) => h.includeFilePath)))})
${brCompact(installDirectives)}
'''
      ]);
    }

    appCmake(app) {
      final relPath = path.relative(app.appPath, from: installation.cppPath);
      final requiredLibs = app.requiredLibs;
      if (app.hasSignalHandler && !requiredLibs.contains('pthread')) {
        requiredLibs.add('pthread');
      }
      final isMacroRe = new RegExp(r'^\s*\$');
      installTargets.add(app.name);
      return brCompact([
        '''
add_executable(${app.name}
  ${app.sources.map((src) => '$relPath/$src.cpp').join('\n  ')}
)

${chomp(scriptCustomBlock('${app.name} exe additions'))}

target_link_libraries(${app.name}
${chomp(scriptCustomBlock('${app.name} libs'))}
  \${Boost_PROGRAM_OPTIONS_LIBRARY}
  \${Boost_SYSTEM_LIBRARY}
  \${Boost_THREAD_LIBRARY}
''',
        requiredLibs
            .map((l) => indentBlock(l.contains(isMacroRe) ? l : '-${l}')),
        ')'
      ]);
    }

    testCmake(Testable testable) {
      final test = testable.test;
      final basename = path.basenameWithoutExtension(testable.testFileName);
      final owningLib = testable.owningLib.id.snake;
      final testBaseName = 'test.$owningLib.$basename';
      final relPath = path.relative(path.dirname(test.filePath),
          from: installation.cppPath);
      installTargets.add(testBaseName);
      return '''

${scriptComment("test for ${test.name}\n${indentBlock(test.detailedPath)}")}
add_executable($testBaseName
  ${test.sources.map((src) => '$relPath/$src').join('\n  ')}
)

${chomp(scriptCustomBlock('${test.name} test additions'))}

target_link_libraries($testBaseName
${chomp(scriptCustomBlock('${_isCatchDecl}${test.name} link requirements'))}
  \${Boost_SYSTEM_LIBRARY}
  \${Boost_THREAD_LIBRARY}
  pthread
)

add_test(
  $testBaseName
  $testBaseName)''';
    }

    benchmarkCmake(BenchmarkApp app) {
      relPath(String p) => path.relative(p, from: installation.cppPath);
      final benchName = 'bench_${app.id.snake}';
      installTargets.add(benchName);
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
''';
    }

    scriptMergeWithFile(
        '''
cmake_minimum_required (VERSION 2.8)

include(CheckCXXCompilerFlag)
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -std=c++14")
set(CMAKE_CXX_FLAGS_DEBUG "\${CMAKE_CXX_FLAGS_DEBUG} -O0 -DDEBUG")

######################################################################
# Find boost and include desired components
######################################################################
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost 1.54.0 COMPONENTS program_options system thread
${chomp(scriptCustomBlock('boost lib components'))}
)

## TO ENABLE LIB INIT LOGGING MOVE THIS TO custom
## set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -DLIB_INIT_LOGGING")

${scriptCustomBlock('misc section')}

######################################################################
# Add additional link directories
######################################################################
link_directories(
${scriptCustomBlock('link directories')}
)

enable_testing()

######################################################################
# Add additional include directories
######################################################################
include_directories(
  \${CMAKE_CURRENT_LIST_DIR}
  \${Boost_INCLUDE_DIRS}
${scriptCustomBlock('include directories')}
)

######################################################################
# Lib sources
######################################################################
${chomp(br(libs.map((lib) => libCmake(lib))))}

######################################################################
# Application build directives
######################################################################
${chomp(br(apps.map((app) => appCmake(app))))}

######################################################################
# Test directives
######################################################################
${chomp(br(testables.map((testable) => testCmake(testable))))}

######################################################################
# Benchmark directives
######################################################################
${chomp(br(benchmarkApps.map((bma) => benchmarkCmake(bma as BenchmarkApp))))}

######################################################################
# Install directives
######################################################################
install(TARGETS
  ${indentBlock(brCompact(installTargets))}
  RUNTIME DESTINATION \${DESTDIR}/bin
  LIBRARY DESTINATION \${DESTDIR}/lib
  ARCHIVE DESTINATION \${DESTDIR}/lib/static)
''',
        cmakeRoot);

    final cmakeGenerator = path.join(path.dirname(cmakeRoot), '.cmake.gen.sh');
    scriptMergeWithFile(
        '''
#!/bin/bash
${scriptCustomBlock('additional exports')}
cmake -DCMAKE_BUILD_TYPE=Release -B../cmake_build/release -H.
cmake -DCMAKE_BUILD_TYPE=Debug -B../cmake_build/debug -H.
''',
        cmakeGenerator);
  }

  // end <class CmakeInstallationBuilder>

}

// custom <part cmake_support>

installationCmakeCommon(Installation installation) => path.join(
    installation.rootFilePath, 'cpp', 'cmake.${installation.name}.common');

installationCmakeRoot(Installation installation) =>
    path.join(installation.rootFilePath, 'cpp', 'CMakeLists.txt');

// end <part cmake_support>
