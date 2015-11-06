part of ebisu_cpp.ebisu_cpp;

/// Establishes an abstract interface to provide customizable c++ log messages
///
/// Not wanting to commit to a single logging solution, this class allows
/// client code to make certain items [Loggable] and not tie the generated
/// code to a particular logging solution. A default [LogProvider] that makes
/// use of *spdlog* is provided.
abstract class LogProvider {
  LogProvider(this.namer);

  Includes includeRequirements;
  Namer namer;

  // custom <class LogProvider>

  /// Provide C++ text that defines the desired logger.
  ///
  /// [entity] may be used to differentiate this logger from others.
  String createLoggerInstance(Entity entity);

  /// Create a [Header] a logger owned by [CppEntity] [owner].
  ///
  /// It is assumed a logger may be declared/defined in its own [Header]
  Header createLoggingHeader(CppEntity owner, Namespace namespace);

  /// Set the log level from [varExpression] (assumed to be a string
  /// representing the logging level)
  String setLogLevel(varExpression);

  // end <class LogProvider>

}

/// Provides support for logging via spdlog
class SpdlogProvider extends LogProvider {
  // custom <class SpdlogProvider>

  SpdlogProvider(Namer namer) : super(namer) {
    includeRequirements = new Includes()..add('ebisu/logger/logger.hpp');
  }

  /// Names the singleton logger class by suffixing the entity name with '_logger'
  loggerClassName(Entity entity) =>
      namer.nameClass(idFromString('${entity.id.snake}_logger'));

  /// Names the logger by suffixing the entity name with '_logger'
  loggerName(Entity entity) =>
      namer.nameMember(idFromString('${entity.id.snake}_logger'));

  String setLogLevel(varExpression) => '''
std::string const desired_log_level { $varExpression };
if(desired_log_level == "off") {
  spdlog::set_level(spdlog::level::off);
} else if(desired_log_level == "debug") {
  spdlog::set_level(spdlog::level::debug);
} else if(desired_log_level == "info") {
  spdlog::set_level(spdlog::level::info);
} else if(desired_log_level == "notice") {
  spdlog::set_level(spdlog::level::notice);
} else if(desired_log_level == "warn") {
  spdlog::set_level(spdlog::level::warn);
} else if(desired_log_level == "err") {
  spdlog::set_level(spdlog::level::err);
} else if(desired_log_level == "critical") {
  spdlog::set_level(spdlog::level::critical);
} else if(desired_log_level == "alert") {
  spdlog::set_level(spdlog::level::alert);
} else if(desired_log_level == "emerg") {
  spdlog::set_level(spdlog::level::emerg);
} else if(desired_log_level == "trace") {
  spdlog::set_level(spdlog::level::trace);
} else {
  throw std::invalid_argument("log_level must be one of: [trace, debug, info, notice, warn, err, critical, alert, emerg, off]");
}
''';

  /// Will provide a singleton logger in anonymous namespace to get internal
  /// linkage so logger is accessible in all translation units that include the
  /// header
  createLoggerInstance(Entity entity) {
    final loggerClassName_ = loggerClassName(entity);
    final loggerTraceMacro = '${entity.id.shout}_TRACE';
    final loggerName_ = loggerName(entity);

    _logger
        .info('creating logger for ${entity.id} ${chomp(entity.detailedPath)}');
    final detailedName = chomp(entity.detailedPath);

    return '''

/// Establishes logger for library ${entity.id.snake}
template <typename T>
struct $loggerClassName_ {};

/// Establishes logger using spdlog as implementation
template <>
struct $loggerClassName_<spdlog::logger> {
  using Logger_impl_t = std::shared_ptr<spdlog::logger>;
  static Logger_impl_t& logger() {
    static Logger_impl_t logger = spdlog::stdout_logger_mt("${entity.id.snake}");
    return logger;
  }
};

/// Establishes *null logger* that does no logging but satisfies the requirements
template <>
struct $loggerClassName_<ebisu::logger::Null_logger_impl> {
  using Impl_t = ebisu::logger::Null_logger_impl;
  using Logger_impl_t = ebisu::logger::Logger< Impl_t >*;
  static Logger_impl_t logger() {
    static ebisu::logger::Logger< Impl_t > logger { Impl_t() } ;
    return &logger;
  }
};

namespace {

////////////////////////////////////////////////////////////////////////////////
// Logging takes place by default in DEBUG mode only
// If logging is desired for *release* mode, define RELEASE_HAS_LOGGING
#if defined(DEBUG) || defined(RELEASE_HAS_LOGGING)
  using ${loggerClassName_}_t = $loggerClassName_<spdlog::logger>;
#define $loggerTraceMacro(...) ${entity.id.snake}_logger->trace(__VA_ARGS__)
#else
  using ${loggerClassName_}_t = $loggerClassName_< ebisu::logger::Null_logger_impl >;
  ${loggerClassName_}_t ${entity.id.snake}_logger_impl;
#define $loggerTraceMacro(...) (void)0
#endif

${loggerClassName_}_t::Logger_impl_t ${entity.id.snake}_logger = ${loggerClassName_}_t::logger();
}
''';
  }

  Header createLoggingHeader(CppEntity owner, Namespace namespace) {
    Id id = idFromString('${owner.id.snake}_logging');
    return header(id)
      ..namespace = namespace
      ..includes.mergeIncludes(includeRequirements)
      ..getCodeBlock(fcbBeginNamespace)
          .snippets
          .add(createLoggerInstance(owner))
      ..owner = owner;
  }

  // end <class SpdlogProvider>

}

/// Represents a single C++ logger
class CppLogger extends CppEntity {
  // custom <class CppLogger>

  CppLogger(id) : super(id);

  /// [CppLogger] has no children - returns empty [Iterable]
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  // end <class CppLogger>

}

/// Mixin to indicate an item is loggable.
///
/// Examples might be member accessors, member constructors, etc
class Loggable {
  /// If true the [Loggable] item is logged
  bool isLogged = false;

  // custom <class Loggable>
  // end <class Loggable>

}

// custom <part log_provider>

cppLogger(id) => new CppLogger(id);

// end <part log_provider>
