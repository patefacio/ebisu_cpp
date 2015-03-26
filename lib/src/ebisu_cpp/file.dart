part of ebisu_cpp.ebisu_cpp;

/// Establishes an interface and common elements for c++ file, such as
/// *Header* and *Impl*.
abstract class CppFile extends Entity {
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
  /// List of includes required by this c++ file
  Includes get includes => _includes;
  /// List of c++ *constexprs* that will appear near the top of the file
  List<ConstExpr> constExprs = [];
  /// List of forward declarations that will appear near the top of the file
  List<ForwardDecl> forwardDecls = [];
  /// List of using statements that will appear near the top of the file
  List<String> usings = [];
  /// List of enumerations that will appear near the top of the file
  List<Enum> enums = [];
  /// List of interfaces for this header. Interfaces result in either:
  ///
  /// * abstract base class with pure virtual methods
  /// * static polymorphic base class with inline forwarding methods
  List<Interface> interfaces = [];
  // custom <class CppFile>

  CppFile(Id id) : super(id);

  String get contents;
  String get filePath;

  set includes(Object h) => _includes = _makeIncludes(h);

  Iterable<Entity> get children => concat([classes, constExprs, enums]);

  _makeIncludes(Object h) => h is Iterable
      ? new Includes(h)
      : h is String
          ? new Includes([h])
          : h is Includes
              ? h
              : throw 'Includes must be String, List<String> or Includes';

  generate() =>
      (Platform.environment['EBISU_CLANG_FORMAT'] != null || useClangFormatter)
          ? mergeWithFile(contents, filePath, customBegin, customEnd,
              (String txt) => clangFormat(txt, '${id.snake}.cpp'))
          : mergeWithFile(contents, filePath);

  CodeBlock getCodeBlock(FileCodeBlock fcb) {
    final result = _codeBlocks[fcb];
    return result == null ? (_codeBlocks[fcb] = codeBlock()) : result;
  }

  String get _contentsWithBlocks {
    if (classes.any((c) => c._opMethods.any((m) => m is OpOut))) {
      _includes.add('fcs/utils/block_indenter.hpp');
    }
    customBlocks
        .forEach((cb) => getCodeBlock(cb).tag = '${evCap(cb)} ${id.snake}');

    if (namespace == null) {
      throw new ArgumentError(
          'Yikes! provide a namespace: ${runtimeType} ${id.snake}');
    }

    return combine([
      br(_includes.includes),
      _codeBlockText(fcbCustomIncludes),
      _codeBlockText(fcbPreNamespace),
      namespace.wrap(combine([
        _codeBlockText(fcbBeginNamespace),
        br(interfaces.map((i) => i.definition)),
        br(constExprs),
        forwardDecls,
        br(usings.map((u) => 'using $u;')),
        br(enums.map((Enum e) => br(e.decl))),
        br(classes.map((Class cls) => br(cls.definition))),
        _codeBlockText(fcbEndNamespace)
      ])),
      _codeBlockText(fcbPostNamespace),
    ]);
  }

  _codeBlockText(FileCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null ? codeBlock.toString() : null;
  }

  // end <class CppFile>
  /// Mapping of the *FileCodeBlock* to the corresponding *CodeBlock*.
  Map<FileCodeBlock, CodeBlock> _codeBlocks = {};
  Includes _includes = new Includes();
}
// custom <part file>

bool useClangFormatter = false;

// end <part file>
