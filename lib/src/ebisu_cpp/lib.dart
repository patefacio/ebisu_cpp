part of ebisu_cpp.ebisu_cpp;

/// Common headers unique to a [Lib] designed to provide consistency and
/// facilitate library usage.
///
/// - [libCommonHeader]: For a given [Lib], a place to put common types,
///   declarations that need to be included by all other headers in the
///   lib. If requested for a [Lib], all other headers in the [Lib] will
///   inlude this. Therefore, it is important that this header *not*
///   include other *non-common* headers in the [Lib]. The naming
///   convention is: LIBNAME_common.hpp
///
/// - [libLoggingHeader]: For a given [Lib] a header to provide a logger
///   instance. If requested for a [Lib], all other headers in the [Lib]
///   will include this indirectly via *lib_common_header*. The naming
///   convention is: LIBNAME_logging.hpp
///
/// - [ibInitializationHeader]: For a given [Lib] a header to provide
///   library initialization and uninitialization routines. If requested
///   for a [Lib], all other headers in the [Lib] will include this
///   indirectly via *lib_common_header*. The naming convention is:
///   LIBNAME_initialization.hpp
///
/// - [LibAllHeader]: For a given [Lib], this header will include all
///   other headers. This is a convenience for clients writing non-library
///   code. The naming convention is: LIBNAME_all.hpp
///
///
enum StandardizedHeader {
  libCommonHeader,
  libLoggingHeader,
  libInitializationHeader,
  libAllHeader
}

/// Convenient access to StandardizedHeader.libCommonHeader with *libCommonHeader* see [StandardizedHeader].
///
const StandardizedHeader libCommonHeader = StandardizedHeader.libCommonHeader;

/// Convenient access to StandardizedHeader.libLoggingHeader with *libLoggingHeader* see [StandardizedHeader].
///
const StandardizedHeader libLoggingHeader = StandardizedHeader.libLoggingHeader;

/// Convenient access to StandardizedHeader.libInitializationHeader with *libInitializationHeader* see [StandardizedHeader].
///
const StandardizedHeader libInitializationHeader =
    StandardizedHeader.libInitializationHeader;

/// Convenient access to StandardizedHeader.libAllHeader with *libAllHeader* see [StandardizedHeader].
///
const StandardizedHeader libAllHeader = StandardizedHeader.libAllHeader;

/// Set of pre-canned blocks where custom or generated code can be placed.
/// The various supported code blocks associated with a C++ file. The
/// name indicates where in the file it appears.
///
/// So, the following spec:
///
///     final h = header('foo')
///       ..includes = [ 'iostream' ]
///       ..namespace = namespace(['foo'])
///       ..customBlocks = [
///         fcbCustomIncludes,
///         fcbPreNamespace,
///         fcbBeginNamespace,
///         fcbEndNamespace,
///         fcbPostNamespace,
///       ];
///     print(h.contents);
///
/// prints:
///
///     #ifndef __FOO_FOO_HPP__
///     #define __FOO_FOO_HPP__
///
///     #include <iostream>
///
///     // custom <FcbCustomIncludes foo>
///     // end <FcbCustomIncludes foo>
///
///     // custom <FcbPreNamespace foo>
///     // end <FcbPreNamespace foo>
///
///     namespace foo {
///       // custom <FcbBeginNamespace foo>
///       // end <FcbBeginNamespace foo>
///
///       // custom <FcbEndNamespace foo>
///       // end <FcbEndNamespace foo>
///
///     } // namespace foo
///     // custom <FcbPostNamespace foo>
///     // end <FcbPostNamespace foo>
///
///     #endif // __FOO_FOO_HPP__
///
///
enum FileCodeBlock {
  /// Custom block any code just before includes begin
  /// Useful for putting definitions just prior to includes, e.g.
  ///
  ///     #define CATCH_CONFIG_MAIN
  ///     #include "catch.hpp"
  ///
  fcbPreIncludes,

  /// Custom block for any additional includes appearing just after generated includes
  fcbCustomIncludes,

  /// Custom block appearing just before the namespace declaration in the code
  fcbPreNamespace,

  /// Custom block appearing at the begining of and inside the namespace
  fcbBeginNamespace,

  /// Custom block appearing at the end of and inside the namespace
  fcbEndNamespace,

  /// Custom block appearing just after the namespace declaration in the code
  fcbPostNamespace
}

/// Convenient access to FileCodeBlock.fcbPreIncludes with *fcbPreIncludes* see [FileCodeBlock].
///
/// Custom block any code just before includes begin
/// Useful for putting definitions just prior to includes, e.g.
///
///     #define CATCH_CONFIG_MAIN
///     #include "catch.hpp"
///
///
const FileCodeBlock fcbPreIncludes = FileCodeBlock.fcbPreIncludes;

/// Convenient access to FileCodeBlock.fcbCustomIncludes with *fcbCustomIncludes* see [FileCodeBlock].
///
/// Custom block for any additional includes appearing just after generated includes
///
const FileCodeBlock fcbCustomIncludes = FileCodeBlock.fcbCustomIncludes;

