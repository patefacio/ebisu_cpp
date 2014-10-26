part of ebisu_cpp.cpp;

class Test extends Impl with InstallationCodeGenerator {

  String get filePath => _filePath;
  List<Header> headers = [];
  List<Impl> impls = [];
  List<String> requiredLibs = [];

  // custom <class Test>

  Test(Id id) : super(id);

  Namespace get namespace => super.namespace;

  get testFilePath => path.join(namespace.asPath, 'test_${id.snake}.cpp');

  setFilePathFromRoot(String root) =>
    _filePath = path.join(root, testFilePath);

  String get contents {
    getCodeBlock(fcbPostNamespace).snippets.add('''

boost::unit_test::test_suite* init_unit_test_suite(int , char*[]) {
  ${namespace.using};
  using namespace boost::unit_test;
  test_suite* test= BOOST_TEST_SUITE( "Unit test <${id.snake}>" );
  test->add( BOOST_TEST_CASE( &test_api_initializer ) );
  return test;
}
''');

    return _contentsWithBlocks(
      combine([
        '''
void ${id.snake}() {
}


''']));
  }

  generate() {
    super.generate();
  }

  // end <class Test>
  String _filePath;
}
// custom <part test>
// end <part test>
