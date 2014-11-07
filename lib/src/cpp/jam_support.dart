part of ebisu_cpp.cpp;

class JamAppBuilder extends AppBuilder {


  // custom <class JamAppBuilder>

  get app => super.app;
  get appName => app.name;

  JamAppBuilder(App app) : super(app);

  static const Map _headerToJamRequirement = const {
    'boost/program_options.hpp' : '/site-config//boost_program_options',
    'boost/date_time' : '/site-config//boost_date_time',
    'boost/regex' : '/site-config//boost_regex',
  };

  static const Map _libToJamRequirement = const {
    'boost_program_options' : '/site-config//boost_program_options',
    'boost_date_time' : '/site-config//boost_date_time',
    'boost_regex' : '/site-config//boost_regex',
  };

  get jamRequirements {
    final found = new Set();

    app.requiredLibs.forEach((String lib) {
      final requirement = _libToJamRequirement[lib];
      if(requirement == null)
        throw "Unkown lib requirement $lib";
      found.add(requirement);
    });

    app.allIncludes.includeEntries.forEach((String include) {
      _headerToJamRequirement.forEach((String header, String requirement) {
        if(include.contains(header))
          found.add(requirement);
      });
    });
    return found;
  }

  void generate() {
    final targetFile = path.join(app.appPath, 'Jamfile.v2');
    mergeBlocksWithFile('''
import os ;
project $appName
    :
    :
    ;
ENV_CXXFLAGS = [ os.environ CXXFLAGS ] ;
ENV_LINKFLAGS = [ os.environ LINKFLAGS ] ;
SOURCES =
     ${app.sources.join('\n     ')}
;

exe date_time_converter
    : $appName.cpp
      \$(SOURCES).cpp
      ${jamRequirements.join('\n      ')}
    : <define>DEBUG_FCS_STARTUP
      <cxxflags>\$(ENV_CXXFLAGS)
      <linkflags>\$(ENV_LINKFLAGS)
      <variant>debug:<define>DEBUG
      <variant>release:<define>NDEBUG
    ;

install install_app : $appName :
   <link>static
      <variant>debug:<location>\$(FCS_INSTALL_PATH)/static/debug
      <variant>release:<location>\$(FCS_INSTALL_PATH)/static/release
;

install install_app : $appName :
   <link>shared
      <variant>debug:<location>\$(FCS_INSTALL_PATH)/shared/debug
      <variant>release:<location>\$(FCS_INSTALL_PATH)/shared/release
;

explicit install_app ;

''', targetFile);
  }

  // end <class JamAppBuilder>
}

class JamTestBuilder extends TestBuilder {


  // custom <class JamTestBuilder>

  get lib => super.lib;

  JamTestBuilder(Lib lib, String directory, List<Test> tests) :
    super(lib, directory, tests);

  _testRuleAddition(Test test) => '''
rule ${test.name}
{
  all_rules += [ run ${test.cppFiles.join('\n    ')}
  :
  : # test-files
  : # requirements
  ] ;
}
test-suite ${test.basename} : [ ${test.name} ] ;
''';

  void generate() {
    final targetFile = path.join(directory, 'Jamfile.v2');
    mergeBlocksWithFile('''
project test_${lib.snake}
    :
    :
    ;

import testing ;

${chomp(br(tests.map((t) => _testRuleAddition(t))))}''', targetFile);
  }

  // end <class JamTestBuilder>
}

class SiteConfig implements CodeGenerator {

  SiteConfig(this.installation);

  Installation installation;

  // custom <class SiteConfig>

  void generate() {
    final boostPath = installation.path('boost_install');
    final cppIncludePath = installation.path('cpp_include');

    if(boostPath == null)
      throw 'To generate site-config.jam you must set BOOST_INSTALL_PATH';

    final filePath = path.join(installation.root, 'config', 'site-config.jam');
    mergeBlocksWithFile('''
import project ;
import feature ;
import os ;

project site-config ;

path-constant BOOST_INCLUDE_PATH : $boostPath/include ;
path-constant BOOST_LIB_PATH : $boostPath/lib ;
path-constant CPP_INCLUDE_PATH : $cppIncludePath ;

${
combine(_boostLibsUnique.map((String l) =>
combine([
_boostMtStatics.contains(l) ?
'lib boost_$l : : <file>\$(BOOST_LIB_PATH)/libboost_$l-mt.a <variant>release ;' : null
])))
}

''', filePath);
  }

