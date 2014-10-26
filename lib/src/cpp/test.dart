part of ebisu_cpp.cpp;

class Test extends Impl with InstallationCodeGenerator {

  String get filePath => _filePath;
  Header headerUnderTest;
  List<Header> headers = [];
  List<Impl> impls = [];
  List<String> get testFunctions => _testFunctions;
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

  get testFilePath => path.join(namespace.asPath, 'test_${id.snake}.cpp');

  setFilePathFromRoot(String root) =>
    _filePath = path.join(root, testFilePath);

  String get contents {
    _includes.add(headerUnderTest.includeFilePath);
    _testFunctions = headerUnderTest.testFunctions.toList();
    getCodeBlock(fcbPostNamespace).snippets.add('''

boost::unit_test::test_suite* init_unit_test_suite(int , char*[]) {
  ${namespace.using};
  using namespace boost::unit_test;
  test_suite* test= BOOST_TEST_SUITE( "<${id.snake}>" );
${
indentBlock(
  combine(
    testFunctions.map((f) => 'test->add( BOOST_TEST_CASE( &test_$f ) );')))
}
  return test;
}
''');

    return _contentsWithBlocks(
      combine(testFunctions.map((f) => '''
void test_$f() {
${chomp(indentBlock(customBlock(f)))}
}
''')));
  }

  generate() {
    super.generate();
  }

  // end <class Test>
  String _filePath;
  List<String> _testFunctions = [];
}
// custom <part test>
// end <part test>
