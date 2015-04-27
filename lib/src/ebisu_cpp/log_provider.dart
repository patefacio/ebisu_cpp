part of ebisu_cpp.ebisu_cpp;

/// Establishes an abstract interface to provide customizable c++ log messages
///
/// Not wanting to commit to a single logging solution, this class allows
/// client code to make certain items [Loggable] and not tie the generated
/// code to a particular logging solution. A default [LogProvider] that makes
/// use of *spdlog* is provided.
///
abstract class LogProvider {

  Includes includeRequriements;

  // custom <class LogProvider>
  // end <class LogProvider>

}


/// Provides support for logging via spdlog
class SpdlogProvider extends LogProvider {

  // custom <class SpdlogProvider>
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