  get _boostLibs => [];



  // end <class SiteConfig>
}

class UserConfig implements CodeGenerator {

  UserConfig(this.installation);

  Installation installation;

  // custom <class UserConfig>

  void generate() {
    final filePath = path.join(installation.root, 'config', 'user-config.jam');
    mergeBlocksWithFile('''
''', filePath);
  }

  // end <class UserConfig>
}

class JamFileTop implements CodeGenerator {

  JamFileTop(this.installation);

  Installation installation;

  // custom <class JamFileTop>

  get id => installation.id;
  get name => installation.name;
  get nameShout => installation.nameShout;

  void generate() {
    final filePath = path.join(installation.root, 'cpp', 'Jamfile');

    mergeBlocksWithFile('''
import package ;
import common ;
import os ;
import feature : set-default ;

constant ${nameShout}_INSTALL_PATH : ${_buildInstallPath}/${name} ;
constant TOP : ${installation.cppPath} ;

local rule explicit-alias ( id : targets + )
{
    alias \$(id) : \$(targets) ;
    explicit \$(id) ;
}

project ${id}_projects
        : requirements
          <define>OTL_ODBC_UNIX
          <define>BOOST_FILESYSTEM_VERSION=2
          <variant>debug:<define>DEBUG
          <toolset>gcc:<cxxflags>-Wno-invalid-offsetof
          <toolset>gcc:<cxxflags>-Wno-deprecated-declarations
          <toolset>gcc:<cxxflags>-std=c++11
          <toolset>darwin:<cxxflags>-std=c++11
          <linkflags>-lpthread
          <include>\$(BOOST_INCLUDE_PATH)
          <include>\$(CPP_INCLUDE_PATH)
          <include>/usr/local/include
          <tag>@\$(__name__).tag
          <include>.
          <toolset>intel:<cxxflags>-std=c++0x
          <toolset>intel:<cxxflags>-Qoption,cpp,--rvalue_ctor_is_not_copy_ctor
          <toolset>intel:<define>BOOST_CALLBACK_EXPLICIT_COPY_CONSTRUCTOR
          <toolset>intel:<linkflags>-i-static
          <toolset>intel:<linkflags>-i-static
          <library>/site-config//boost_thread
          <library>/site-config//boost_system
        :
        : build-dir ../../build-dir
        ;

''', filePath);
  }

  // end <class JamFileTop>
}

class JamRoot implements CodeGenerator {

  JamRoot(this.installation);

  Installation installation;

  // custom <class JamRoot>

  void generate() {
    final filePath = path.join(installation.root, 'cpp', 'Jamroot');
    mergeBlocksWithFile(
      _jamRoot
      .replaceAll('FCS', installation.id.shout)
      .replaceAll('fcs', installation.id.snake)
      .replaceAll('Fcs', installation.id.capSnake), filePath);
  }

  // end <class JamRoot>
}
// custom <part jam_support>

