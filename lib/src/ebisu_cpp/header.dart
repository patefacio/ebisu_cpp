part of ebisu_cpp.ebisu_cpp;

/// A single c++ header
class Header extends CppFile {
  String get filePath => _filePath;
  bool includesTest = false;
  /// If true marks this header as special to the set of headers in its library in that:
  /// (1) It will be automatically included by all other headers
  /// (2) For windows systems it will be the place to provide the api decl support
  /// (3) Will have code that initializes the api
  bool isApiHeader = false;

  // custom <class Header>

  Header(Id id) : super(id);

  Namespace get namespace => super.namespace;

  Test get test => _test == null ? (_test = new Test(this)) : _test;

  /// Provides access to this header's test as function for declarative
  /// manipulation:
  ///
  ///     header('h')
  ///     ..doc
  ///     ..withTest((Test test) {
  ///        test
  ///        ..includes.addAll([...])
  ///        ...
  ///     });
  withTest(void t(Test t)) => t(test);

  /// Returns true if user requested [includesTest] = true or any
  /// classes have [includesTest] = true
  bool get hasTest =>
      includesTest || _test != null || classes.any((c) => c.includesTest);

  Iterable get testFunctions => (includesTest ? [id.snake] : [])
    ..addAll(classes.where((c) => c.includesTest).map((c) => c.id.snake));

  get includeFilePath => path.join(namespace.asPath, namer.nameHeader(id));

  setFilePathFromRoot(String root) =>
      _filePath = path.join(root, includeFilePath);

  String get contents {
    if (classes.any((c) => c.isStreamable) &&
        !this.includes.contains('iostream')) {
      this.includes.add('iosfwd');
    }

    if (classes.any((c) => c.serializers.any((s) => s is Cereal))) {
      this.includes.addAll([
        'cereal/cereal.hpp',
        'fcs/timestamp/cereal.hpp',
        'cereal/archives/json.hpp',
      ]);
    }

    if (classes.any((c) => c.serializers.any((s) => s is DsvSerializer))) {
      this.includes.addAll(['cppformat/format.h',]);
    }

    addIncludesForCommonTypes(
        concat(classes.map((c) => c.typesReferenced)), this.includes);

    return _wrapIncludeGuard(_contentsWithBlocks);
  }

  String toString() => '''
        header($id)
          classes:[${classes.map((cls) => cls.className).join(', ')}]
''';

  String get _includeGuard => namespace == null
      ? '__${id.shout}__'
      : '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${id.shout}_HPP__';

  String _wrapIncludeGuard(String text) => '''
#ifndef $_includeGuard
#define $_includeGuard

$text
#endif // $_includeGuard
''';

  // end <class Header>

  String _filePath;
  Test _test;
}

// custom <part header>
Header header(Object id) => new Header(id is Id ? id : new Id(id));
// end <part header>