/// Convenient access to FileCodeBlock.fcbPreNamespace with *fcbPreNamespace* see [FileCodeBlock].
///
/// Custom block appearing just before the namespace declaration in the code
///
const FileCodeBlock fcbPreNamespace = FileCodeBlock.fcbPreNamespace;

/// Convenient access to FileCodeBlock.fcbBeginNamespace with *fcbBeginNamespace* see [FileCodeBlock].
///
/// Custom block appearing at the begining of and inside the namespace
///
const FileCodeBlock fcbBeginNamespace = FileCodeBlock.fcbBeginNamespace;

/// Convenient access to FileCodeBlock.fcbEndNamespace with *fcbEndNamespace* see [FileCodeBlock].
///
/// Custom block appearing at the end of and inside the namespace
///
const FileCodeBlock fcbEndNamespace = FileCodeBlock.fcbEndNamespace;

/// Convenient access to FileCodeBlock.fcbPostNamespace with *fcbPostNamespace* see [FileCodeBlock].
///
/// Custom block appearing just after the namespace declaration in the code
///
const FileCodeBlock fcbPostNamespace = FileCodeBlock.fcbPostNamespace;

/// Wrap (un)initialization of a Lib in static methods of a class
class LibInitializer {
  /// CodeBlock for customizing intialization of [Lib]
  CodeBlock initCustomBlock;

  /// CodeBlock for customizing unintialization of [Lib]
  CodeBlock uninitCustomBlock;

  // custom <class LibInitializer>
  // end <class LibInitializer>

}

/// A c++ library
class Lib extends CppEntity with Testable implements CodeGenerator {
  /// Semantic Version for this [Lib]
  SemanticVersion get version => _version;

  /// Names for [Lib]
  Namespace namespace = new Namespace();

  /// List of [Header] objects in this [Lib]
  List<Header> get headers => _headers;

  /// List of [Impl] objects in this [Impl]
  List<Impl> impls = [];
  set requiresLogging(bool requiresLogging) =>
      _requiresLogging = requiresLogging;
  set libInitializer(LibInitializer libInitializer) =>
      _libInitializer = libInitializer;

  // custom <class Lib>

  Lib(Id id) : super(id);

  get libName => id.snake;

  set headers(Iterable<Header> hdrs) {
    _headers = new List<Header>.from(hdrs);
    _preserveStandardizedHeaders();
  }

  String get contents => indentBlock(br([
        '<<<< LIB($id) >>>>',
        concat([headers, impls]).map((CppFile f) =>
            indentBlock('<<<< FILE(${f.runtimeType}:${f.id}) >>>>', f.contents))
      ]));

  _preserveStandardizedHeaders() =>
      _standardizedHeaders.forEach((Header header) {
        if (header != null) {
          _logger.info('Preserved standardized header ${header.id}');
          _headers.add(header);
        }
      });

  set version(version_) => _version = version_ is SemanticVersion
      ? version_
      : version_ is String
          ? new SemanticVersion.fromString(version_)
          : throw new ArgumentError(
              'Lib version must be Semantic Version: $_version');

  get libInitializer => _libInitializer == null
      ? (_libInitializer = new LibInitializer())
      : _libInitializer;

  get requiresLibInitialization =>
      installation.logsApiInitializations || _libInitializer != null;

  withStandardizedHeader(
          StandardizedHeader headerType, f(Header standardizedHeader)) =>
      f(_includeStandardizedHeader(headerType));

  /// When need for standardized header is determined, this will ensure it has
  /// been initialized and included in [Lib]'s list of headers
  _includeStandardizedHeader(StandardizedHeader headerType) {
    switch (headerType) {
      case libCommonHeader:
        return _initCommonHeader();
      case libLoggingHeader:
        return _initLoggingHeader();
      case libInitializationHeader:
        return _initInitializationHeader();
      case libAllHeader:
        return _initAllHeader();
    }
  }

  /// Just a disptatch to find the potentially unneeded/unininitialized header
  /// instance. null value indicates uninitialized
  _getStandardizedHeader(StandardizedHeader headerType) {
    switch (headerType) {
      case libCommonHeader:
        return _commonHeader;
      case libLoggingHeader:
        return _loggingHeader;
      case libInitializationHeader:
        return _initializationHeader;
      case libAllHeader:
        return _allHeader;
    }
  }

  /// Determines what standard headers are required, initializes and initializes
  /// them
  _addStandardizedHeaders() {
    if (this.requiresLibInitialization) {
      _includeStandardizedHeader(libInitializationHeader);
    }

    if (this.requiresLogging) {
      _includeStandardizedHeader(libLoggingHeader);
    }
  }

  onOwnershipEstablished() {}

  get name => namer.nameLib(namespace, id);

  Iterable<CppEntity> get children => concat([headers, testScenarios]);

  /// Ensure any reference to [installation] gets the real root [Installation]
  /// of this [Lib].
  ///
  /// Without this, inadvertent call to [installation] refers to the function
  /// that creates an [Installation]
  Installation get installation => super.installation;

