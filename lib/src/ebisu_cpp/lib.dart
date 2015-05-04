part of ebisu_cpp.ebisu_cpp;

/// Common headers unique to a [Lib] designed to provide consistency and
/// facilitate library usage.
///
/// - lib_common_header: For a given [Lib], a place to put common types,
///   declarations that need to be included by all other headers in the
///   lib. If requested for a [Lib], all other headers in the [Lib] will
///   inlude this. Therefore, it is important that this header *not*
///   include other *non-common* headers in the [Lib]. The naming
///   convention is: LIBNAME_common.hpp
///
/// - [LibLoggingHeader]: For a given [Lib] a header to provide a logger
///   instance. If requested for a [Lib], all other headers in the [Lib]
///   will include this indirectly via *lib_common_header*. The naming
///   convention is: LIBNAME_logging.hpp
///
/// - [LibInitializationHeader]: For a given [Lib] a header to provide
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
///
class LibInitializer {
  CodeBlock initCustomBlock;
  CodeBlock uninitCustomBlock;

  // custom <class LibInitializer>
  // end <class LibInitializer>

}

/// A c++ library
///
class Lib extends CppEntity with Testable implements CodeGenerator {
  Namespace namespace = new Namespace();
  List<Header> headers = [];
  List<Impl> impls = [];
  set requiresLogging(bool requiresLogging) =>
      _requiresLogging = requiresLogging;
  set libInitializer(LibInitializer libInitializer) =>
      _libInitializer = libInitializer;

  // custom <class Lib>

  Lib(Id id) : super(id);

  get libInitializer => _libInitializer == null
      ? (_libInitializer = new LibInitializer())
      : _libInitializer;

  get requiresLibInitialization =>
      installation.logsApiInitializations || _libInitializer != null;

  withStandardizedHeader(
          StandardizedHeader headerType, f(Header standardizedHeader)) =>
      f(includeStandardizedHeader(headerType));

  includeStandardizedHeader(StandardizedHeader headerType) {
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

  includeStandardizedHeaders(
          Iterable<StandardizedHeader> standardizedHeaders) =>
      standardizedHeaders.forEach((hdr) => includeStandardizedHeader(hdr));

  onOwnershipEstablished() {
    if (this.requiresLibInitialization) {
      includeStandardizedHeader(libInitializationHeader);
    }

    if (this.requiresLogging) {
      includeStandardizedHeader(libLoggingHeader);
    }
  }

  get name => namer.nameLib(namespace, id);

  Iterable<CppEntity> get children => concat([headers, testScenarios]);

  Installation get installation => super.installation;

  get requiresLogging {
    return (requiresLibInitialization ||
            _requiresLogging != null && _requiresLogging) ||
        concat([headers, impls]).any((cls) => cls.requiresLogging);
  }

  _isStandardizedHeader(Header header) => [
    _commonHeader,
    _loggingHeader,
    _initializationHeader,
    _allHeader
  ].contains(header);

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
  get loggerVariableName => logProvider.libLoggerName(this);

  _initCommonHeader() {
    if (_commonHeader == null) {
      _commonHeader = header('${id.snake}_common')
        ..namespace = this.namespace
        ..owner = this;
      print('Inited common header ${_commonHeader.id}');
      headers.add(_commonHeader);
    }
    return _commonHeader;
  }

  _initLoggingHeader() {
    if (_loggingHeader == null) {
      _loggingHeader = header('${id.snake}_logging')
        ..namespace = this.namespace
        ..includes.mergeIncludes(logProvider.includeRequirements)
        ..getCodeBlock(fcbBeginNamespace).snippets
            .add(logProvider.createLibLogger(this))
        ..owner = this;
      headers.add(_loggingHeader);
    }
    return _initLoggingHeader;
  }

  /// As a design choice - Initialization includes a dependency on logging. If
  /// specialized initialization is required for a [Lib] - logging will be
  /// helpful.
  _initInitializationHeader() {
    if (_initializationHeader == null) {
      _initLoggingHeader();
      assert(_loggingHeader != null);
      final libName = id.snake;
      _initializationHeader = header('${libName}_initialization')
        ..namespace = this.namespace
        ..getCodeBlock(fcbBeginNamespace).snippets.add('''
void ${libName}_init() {
  $loggerVariableName->info("init of ${libName}");
}

void ${libName}_uninit() {
  $loggerVariableName->info("uninit of ${libName}");
}

fcs::raii::Api_initializer<> ${libName}_initializer {
  ${libName}_init,
  ${libName}_uninit
};
''')
        ..includes.addAll(
            ['fcs/raii/api_initializer.hpp', _loggingHeader.includeFilePath])
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

  bool _requiresLogging;
  LibInitializer _libInitializer;
  Header _commonHeader;
  Header _loggingHeader;
  Header _initializationHeader;
  Header _allHeader;
}

// custom <part lib>

Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));

// end <part lib>
