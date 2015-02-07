part of ebisu_cpp.cpp;

enum FileCodeBlock {
  fcbCustomIncludes,
  fcbPreNamespace,
  fcbPostNamespace,
  fcbBeginNamespace,
  fcbEndNamespace
}
const fcbCustomIncludes = FileCodeBlock.fcbCustomIncludes;
const fcbPreNamespace = FileCodeBlock.fcbPreNamespace;
const fcbPostNamespace = FileCodeBlock.fcbPostNamespace;
const fcbBeginNamespace = FileCodeBlock.fcbBeginNamespace;
const fcbEndNamespace = FileCodeBlock.fcbEndNamespace;


class Lib extends Entity with InstallationCodeGenerator {
  Namespace namespace = new Namespace();
  List<Header> headers = [];
  List<Test> tests = [];
  // custom <class Lib>

  Lib(Id id) : super(id);
  get snake => '${namespace.snake}';

  get allTests => new List.from(tests);

  generate() {
    if(installation == null) {
      installation = new Installation(new Id('tmp'))
        ..root = '/tmp';
    }

    final apiHeaders = headers.where((h) => h.isApiHeader);
    Header apiHeader;

    if(apiHeaders.length > 1) {
      throw '''A library may have only one api header:
[ ${apiHeaders.map((h)=>h.id).join(', ')} ]''';
    } else if(apiHeaders.isNotEmpty) {
      apiHeader = apiHeaders.first;
    }

    final cpp = installation.paths["cpp"];
    headers.forEach((Header header) {
      if(header.namespace == null) {
        header.namespace = namespace;
      }
      header.setFilePathFromRoot(installation.cppPath);

      if(apiHeader != null && apiHeader != header)
        header.includes.add(apiHeader.includeFilePath);

      header.generate();
    });

    generateTests();
  }

  generateTests() {
    Map pathToTests = {};
    headers
      .where((header) => header.hasTest)
      .forEach((header) {
         header.test
           ..namespace = header.namespace
           ..setFilePathFromRoot(path.join(installation.cppPath, 'tests'))
           ..generate();

         final test = header.test;
         final directory = path.dirname(test.filePath);
         var dirTests = pathToTests[directory];
         if(dirTests == null)
           dirTests = (pathToTests[directory] = []);
         dirTests.add(test);
         tests.add(test);
       });

    if(installation.wantsJam) {
      pathToTests.forEach((directory, tests) {
        new JamTestBuilder(this, directory, tests)
          .generate();
      });
    }
  }

  String toString() => '''
    lib($id)
      headers:\n${headers.map((h) => h.toString()).join('\n')}
      tests:\n${tests.map((t) => t.name).join('\n')}
''';

  // end <class Lib>
}

class Header extends CppFile {
  String get filePath => _filePath;
  bool includeTest = false;
  /// If true marks this header as special to the set of headers in its library in that:
  /// (1) It will be automatically included by all other headers
  /// (2) For windows systems it will be the place to provide the api decl support
  /// (3) Will have code that initializes the api
  bool isApiHeader = false;
  // custom <class Header>

  Header(Id id) : super(id);

  Namespace get namespace => super.namespace;

  Test get test => _test == null? (_test = new Test(this)) : _test;
  bool get hasTest => includeTest || _test != null || classes.any((c) => c.includeTest);
  Iterable get testFunctions => (includeTest? [ id.snake ] : [])
    ..addAll(classes.where((c) => c.includeTest).map((c) => c.id.snake));

  get includeFilePath => path.join(namespace.asPath, '${id.snake}.hpp');

  setFilePathFromRoot(String root) =>
    _filePath = path.join(root, includeFilePath);

  String get contents {

    if(classes.any((c) => c.streamable) &&
        !this.includes.contains('iostream')) {
      this.includes.add('iosfwd');
    }

    if(classes.any((c) => c.serializers.any((s) => s is Cereal))) {
      this.includes.addAll([
        'cereal/cereal.hpp',
        'fcs/timestamp/cereal.hpp',
        'cereal/archives/json.hpp',
      ]);
    }

    if(classes.any((c) => c.serializers.any((s) => s is DsvSerializer))) {
      this.includes.addAll([
        'cppformat/format.h',
      ]);
    }

    addIncludesForCommonTypes(
      concat(classes.map((c) => c.typesReferenced)),
      this.includes);

    return _wrapIncludeGuard(
      _contentsWithBlocks(
        combine([
          enums.map((Enum e) => br(e.decl)),
          classes.map((Class cls) => br(cls.definition)),
        ])));
  }

  String toString() => '''
        header($id)
          classes:[${classes.map((cls) => cls.className).join(', ')}]
''';

  String get _includeGuard => namespace == null? '__${id.shout}__' :
    '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${id.shout}_HPP__';

  String _wrapIncludeGuard(String text) =>'''
#ifndef $_includeGuard
#define $_includeGuard

$text
#endif // $_includeGuard
''';

  // end <class Header>
  String _filePath;
  Test _test;
}

class Impl extends CppFile {
  String get filePath => _filePath;
  // custom <class Impl>

  Impl(Id id) : super(id);

  Namespace get namespace => super.namespace;

  String get contents =>
    _contentsWithBlocks(
      combine([
        enums.map((Enum e) => br(e.decl)),
        classes.map((Class cls) => br(cls.definition))]));

  setLibFilePathFromRoot(String root) =>
    _filePath = path.join(root, 'lib', namespace.asPath, '${id.snake}.cpp');

  setAppFilePathFromRoot(String root) =>
    _filePath = path.join(root, 'app', id.snake, '${id.snake}.cpp');

  // end <class Impl>
  String _filePath;
}
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id? id : new Id(id));
Header header(Object id) => new Header(id is Id? id : new Id(id));
Impl impl(Object id) => new Impl(id is Id? id : new Id(id));

// end <part lib>
