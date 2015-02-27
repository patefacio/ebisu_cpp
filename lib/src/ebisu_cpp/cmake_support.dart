part of ebisu_cpp.ebisu_cpp;

class CmakeInstallationBuilder extends InstallationBuilder {
  // custom <class CmakeInstallationBuilder>

  CmakeInstallationBuilder.fromInstallation(installation)
      : super.fromInstallation(installation);

  CmakeInstallationBuilder() : super();

  Installation get installation => super.installation;

  void generate() {
    final cmakeRoot = installationCmakeRoot(installation);

    appCmake(app) {
      final relPath = path.relative(app.appPath, from: installation.cppPath);
      return '''
add_executable(${app.name}
  ${app.sources.map((src) => '$relPath/$src.cpp').join('\n  ')}
)

target_link_libraries(${app.name}
${chomp(scriptCustomBlock('${app.name} libs'))}
  \${Boost_PROGRAM_OPTIONS_LIBRARY}
  \${Boost_SYSTEM_LIBRARY}
  \${Boost_THREAD_LIBRARY}
)''';
    }

    testCmake(test) {
      final relPath = path.relative(test.cppPath, from: installation.cppPath);
      return '''
# test for ${test.name}
add_executable(${test.name}
  ${test.sources.map((src) => '$relPath/$src.cpp').join('\n  ')}
)

target_link_libraries(${test.name}
${chomp(scriptCustomBlock('${test.name} link requirements'))}
  \${Boost_SYSTEM_LIBRARY}
  \${Boost_THREAD_LIBRARY}
)

add_test(${test.name} ${test.name})
''';
    }

    scriptMergeWithFile('''
cmake_minimum_required (VERSION 2.8)

include(CheckCXXCompilerFlag)
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} -std=c++11")

######################################################################
# Find boost and include desired components
######################################################################
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost 1.54.0 COMPONENTS program_options system thread
${chomp(scriptCustomBlock('boost lib components'))}
)

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
# Application build directives
######################################################################
${br(apps.map((app) => appCmake(app)))}

######################################################################
# Test directives
######################################################################
${br(tests.map((test) => testCmake(test)))}

''', cmakeRoot);

    final cmakeGenerator = path.join(path.dirname(cmakeRoot), 'cmake.gen.sh');
    scriptMergeWithFile('''
${scriptCustomBlock('additional exports')}
cmake -DCMAKE_BUILD_TYPE=Release -B../cmake_build/release -H.
cmake -DCMAKE_BUILD_TYPE=Debug -B../cmake_build/debug -H.
''', cmakeGenerator);
  }

  // end <class CmakeInstallationBuilder>
}
// custom <part cmake_support>

CmakeInstallationBuilder cmakeInstallationBuilder() =>
    new CmakeInstallationBuilder();

installationCmakeCommon(Installation installation) =>
    path.join(installation.root, 'cpp', 'cmake.${installation.name}.common');

installationCmakeRoot(Installation installation) =>
    path.join(installation.root, 'cpp', 'CMakeLists.txt');

// end <part cmake_support>
