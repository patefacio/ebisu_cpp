part of ebisu_cpp.cpp;

/// Set of pre-canned blocks where custom or generated code can be placed
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

/// A c++ library
class Lib extends Entity with InstallationContainer implements CodeGenerator {
  Namespace namespace = new Namespace();
  List<Header> headers = [];
  List<Test> tests = [];
  // custom <class Lib>

  Lib(Id id) : super(id);
  get snake => '${namespace.snake}';

  get allTests => new List.from(tests);

  generate() {
    if (installation == null) {
      installation = new Installation(new Id('tmp'))..root = '/tmp';
    }

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

    generateTests();
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

    if (installation.wantsJam) {
      pathToTests.forEach((directory, tests) {
        new JamTestBuilder(this, directory, tests).generate();
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
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));

// end <part lib>
