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

class SiteConfig implements CodeGenerator {

  SiteConfig(this.installation);

  Installation installation;

  // custom <class SiteConfig>

  void generate() {
    final boostPath = Platform.environment['BOOST_INSTALL_PATH'];

    if(boostPath == null)
      throw 'To generate site-config.jam you must set BOOST_INSTALL_PATH';

    final filePath = path.join(installation.root, 'config', 'site-config.jammed');
    mergeBlocksWithFile('''
import project ;
import feature ;
import os ;

project site-config ;

path-constant BOOST_INCLUDE_PATH : $boostPath/include ;
path-constant BOOST_LIB_PATH : $boostPath/lib ;

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

  void generate() {
    final filePath = path.join(installation.root, 'cpp', 'Jamfiled');
    mergeBlocksWithFile('''
''', filePath);
  }

  // end <class JamFileTop>
}

class JamRoot implements CodeGenerator {

  JamRoot(this.installation);

  Installation installation;

  // custom <class JamRoot>

  void generate() {
    final filePath = path.join(installation.root, 'cpp', 'Jamrooted');
    mergeBlocksWithFile('''
''', filePath);
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


// end <part jam_support>