final _boostLibs = [
  'atomic-mt.a',
  'atomic-mt.dylib',
  'chrono-mt.a',
  'chrono-mt.dylib',
  'chrono.a',
  'chrono.dylib',
  'context-mt.a',
  'context-mt.dylib',
  'context.a',
  'context.dylib',
  'coroutine-mt.a',
  'coroutine-mt.dylib',
  'coroutine.a',
  'coroutine.dylib',
  'date_time-mt.a',
  'date_time-mt.dylib',
  'date_time.a',
  'date_time.dylib',
  'exception-mt.a',
  'exception.a',
  'filesystem-mt.a',
  'filesystem-mt.dylib',
  'filesystem.a',
  'filesystem.dylib',
  'graph-mt.a',
  'graph-mt.dylib',
  'graph.a',
  'graph.dylib',
  'iostreams-mt.a',
  'iostreams-mt.dylib',
  'iostreams.a',
  'iostreams.dylib',
  'locale-mt.a',
  'locale-mt.dylib',
  'log-mt.a',
  'log-mt.dylib',
  'log.a',
  'log.dylib',
  'log_setup-mt.a',
  'log_setup-mt.dylib',
  'log_setup.a',
  'log_setup.dylib',
  'math_c99-mt.a',
  'math_c99-mt.dylib',
  'math_c99.a',
  'math_c99.dylib',
  'math_c99f-mt.a',
  'math_c99f-mt.dylib',
  'math_c99f.a',
  'math_c99f.dylib',
  'math_c99l-mt.a',
  'math_c99l-mt.dylib',
  'math_c99l.a',
  'math_c99l.dylib',
  'math_tr1-mt.a',
  'math_tr1-mt.dylib',
  'math_tr1.a',
  'math_tr1.dylib',
  'math_tr1f-mt.a',
  'math_tr1f-mt.dylib',
  'math_tr1f.a',
  'math_tr1f.dylib',
  'math_tr1l-mt.a',
  'math_tr1l-mt.dylib',
  'math_tr1l.a',
  'math_tr1l.dylib',
  'prg_exec_monitor-mt.a',
  'prg_exec_monitor-mt.dylib',
  'prg_exec_monitor.a',
  'prg_exec_monitor.dylib',
  'program_options-mt.a',
  'program_options-mt.dylib',
  'program_options.a',
  'program_options.dylib',
  'python-mt.a',
  'python-mt.dylib',
  'python.a',
  'python.dylib',
  'random-mt.a',
  'random-mt.dylib',
  'random.a',
  'random.dylib',
  'regex-mt.a',
  'regex-mt.dylib',
  'regex.a',
  'regex.dylib',
  'serialization-mt.a',
  'serialization-mt.dylib',
  'serialization.a',
  'serialization.dylib',
  'signals-mt.a',
  'signals-mt.dylib',
  'signals.a',
  'signals.dylib',
  'system-mt.a',
  'system-mt.dylib',
  'system.a',
  'system.dylib',
  'test_exec_monitor-mt.a',
  'test_exec_monitor.a',
  'thread-mt.a',
  'thread-mt.dylib',
  'timer-mt.a',
  'timer-mt.dylib',
  'timer.a',
  'timer.dylib',
  'unit_test_framework-mt.a',
  'unit_test_framework-mt.dylib',
  'unit_test_framework.a',
  'unit_test_framework.dylib',
  'wave-mt.a',
  'wave-mt.dylib',
  'wave.a',
  'wave.dylib',
  'wserialization-mt.a',
  'wserialization-mt.dylib',
  'wserialization.a',
  'wserialization.dylib',
];

final _boostMtStatics = new Set();
final _boostStStatics = new Set();
final _boostMtDynamics = new Set();
final _boostStDynamics = new Set();

final _boostLibsUnique = () {
  final result = new Set();
  _boostLibs.forEach((String l) {
    addLib(Set s, l) {
      result.add(l);
      s.add(l);
    }
    if(l.endsWith('-mt.a')) {
      final base = l.substring(0, l.indexOf('-mt.a'));
      addLib(_boostMtStatics, base);
    } else if(l.endsWith('-mt.dylib')) {
      final base = l.substring(0, l.indexOf('-mt.dylib'));
      addLib(_boostMtDynamics, base);
    } else if(l.endsWith('.a')) {
      final base = l.substring(0, l.indexOf('.a'));
      addLib(_boostStStatics, base);
    } else if(l.endsWith('.dylib')) {
      final base = l.substring(0, l.indexOf('.dylib'));
      addLib(_boostMtStatics, base);
    } else {
      throw "Unknown lib type $l";
    }
  });
  return result;
}();

get _buildInstallPath {
  final result = Platform.environment['BUILD_INSTALL_PATH'];
  if(result == null)
    throw "You must specify env var BUILD_INSTALL_PATH";
  return result;
}

