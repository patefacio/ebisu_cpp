part of ebisu_cpp.ebisu_cpp;

/// Establishes an interface and common elements for c++ file, such as
/// *Header* and *Impl*.
abstract class CppFile extends CppEntity with Testable {
  /// Namespace associated with this file
  Namespace namespace;

  /// List of blocks requiring custom code and therefore inserted into the
  /// file with *Protect Blocks*. Note it is a list of *FileCodeBlock*
  /// enumeration values. *CodeBlocks* can be used to inject code into
  /// the location designated by their value. Additionally *CodeBlocks*
  /// have support for a single custom *Protect Block*
  List<FileCodeBlock> customBlocks = [];

  /// List of classes whose definitions are included in this file
  List<Class> classes = [];

  /// List of c++ *constexprs* that will appear near the top of the file
  List<ConstExpr> constExprs = [];

  /// List of forward declarations that will appear near the top of the file
  List<ForwardDecl> forwardDecls = [];

  /// List of using statements that will appear near the top of the file
  List<Using> get usings => _usings;

  /// List of enumerations that will appear near the top of the file
  List<Enum> enums = [];

  /// List of interfaces for this header. Interfaces result in either:
  ///
  /// * abstract base class with pure virtual methods
  /// * static polymorphic base class with inline forwarding methods
  List<Interface> interfaces = [];
  String get basename => _basename;
  String get filePath => _filePath;

  /// If true includes comment about code being generated as well as a stack
  /// trace to help find the dart code that generated the source.
  set includeStackTrace(bool includeStackTrace) =>
      _includeStackTrace = includeStackTrace;

  // custom <class CppFile>

  CppFile(id) : super(id);

  String get contents;

  excludeStandardizedHeader(StandardizedHeader headerType) =>
      _standardizedInclusions[headerType] = false;

  includeStandardizedHeader(StandardizedHeader headerType) =>
      _standardizedInclusions[headerType] = true;

  includesStandardizedHeader(StandardizedHeader headerType) =>
      _standardizedInclusions[headerType] == true;

  excludesStandardizedHeader(StandardizedHeader headerType) =>
      _standardizedInclusions[headerType] == false;

  set includes(Object h) => _includes = _makeIncludes(h);

  /// Set the [Using] statements for the [CppFile].
  ///
  /// Each file has one or more usings appearing within the namespace, near the
  /// beginning before any file classes
  set usings(Iterable<Using> items) =>
      _usings = items.map((u) => using(u)).toList();

  Iterable<Entity> get children => concat([
        classes,
        constExprs,
        enums,
        usings,
        _test == null ? [] : [test],
        testScenarios,
        interfaces
      ]);

  get includeStackTrace => _includeStackTrace == null
      ? ((this.installation != null &&
              this.installation.includeStackTrace != null)
          ? this.installation.includeStackTrace
          : false)
      : _includeStackTrace;

  String get wrappedContents =>
      includeStackTrace ? tagGeneratedContent(contents) : contents;

  generate() =>
    (Platform.environment['EBISU_CLANG_FORMAT'] != null || useClangFormatter)
    ? mergeWithFile(wrappedContents, filePath, customBegin, customEnd,
        (txt) => clangFormatFile(txt, filePath))
    : mergeWithFile(wrappedContents, filePath);

  /// Returns the codeblock specified by [fcb]
  ///
  /// Provides a mechanism for accessing and thus modifying a [CodeBlock]
  /// specified by [fcb]. For example, the following will get the codeblock at
  /// the beginning of the header's namespace and add some text.
  ///
  ///        someHeader
  ///          ..getCodeBlock(fcbBeginNamespace)
  ///              .snippets
  ///              .add(createLoggerInstance(owner))
  ///          ....
  ///
  /// See also: [withCustomBlock]
  CodeBlock getCodeBlock(FileCodeBlock fcb) {
    final result = _codeBlocks[fcb];
    return result == null ? (_codeBlocks[fcb] = codeBlock()) : result;
  }

  /// Invoke the function [f] on code block specifed by [fcb]
  ///
  /// Provides a mechanism for adding code to a file at a particular location
  /// indicated by [fcb]. For example, if *test* is a CppFile, the
  /// [withCustomBlock] call below updates the [fcbPreIncludes] section by adding
  /// a define.
  ///
  ///      test
  ///        ..withCustomBlock(fcbPreIncludes,
  ///            (cb) => cb.snippets.add('#define CATCH_CONFIG_MAIN'))
  ///
  withCustomBlock(FileCodeBlock fcb, f(CodeBlock)) => f(getCodeBlock(fcb));

  String get _contentsWithBlocks {
    if (classes.any((c) => c._opMethods.any((m) => m is OpOut))) {
      _includes.add('ebisu/utils/block_indenter.hpp');
    }
    customBlocks
        .forEach((cb) => getCodeBlock(cb).tag = '${evCap(cb)} ${id.snake}');

    if (namespace == null) {
      throw new ArgumentError(
          'Yikes! provide a namespace: ${runtimeType} ${id.snake}');
    }

    _usingFormatted(u) => (u.hasComment ? '\n' : '') + u.usingStatement(namer);

    return br([
      brCompact([briefComment, _codeBlockText(fcbPreIncludes)]),
      allIncludes.includes,
      _codeBlockText(fcbCustomIncludes),
      _codeBlockText(fcbPreNamespace),
      namespace.wrap(br([
        _codeBlockText(fcbBeginNamespace),
        // TODO: determine strategy for interfaces in a file: .... br(interfaces.map((i) => i.definition)),
        br(constExprs),
        forwardDecls,
        brCompact(usings.map((u) => _usingFormatted(u))),
        br(enums),
        br(classes.map((Class cls) => br(cls.definition))),
        _codeBlockText(fcbEndNamespace)
      ])),
      _codeBlockText(fcbPostNamespace),
    ]);
  }

  set __basename(String name) => _basename = name;

  _makeIncludes(Object h) => h is Iterable
      ? new Includes(h)
      : h is String
          ? new Includes([h])
          : h is Includes
              ? h
              : throw 'Includes must be String, List<String> or Includes';

  _codeBlockText(FileCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null ? codeBlock.toString() : null;
  }

  // end <class CppFile>

  /// Mapping of the *FileCodeBlock* to the corresponding *CodeBlock*.
  Map<FileCodeBlock, CodeBlock> _codeBlocks = {};
  List<Using> _usings = [];
  String _basename;
  String _filePath;

  /// A list of [StandardizedHeader] indexed bool values indicating desire
  /// to include/exclude given header.
  Map<StandardizedHeader, bool> _standardizedInclusions = {};
  bool _includeStackTrace;
}

// custom <part file>

bool useClangFormatter = false;

// end <part file>
