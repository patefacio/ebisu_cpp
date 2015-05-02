part of ebisu_cpp.ebisu_cpp;

/// Establishes an abstract interface to provide customizable c++ log messages
///
/// Not wanting to commit to a single logging solution, this class allows
/// client code to make certain items [Loggable] and not tie the generated
/// code to a particular logging solution. A default [LogProvider] that makes
/// use of *spdlog* is provided.
///
abstract class LogProvider {
  LogProvider(this.namer);

  Includes includeRequirements;
  Namer namer;
  Id get installationId => _installationId;
  String loggerName;

  // custom <class LogProvider>

  String logMethodInvocation(Lib lib, String methodName);
  String createLibLogger(Id libId);

  set installationId(Id id) {
    _installationId = id;
    loggerName = idFromString('${id.snake}_logger').snake;
  }

  // end <class LogProvider>

  Id _installationId;
}

/// Provides support for logging via spdlog
class SpdlogProvider extends LogProvider {

  // custom <class SpdlogProvider>

  SpdlogProvider(Namer namer) : super(namer) {
    includeRequirements = new Includes()..add('spdlog/spdlog.h');
  }

  libLoggerClassName(Lib lib) =>
      namer.nameClass(idFromString('${lib.id.snake}_logger'));
  libLoggerName(Lib lib) =>
      namer.nameMember(idFromString('${lib.id.snake}_logger'));

  logMethodInvocation(Lib lib, String methodName) =>
      '${libLoggerName}()->info("Method $methodName invoked")';

  createLibLogger(Lib lib) {
    final loggerClassName = libLoggerClassName(lib);
    final loggerName = libLoggerName(lib);
    final detailedName = chomp(lib.detailedPath);

    return '''
/// Provide for single logger for $detailedName
template <typename T>
struct $loggerClassName {
  std::shared_ptr<spdlog::logger> & logger() {
    static std::shared_ptr<spdlog::logger> logger = spdlog::stdout_logger_mt("${lib.id.snake}");
    return logger;
  }
};

namespace {

/// Accessor for the logger for $detailedName
inline std::shared_ptr<spdlog::logger>& ${loggerName}() {
  return $loggerClassName<int>().logger();
}
}
''';
  }

  // end <class SpdlogProvider>

}

/// Mixin to indicate an item is loggable.
///
/// Examples might be member accessors, member constructors, etc
///
class Loggable {

  /// If true the [Loggable] item is logged
  bool isLogged = false;

  // custom <class Loggable>
  // end <class Loggable>

}

// custom <part log_provider>
// end <part log_provider>