  /// Determines if logging is required.
  ///
  /// Logging is required if any [Loggable] requires logging or if any child
  /// [Header] or [Impl] requires it. To determine if any [Loggable] requires
  /// it, each class is tested for [requiresLogging]. Also, if the [Lib]
  /// requires initialization, logging is assumed required, since the generated
  /// lib intialization support uses it.
  get requiresLogging {
    return (requiresLibInitialization ||
            _requiresLogging != null && _requiresLogging) ||
        concat([headers, impls]).any((cls) => cls.requiresLogging);
  }

  /// List of the standardized headers (null indicating not needed)
  get _standardizedHeaders =>
      [_commonHeader, _loggingHeader, _initializationHeader, _allHeader];

  /// Determine if the header is one of the standardized headers
  _isStandardizedHeader(Header header) => _standardizedHeaders.contains(header);

  generate() {
    assert(installation != null);

    headers.forEach((Header header) {
      header.setFilePathFromRoot(installation.cppPath);

      // This header is not a standardized header
      if (!_isStandardizedHeader(header)) {
        [
          libCommonHeader,
          libLoggingHeader,
          libInitializationHeader,
          libAllHeader
        ].forEach((StandardizedHeader headerType) {
          final standardizedHeader = _getStandardizedHeader(headerType);

          if (standardizedHeader != null &&
              !header.excludesStandardizedHeader(headerType)) {
            header.includes.add(standardizedHeader.includeFilePath);
          }
        });
      }

      _logger.info('Generating ${header.id.snake}');
      header.generate();
    });

    impls.forEach((Impl impl) {
      if (impl.namespace == null) {
        impl.namespace = namespace;
      }
      impl.setLibFilePathFromRoot(installation.cppPath);
      impl.generate();
    });
  }

  get logProvider => installation.logProvider;
  get loggerVariableName => logProvider.loggerName(this);

  _initCommonHeader() {
    if (_commonHeader == null) {
      _commonHeader = header('${libName}_common')
        ..namespace = this.namespace
        ..owner = this;

      _logger.info('initilizing common header ${_commonHeader.id.snake}');

      headers.add(_commonHeader);
    }
    return _commonHeader;
  }

  _initLoggingHeader() {
    if (_loggingHeader == null) {
      _loggingHeader = logProvider.createLoggingHeader(this, this.namespace);
      headers.add(_loggingHeader);
    }
    return _initLoggingHeader;
  }

  _initAllHeader() {
    if (_allHeader == null) {
      _allHeader = header('${libName}_all')..namespace = this.namespace;
    }
  }

  /// As a design choice - Initialization includes a dependency on logging. If
  /// specialized initialization is required for a [Lib] - logging will be
  /// helpful.
  _initInitializationHeader() {
    if (_initializationHeader == null) {
      _initLoggingHeader();
      assert(_loggingHeader != null);
      _initializationHeader = header('${libName}_initialization')
        ..namespace = this.namespace
        ..getCodeBlock(fcbBeginNamespace).snippets.add('''
/// Initialization function for $libName
inline void ${libName}_init() {
#if defined(LIB_INIT_LOGGING)
  $loggerVariableName->info("init of ${libName} ($version)");
#endif
}

/// Uninitialization function for $libName
inline void ${libName}_uninit() {
#if defined(LIB_INIT_LOGGING)
  $loggerVariableName->info("uninit of ${libName} ($version)");
#endif
}

/// Singleton for $libName initializer
inline ebisu::raii::Api_initializer<> ${libName}_initializer_() {
  static ebisu::raii::Api_initializer<> ${libName}_initializer {
    ${libName}_init,
    ${libName}_uninit
  };
  return ${libName}_initializer;
}

/// Internal linkage (i.e. 1 per translation unit) initializer for $libName
namespace {
  ebisu::raii::Api_initializer<>
  ${libName}_initializer { ${libName}_initializer_() };
}
''')
        ..includes.addAll(
            ['ebisu/raii/api_initializer.hpp', _loggingHeader.includeFilePath])
        ..owner = this;
      headers.add(_initializationHeader);
    }
    return _initializationHeader;
  }

  String toString() => '''
    lib($id)
      headers:\n${headers.map((h) => h.toString()).join('\n')}
''';

  // end <class Lib>

  SemanticVersion _version = new SemanticVersion(0, 0, 0);
  List<Header> _headers = [];
  bool _requiresLogging;
  LibInitializer _libInitializer;

  /// A header for placing types and definitions to be shared among all
  /// other headers in the [Lib]. If this were used for windows, this would
  /// be a good place for the API decl definitions.
  Header _commonHeader;

  /// A header for initializing a single logger for the [Lib] if required
  Header _loggingHeader;

  /// For [Lib]s that need certain *initialization*/*uninitialization*
  /// functions to be run this will provide a mechanism.
  Header _initializationHeader;

  /// A single header including all other headers - intended as a
  /// convenience mechanism for clients not so worried about compile times.
  Header _allHeader;
}

// custom <part lib>

Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));

// end <part lib>
