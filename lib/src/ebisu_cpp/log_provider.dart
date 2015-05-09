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

  // custom <class LogProvider>

  /// Provide C++ text that defines the desired logger.
  ///
  /// [entity] may be used to differentiate this logger from others.
  String createLoggerInstance(Entity entity);

  /// Create a [Header] a logger owned by [CppEntity] [owner].
  ///
  /// It is assumed a logger may be declared/defined in its own [Header]
  Header createLoggingHeader(CppEntity owner, Namespace namespace);

  // end <class LogProvider>

}

/// Provides support for logging via spdlog
///
class SpdlogProvider extends LogProvider {

  // custom <class SpdlogProvider>

  SpdlogProvider(Namer namer) : super(namer) {
    includeRequirements = new Includes()..add('spdlog/spdlog.h');
  }

  /// Names the singleton logger class by suffixing the entity name with '_logger'
  loggerClassName(Entity entity) =>
      namer.nameClass(idFromString('${entity.id.snake}_logger'));

  /// Names the logger by suffixing the entity name with '_logger'
  loggerName(Entity entity) =>
      namer.nameMember(idFromString('${entity.id.snake}_logger'));

  /// Will provide a singleton logger in anonymous namespace to get internal
  /// linkage so logger is accessible in all translation units that include the
  /// header
  createLoggerInstance(Entity entity) {
    final loggerClassName_ = loggerClassName(entity);
    final loggerName_ = loggerName(entity);

    _logger.severe(
        'creating logger for ${entity.id} ${chomp(entity.detailedPath)}');
    final detailedName = chomp(entity.detailedPath);

    return '''
/// Provide for single logger for $detailedName
template <typename T>
struct $loggerClassName_ {
  std::shared_ptr<spdlog::logger> & logger() {
    static std::shared_ptr<spdlog::logger> logger = spdlog::stdout_logger_mt("${entity.id.snake}");
    return logger;
  }
};

namespace {
  /// Accessor to the logger for $detailedName
  ///
  /// Internal linkage providing one shared pointer per translation unit
  std::shared_ptr<spdlog::logger> ${loggerName_} { $loggerClassName_<int>().logger() };
}
''';
  }

  Header createLoggingHeader(CppEntity owner, Namespace namespace) {
    Id id = idFromString('${owner.id.snake}_logging');
    return header(id)
      ..namespace = namespace
      ..includes.mergeIncludes(includeRequirements)
      ..getCodeBlock(fcbBeginNamespace).snippets
          .add(createLoggerInstance(owner))
      ..owner = owner;
  }

  // end <class SpdlogProvider>

}

/// Represents a single C++ logger
///
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
///
class Loggable {

  /// If true the [Loggable] item is logged
  ///
  bool isLogged = false;

  // custom <class Loggable>
  // end <class Loggable>

}

// custom <part log_provider>

cppLogger(id) => new CppLogger(id);

// end <part log_provider>
