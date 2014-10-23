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
    final filePath = path.join(installation.root, 'config', 'site-config.jam');
    mergeBlocksWithFile('''
import project ;
import feature ;
import os ;

project site-config ;

''', filePath);
  }

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
// custom <part jam_support>
// end <part jam_support>
