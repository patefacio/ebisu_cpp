part of ebisu_cpp.ebisu_cpp;

class Test extends Impl implements CodeGenerator {
  Testable testable;
  List<Header> headers = [];
  List<Impl> impls = [];
  Map<String, String> get testImplementations => _testImplementations;
  List<String> requiredLibs = [];

  // custom <class Test>

  Test(Testable testable)
      : super((testable as Entity).id),
        testable = testable {
    _logger.info('Creating test with ${(testable as Entity).id.snake}');
    _includes.addAll(['boost/test/included/unit_test.hpp',]);
  }

  Namespace get namespace => super.namespace;

  get name => 'test_${id.snake}';
  get testCppFile => '$name.cpp';
  get sources =>
      [path.basename(filePath)]..addAll(impls.map((i) => i.id.snake));

  _testFilePathFromRoot([fileBasename]) => path.join(
      namespace.asPath, fileBasename == null ? testCppFile : fileBasename);

  addTestImplementations(Map<String, String> impls) =>
      _testImplementations.addAll(impls);

  setFilePathFromRoot(String root, [fileBasename]) =>
      _filePath = path.join(root, _testFilePathFromRoot(fileBasename));

  get testFunctions => testable.testFunctions;
  get testNames => concat([testFunctions, testImplementations.keys]);

  String get contents => _contentsWithBlocks;

  generate() => super.generate();

  // end <class Test>

  Map<String, String> _testImplementations = {};
}

// custom <part test>
// end <part test>
