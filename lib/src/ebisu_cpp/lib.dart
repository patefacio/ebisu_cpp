part of ebisu_cpp.ebisu_cpp;

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

/// A c++ library
class Lib extends Entity with Testable implements CodeGenerator {
  Namespace namespace = new Namespace();
  List<Header> headers = [];
  List<Impls> impls = [];
  List<Test> tests = [];

  // custom <class Lib>

  Lib(Id id) : super(id);

  get name => namer.nameLib(namespace, id);

  get allTests => new List.from(tests);

  Iterable<Entity> get children => concat([headers, tests]);

  Installation get installation => super.installation;

  generate() {
    assert(installation != null);

    final apiHeaders = headers.where((h) => h.isApiHeader);
    Header apiHeader;

    if (apiHeaders.length > 1) {
      throw '''A library may have only one api header:
[ ${apiHeaders.map((h)=>h.id).join(', ')} ]''';
    } else if (apiHeaders.isNotEmpty) {
      apiHeader = apiHeaders.first;
    }

    final cpp = installation.paths["cpp"];
    headers.forEach((Header header) {
      if (header.namespace == null) {
        header.namespace = namespace;
      }
      header.setFilePathFromRoot(installation.cppPath);

      if (apiHeader != null && apiHeader != header) header.includes
          .add(apiHeader.includeFilePath);

      header.generate();
    });

    impls.forEach((Impl impl) {
      if (impl.namespace == null) {
        impl.namespace = namespace;
      }
      impl.setLibFilePathFromRoot(installation.cppPath);

      impl.generate();
    });

    //generateTests();
  }

  generateTests() {
    Map pathToTests = {};
    headers.where((header) => header.hasTest).forEach((header) {
      header.test
        ..namespace = header.namespace
        ..setFilePathFromRoot(path.join(installation.cppPath, 'tests'))
        ..generate();

      final test = header.test;
      final directory = path.dirname(test.filePath);
      var dirTests = pathToTests[directory];
      if (dirTests == null) dirTests = (pathToTests[directory] = []);
      dirTests.add(test);
      tests.add(test);
    });
  }

  String toString() => '''
    lib($id)
      headers:\n${headers.map((h) => h.toString()).join('\n')}
      tests:\n${tests.map((t) => t.name).join('\n')}
''';

  // end <class Lib>

}

// custom <part lib>

Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));

// end <part lib>