final _jamRoot = r'''
# Copyright Vladimir Prus 2002-2006.
# Copyright Dave Abrahams 2005-2006.
# Copyright Rene Rivera 2005-2007.
# Copyright Douglas Gregor 2005.
#
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)

# Usage:
#
#   bjam [options] [install|stage]
#
#   Builds and installs Boost.
#
# Targets and Related Options:
#
#   install                 Install headers and compiled library files to the
#   =======                 configured locations (below).
#
#   --prefix=<PREFIX>       Install architecture independent files here.
#                           Default; C:\Boost on Win32
#                           Default; /usr/local on Unix. Linux, etc.
#
#   --exec-prefix=<EPREFIX> Install architecture dependent files here.
#                           Default; <PREFIX>
#
#   --libdir=<DIR>          Install library files here.
#                           Default; <EPREFIX>/lib
#
#   --includedir=<HDRDIR>   Install header files here.
#                           Default; <PREFIX>/include
#
#   stage                   Build and install only compiled library files
#   =====                   to the stage directory.
#
#   --stagedir=<STAGEDIR>   Install library files here
#                           Default; ./stage
#
# Other Options:
#
#   --build-type=<type>     Build the specified pre-defined set of variations
#                           of the libraries. Note, that which variants get
#                           built depends on what each library supports.
#
#                               minimal (default) - Builds the single
#                               "release" version of the libraries. This
#                               release corresponds to specifying:
#                               "release <threading>multi <link>shared
#                               <link>static <runtime-link>shared" as the
#                               Boost.Build variant to build.
#
#                               complete - Attempts to build all possible
#                               variations.
#
#   --build-dir=DIR         Build in this location instead of building
#                           within the distribution tree. Recommended!
#
#   --toolset=toolset       Indicates the toolset to build with.
#
#   --show-libraries        Displays the list of Boost libraries that require
#                           build and installation steps, then exit.
#
#   --layout=<layout>       Determines whether to choose library names
#                           and header locations such that multiple
#                           versions of Boost or multiple compilers can
#                           be used on the same system.
#
#                               versioned (default) - Names of boost
#                               binaries include the Boost version
#                               number and the name and version of the
#                               compiler.  Boost headers are installed
#                               in a subdirectory of <HDRDIR> whose
#                               name contains the Boost version
#                               number.
#
#                               system - Binaries names do not include
#                               the Boost version number or the name
#                               and version number of the compiler.
#                               Boost headers are installed directly
#                               into <HDRDIR>.  This option is
#                               intended for system integrators who
#                               are building distribution packages.
#
#   --buildid=ID            Adds the specified ID to the name of built
#                           libraries.  The default is to not add anything.
#
#   --help                  This message.
#
#   --with-<library>        Build and install the specified <library>
#                           If this option is used, only libraries
#                           specified using this option will be built.
#
#   --without-<library>     Do not build, stage, or install the specified
#                           <library>. By default, all libraries are built.

# TODO:
#  - handle boost version
#  - handle python options such as pydebug

import generate ;
import modules ;
import set ;
import package ;
import path ;
import common ;
import os ;
import regex ;
import stage ;
import errors ;
import "class" : new ;
import common ;
import sequence ;
import symlink ;
import option ;
import property ;

path-constant FCS_ROOT : . ;
constant FCS_VERSION : 0.0.1 ;
constant FCS_JAMROOT_MODULE : $(__name__) ;

local version-tag = [ MATCH "^([^.]+)[.]([^.]+)[.]([^.]+)" : $(FCS_VERSION) ] ;
if $(version-tag[3]) = 0
{
    version-tag = $(version-tag[1-2]) ;
}

constant FCS_VERSION_TAG : $(version-tag:J="_") ;


# Option to choose how many variants to build. The default is "minimal",
# which builds only the "release <threading>multi <link>shared" variant.
local build-type = [ MATCH "^--build-type=(.*)" : [ modules.peek : ARGV ] ] ;

build-type ?= minimal ;
if ! ( $(build-type) in minimal complete )
{
    build-type = minimal ;
}

# Specify the build variants keyed on the build-type.
local default-build,minimal =
    release
    <threading>multi
    <link>shared <link>static
    <runtime-link>shared
    ;
local default-build,complete =
    debug release
    <threading>single <threading>multi
    <link>shared <link>static
    <runtime-link>shared <runtime-link>static
    ;

# Set the default build.
local default-build = $(default-build,$(build-type)) ;

# We only use the default build when building at the root to
# avoid having it impact the default regression testing of "debug".
# TODO: Consider having a "testing" build type instead of this check.
if $(__file__:D) != ""
{
    default-build = debug ;
}

rule handle-static-runtime ( properties * )
{
    # This property combination is dangerous.
    # Ideally, we'd add constraint to default build,
    # so that user can build with property combination
    # by hand. But we don't have any 'constraint' mechanism
    # for default-build, so disable such builds in requirements.

    # For CW, static runtime is needed so that
    # std::locale works.
    if <link>shared in $(properties)
      && <runtime-link>static in $(properties)
        && ! ( <toolset>cw in $(properties) )
    {
        return <build>no ;
    }
}

project fcs
    : requirements <include>.
      # disable auto-linking for all targets here,
      # primarily because it caused troubles with V2
      #<define>FCS_ALL_NO_LIB=1
      # Used to encode variant in target name. See the
      # 'tag' rule below.
      <tag>@$(__name__).tag
      <conditional>@handle-static-runtime

    : usage-requirements <include>.
    :
    : default-build $(default-build)
    ;

# Setup convenient aliases for all libraries.

all-libraries =
    [ MATCH .*libs/(.*)/build/.* : [ glob libs/*/build/Jamfile.v2 ] [ glob libs/*/build/Jamfile ] ]
    ;

all-libraries = [ sequence.unique $(all-libraries) ] ;

alias headers : : : : <include>. ;

# Decides which libraries are to be installed by looking at --with-<library>
# --without-<library> arguments. Returns the list of directories under "libs"
# which must be built at installed.
rule libraries-to-install ( existing-libraries * )
{
   local argv = [ modules.peek : ARGV ] ;
   local with-parameter = [ MATCH --with-(.*) : $(argv) ] ;
   local without-parameter = [ MATCH --without-(.*) : $(argv) ] ;

   # Do some checks
   if $(with-parameter) && $(without-parameter)
   {
       ECHO "error: both --with-<library> and --without-<library> specified" ;
       EXIT ;
   }

   local wrong = [ set.difference $(with-parameter) : $(existing-libraries) ] ;
   if $(wrong)
   {
       ECHO "error: wrong library name '$(wrong[1])' in the --with-<library> option." ;
       EXIT ;
   }
   local wrong = [ set.difference $(without-parameter) : $(existing-libraries) ] ;
   if $(wrong)
   {
       ECHO "error: wrong library name '$(wrong[1])' in the --without-<library> option." ;
       EXIT ;
   }

   if $(with-parameter)
   {
       return [ set.intersection $(existing-libraries) : $(with-parameter) ] ;
   }
   else
   {
       return [ set.difference $(existing-libraries) : $(without-parameter) ] ;
   }
}

# what kind of layout are we doing?
layout = [ MATCH "^--layout=(.*)" : [ modules.peek : ARGV ] ] ;
layout ?= versioned ;
layout-$(layout) = true ;

# location of python
local python-root = [ MATCH "^--with-python-root=(.*)" : [ modules.peek : ARGV ] ] ;
PYTHON_ROOT ?= $(python-root) ;

# Select the libraries to install.
libraries = [ libraries-to-install $(all-libraries) ] ;

if --show-libraries in [ modules.peek : ARGV ]
{
    ECHO "The following libraries require building:" ;
    for local l in $(libraries)
    {
        ECHO "    - $(l)" ;
    }
    EXIT ;
}

# Custom build ID.
local build-id = [ MATCH "^--buildid=(.*)" : [ modules.peek : ARGV ] ] ;
if $(build-id)
{
    constant BUILD_ID : [ regex.replace $(build-id) "[*\\/:.\"\' ]" "_" ] ;
}

# This rule is called by Fcs.Build to determine the name of
# target. We use it to encode build variant, compiler name and
# fcs version in the target name
rule tag ( name : type ? : property-set )
{
    if $(type) in STATIC_LIB SHARED_LIB IMPORT_LIB
    {
        if $(layout) = versioned
        {
            local result = [ common.format-name
                <base> <toolset> <threading> <runtime> -$(FCS_VERSION_TAG)
                -$(BUILD_ID)
                : $(name) : $(type) : $(property-set) ] ;

            # Optionally add version suffix.
            # On NT, library with version suffix won't be recognized
            # by linkers. On CYGWIN, we get strage duplicate symbol
            # errors when library is generated with version suffix.
            # On OSX, version suffix is not needed -- the linker expets
            # libFoo.1.2.3.dylib format.
            # AIX linkers don't accept version suffixes either.
            # Pgi compilers can't accept library with version suffix
            if $(type) = SHARED_LIB &&
              ( ! ( [ $(property-set).get <target-os> ] in windows cygwin darwin aix ) &&
                ! ( [ $(property-set).get <toolset> ] in pgi ) )
            {
                result = $(result).$(FCS_VERSION)  ;
            }

            return $(result) ;
        }
        else
        {
            return [ common.format-name
                <base> <threading> <runtime> -$(BUILD_ID)
                : $(name) : $(type) : $(property-set) ] ;
        }
    }
}

# Install to system location.

local install-requirements =
    <install-source-root>fcs
    ;
if $(layout-versioned)
{
    install-requirements += <install-header-subdir>fcs-$(FCS_VERSION_TAG)/fcs ;
}
else
{
    install-requirements += <install-header-subdir>fcs ;
}
if [ modules.peek : NT ]
{
    install-requirements += <install-default-prefix>C:/Fcs ;
}
else if [ modules.peek : UNIX ]
{
    install-requirements += <install-default-prefix>/usr/local ;
}

local headers =
    [ path.glob-tree fcs : *.hpp *.ipp *.h *.inc : CVS ]
    ;

# Complete install
package.install install-proper
    :   $(install-requirements) <install-no-version-symlinks>on
    :
    :   libs/$(libraries)/build
    :   $(headers)
    ;
explicit install-proper ;

# Install just library.
install stage-proper
    :   libs/$(libraries)/build
    :   <location>$(stage-locate)/lib
        <install-dependencies>on <install-type>LIB
        <install-no-version-symlinks>on
    ;
explicit stage-proper ;


if $(layout-versioned)
  && ( [ modules.peek : NT ] || [ modules.peek : UNIX ] )
{
    rule make-unversioned-links ( project name ? : property-set : sources * )
    {
        local result ;
        local filtered ;
        local pattern ;
        local nt = [ modules.peek : NT ] ;

        # Collect the libraries that have the version number in 'filtered'.
        for local s in $(sources)
        {
            local m ;
            if $(nt)
            {
                m = [ MATCH "(.*[.]lib)" : [ $(s).name ] ] ;
            }
            else
            {
                m = [ MATCH "(.*[.]so[.0-9]+)" "(.*[.]dylib)" "(.*[.]a)" : [ $(s).name ] ] ;
            }
            if $(m)
            {
                filtered += $(s) ;
            }
        }

        # Create links without version.
        for local s in $(filtered)
        {
            local name = [ $(s).name ] ;
            local ea = [ $(s).action ] ;
            local ep = [ $(ea).properties ] ;
            local a  = [
              new non-scanning-action $(s) : symlink.ln : $(ep) ] ;

            local noversion-file ;
            if $(nt)
            {
                noversion-file = [ MATCH "(.*)-[0-9_]+([.]lib)" : $(name) ] ;
            }
            else
            {
                noversion-file =
                  [ MATCH "(.*)-[0-9_]+([.]so)[.0-9]*" : $(name) ]
                  [ MATCH "(.*)-[0-9_]+([.]dylib)" : $(name) ]
                  [ MATCH "(.*)-[0-9_]+([.]a)" : $(name) ]
                  [ MATCH "(.*)-[0-9_]+([.]dll[.]a)" : $(name) ] ;
            }

            local new-name =
               $(noversion-file[1])$(noversion-file[2]) ;
            result += [ new file-target $(new-name) exact : [ $(s).type ] : $(project)
                    : $(a) ] ;

        }
        return $(result) ;
    }

    generate stage-unversioned : stage-proper :
      <generating-rule>@make-unversioned-links ;
    explicit stage-unversioned ;

    generate install-unversioned : install-proper :
      <generating-rule>@make-unversioned-links ;
    explicit install-unversioned ;
}
else
{
    # Create do-nothing aliases
    alias stage-unversioned ;
    explicit stage-unversioned ;
    alias install-unversioned ;
    explicit install-unversioned ;
}

alias install : install-proper install-unversioned ;
alias install : install-proper ;
alias stage : stage-proper stage-unversioned ;
explicit install ;
explicit stage ;


# Just build the libraries, don't install them anywhere.
# This is what happens with just "bjam --v2".
alias build_all : libs/$(libraries)/build ;


rule fcs-install ( libraries * )
{
    package.install install
        : <dependency>/fcs//install-proper-headers $(install-requirements)
        : # No binaries
        : $(libraries)
        : # No headers, it's handled by the dependency
    ;

    install stage : $(libraries) : <location>$(FCS_STAGE_LOCATE) ;

    local c = [ project.current ] ;
    local project-module = [ $(c).project-module ] ;
    module $(project-module)
    {
        explicit stage ;
        explicit install ;
    }
}

# Make project ids of all libraries known.
for local l in $(all-libraries)
{
    use-project /fcs/$(l) : libs/$(l)/build ;
}
''';


// end <part jam_support>
