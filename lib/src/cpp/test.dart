part of ebisu_cpp.cpp;

class Test extends Impl with InstallationCodeGenerator {

  String get filePath => _filePath;
  Header headerUnderTest;
  List<Header> headers = [];
  List<Impl> impls = [];
  List<String> get testFunctions => _testFunctions;
  Map<String, String> get testImplementations => _testImplementations;
  List<String> requiredLibs = [];

  // custom <class Test>

  Test(Header header) : super(header.id),
                        headerUnderTest = header
  {
    _includes.addAll([
      'boost/test/included/unit_test.hpp',
    ]);
  }

  Namespace get namespace => super.namespace;
  get basename => id.snake;
  get name => 'test_$basename';
  get testCppFile => '$name.cpp';
  get cppFiles => [ testCppFile ];
  get testFilePathFromRoot => path.join(namespace.asPath, testCppFile);

  addTestFunctions(Iterable<String> testFunction) =>
    _testFunctions.addAll(testFunction);

  addTestImplementations(Map<String, String> impls) =>
    _testImplementations.addAll(impls);

  setFilePathFromRoot(String root) =>
    _filePath = path.join(root, testFilePathFromRoot);

  get testNames => concat([testFunctions, testImplementations.keys]);
  String get contents {
    _includes.add(headerUnderTest.includeFilePath);
    _testFunctions.addAll(headerUnderTest.testFunctions);
    getCodeBlock(fcbPostNamespace).snippets.add('''

boost::unit_test::test_suite* init_unit_test_suite(int , char*[]) {
  ${namespace.using};
  using namespace boost::unit_test;
  test_suite* test= BOOST_TEST_SUITE( "<${id.snake}>" );
${
indentBlock(
  combine(
    testNames.map((f) => 'test->add( BOOST_TEST_CASE( &test_$f ) );')))
}
  return test;
}
''');

    return _contentsWithBlocks(
      combine([
        testFunctions.map((f) => '''
void test_$f() {
${chomp(indentBlock(customBlock(f)))}
}
'''),
        testImplementations.keys.map((t) => '''
void test_$t() {
${chomp(indentBlock(testImplementations[t]))}
}
''')]));
  }

  generate() {
    super.generate();
  }

  // end <class Test>
  String _filePath;
  List<String> _testFunctions = [];
  Map<String, String> _testImplementations = {};
}

/// Creates builder for test folder
abstract class TestBuilder implements CodeGenerator {

  TestBuilder(this.lib, this.directory, this.tests);

  Lib lib;
  String directory;
  List<Test> tests;

  // custom <class TestBuilder>

  // end <class TestBuilder>
}
// custom <part test>
// end <part test>
