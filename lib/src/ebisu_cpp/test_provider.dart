part of ebisu_cpp.ebisu_cpp;

/// The various supported code blocks associated with *TestClause*.
/// The *TestClauses* are modeled after the *Catch* library *BDD* approach.
///
enum TcCodeBlock {
  /// The custom block appearing at the start of the clause
  tcOpen,
  /// The custom block appearing at the end of the clause
  tcClose
}
/// Convenient access to TcCodeBlock.tcOpen with *tcOpen* see [TcCodeBlock].
///
/// The custom block appearing at the start of the clause
///
const TcCodeBlock tcOpen = TcCodeBlock.tcOpen;

/// Convenient access to TcCodeBlock.tcClose with *tcClose* see [TcCodeBlock].
///
/// The custom block appearing at the end of the clause
///
const TcCodeBlock tcClose = TcCodeBlock.tcClose;

/// Models common elements of the *Given*, *When*, *Then* clauses.
/// Each *TestClause* has its own [clause] text associated with it
/// and [CodeBlock]s to augment/initialize/teardown.
///
abstract class TestClause extends Entity {
  CodeBlock startCodeBlock = new CodeBlock(null);
  CodeBlock endCodeBlock = new CodeBlock(null);

  // custom <class TestClause>

  TestClause(testClause) : super(makeId(testClause)) {
    startCodeBlock = new CodeBlock(id.sentence);
  }

  get clause => id;

  /// Give the clause codeblock a uniqueId to allow for clauses in different
  /// places in the same file with the same name. The uniqueId is simply a hash
  /// of the *entityPathIds* so its value is unique and random looking but
  /// reproducibly determinnistic by virtue of its plath in the entity tree
  get _uniqueTag => '(${uniqueId}) ${id.sentence}';

  get startBlockText => startCodeBlock.hasContent
      ? (startCodeBlock..tag = _uniqueTag).toString()
      : '';

  get endBlockText => endCodeBlock.hasContent ? endCodeBlock.toString() : '';

  // end <class TestClause>

}

class Then extends TestClause {
  bool isAnd = false;

  // custom <class Then>

  Then(Id thenClause, [this.isAnd]) : super(thenClause);
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  toString() => '''
Then(${clause.snake})
''';

  // end <class Then>

}

class When extends TestClause {
  List<Then> thens;

  // custom <class When>

  When(Id whenClause, this.thens) : super(whenClause);
  Iterable<Entity> get children => thens;

  addThen(clause, [isAnd]) => (thens..add(then(clause, isAnd))).last;

  addAndThen(clause) => (thens..add(then(clause, true))).last;

  toString() => '''
When(${clause.snake})
${indentBlock(br(thens))}
''';

  // end <class When>

}

class Given extends TestClause {
  List<When> whens;

  // custom <class Given>

  Given(Id givenClause, this.whens) : super(givenClause);
  Iterable<Entity> get children => whens;

  addWhen(clause, [withThens]) => (whens..add(when(clause, withThens))).last;

  withWhen(clause, f(when)) => f((whens..add(when(clause))).last);

  toString() => '''
Given(${clause.snake})
${indentBlock(br(whens))}
''';

  // end <class Given>

}

class TestScenario extends Entity {
  List<Given> givens;

  // custom <class TestScenario>

  TestScenario(id, this.givens) : super(id);

  Iterable<Entity> get children => givens;

  addGiven(clause, [withWhens]) => (givens..add(given(clause, withWhens))).last;

  withGiven(clause, f(given)) => f((givens..add(given(clause))).last);

  toString() => '''
TestScenario(${id.snake})
${indentBlock(br(givens))}
''';

  // end <class TestScenario>

}

class Testable {
  List<TestScenario> testScenarios = [];
  /// The implementation file for this test
  Impl testImpl;
  /// The single test for this [Testable]
  set test(Test test) => _test = test;
  /// If set will provide a blank test for the [Testable]
  bool includesTest = false;

  // custom <class Testable>

  Test get test => _test == null ? (_test = new Test(this)) : _test;

  /// Provides access to this [Testable]'s test as function for
  /// declarative manipulation:
  ///
  ///     header('h')
  ///     ..doc
  ///     ..withTest((Test test) {
  ///        test
  ///        ..includes.addAll([...])
  ///        ...
  ///     });
  withTest(void t(Test t)) => t(test);

  get _dottedId {
    final me = this as Entity;
    /// Note if it is not a lib, it will already be in a lib folder so exclude
    final isLib = this is Lib;
    if (isLib) {
      return me.entityPathIds.map((e) => e.snake).join('.');
    } else {
      return me.entityPathIds.skip(1).map((e) => e.snake).join('.');
    }
  }

  _libTestFile(Lib lib) => path.join(
      lib.installation.cppPath, 'tests', lib.id.snake, 'lib.${_dottedId}.cpp');

  _classTestFile(Class class_) => path.join(class_.installation.cppPath,
      'tests', _ownerBasedPathPart(class_, 'class.${_dottedId}.cpp'));

  _headerTestFile(Header header_) => path.join(header_.installation.cppPath,
      'tests', _ownerBasedPathPart(header_, 'header.${_dottedId}.cpp'));

  _implTestFile(Impl impl_) =>
      path.join('tests', _ownerBasedPathPart(impl_, 'impl.${_dottedId}.cpp'));

  _ownerBasedPathPart(entity, cppFileName) {
    final owningLib = entity.owningLib;
    if (owningLib != null) {
      return path.join(owningLib.id.snake, cppFileName);
    } else {
      throw 'TestScenarios must be owned by a *Lib* but'
          '${entity.entityPathIds} $cppFileName is ${entity.runtimeType}';
    }
  }

  String get testFileName => this is Lib
      ? _libTestFile(this)
      : this is Class
          ? _classTestFile(this)
          : this is Header
              ? _headerTestFile(this)
              : this is Impl ? _implTestFile(this) : '??${runtimeType}';

  toString() => '''
Catch Test: ${runtimeType}:${id}:${br(testScenarios)}
''';

  // end <class Testable>

  Test _test;
}

abstract class TestProvider {

  // custom <class TestProvider>

  generateTests(Iterable<Testable> testables);

  // end <class TestProvider>

}

class BoostTestProvider extends TestProvider {

  // custom <class BoostTestProvider>

  generateTests(Installation installation) {
    _logger.info('generating boost tests for ${installation.name}');
    installation.libs.forEach((Lib lib) {

      //lib.generateTests();

      lib.headers.where((header) => header.hasTest).forEach((Header header) {
        _logger.info('Header with test ${header.id.snake}');

        header.test
          ..namespace = header.namespace
          ..setFilePathFromRoot(path.join(installation.cppPath, 'tests'))
          ..generate();

        final test = header.test;
        final directory = path.dirname(test.filePath);
        lib.tests.add(test);
      });
    });
  }

  // end <class BoostTestProvider>

}

class CatchTestProvider extends TestProvider {

  /// The [Impl]s generated to support the tests that need to be
  /// included in the build scripts.
  List generatedTestImpls = [];

  // custom <class CatchTestProvider>

  generateTests(Installation installation) {
    final testables = installation.testables;
    if (testables.isNotEmpty) {
      final installation = testables.first.installation;
      testables.forEach((Testable testable) {
        _logger.info('Found testable in '
            '${(testable as Entity).owningLib.id.snake}');

        if (testable.testImpl == null) {
          testable.testImpl = impl('test');
        }

        final testImpl = testable.testImpl;

        _logger.info(
            '${installation.id} processing test ${testable.runtimeType}'
            ':${testable.entityPathIds.map((id) => id.snake)}');

        final contents = new StringBuffer();

        testable.testScenarios.forEach((TestScenario ts) {
          _logger.info(_scenarioTestText(testable, ts));

          final theLib = testable.owningLib;
          _logger.fine('The testable is ${testable.id} '
              '=> ${testable.runtimeType} ${theLib}');

          final entry = (testImpl
            ..includes = ['catch.hpp']
            ..namespace = testable.owningLib.namespace
            ..getCodeBlock(fcbBeginNamespace).snippets
                .add(_scenarioTestText(testable, ts))).contents;

          contents.writeln(entry);
        });

        generatedTestImpls.add(testImpl
          ..setLibFilePath(testable.testFileName)
          ..generate());
      });
    }
  }

  _thenTestText(Then then) {
    return '''
THEN("${then.id.snake}") {
${brCompact([ then.startBlockText, then.endBlockText ])}
}''';
  }

  _whenTestText(When when) {
    return '''
WHEN("${when.id.sentence}") {
${
brCompact([
  when.startBlockText,
  indentBlock(chomp(brCompact(when.thens.map((t) => _thenTestText(t))))),
  when.endBlockText ])
}}''';
  }

  _givenTestText(Given given) {
    return '''
GIVEN("${given.id.sentence}") {
${
brCompact([
  given.startBlockText,
  indentBlock(chomp(brCompact(given.whens.map((w) => _whenTestText(w))))),
  given.endBlockText ])
}
}''';
  }

  _scenarioTestText(Testable testable, TestScenario ts) {
    return '''
SCENARIO("${ts.id.sentence}") {
${indentBlock(chomp(brCompact(ts.givens.map((g) => _givenTestText(g)))))}
}''';
  }

  // end <class CatchTestProvider>

}

// custom <part test_provider>

/// Create a Then sans new, for more declarative construction
Then then([String clause, bool isAnd = false]) =>
    new Then(idFromWords(clause), isAnd);

/// Create a Then sans new, for more declarative construction
Then andThen([String clause]) => new Then(idFromWords(clause), true);

/// Create a When sans new, for more declarative construction
When when([String clause, thens]) => new When(
    idFromWords(clause), thens == null ? [] : thens is Then ? [thens] : thens);

/// Create a Given sans new, for more declarative construction
Given given([String clause, whens]) => new Given(
    idFromWords(clause), whens == null ? [] : whens is When ? [whens] : whens);
/// Create a TestScenario sans new, for more declarative construction
TestScenario testScenario(id, [givens]) => new TestScenario(
    idFromWords(id), givens == null ? [] : givens is Given ? [givens] : givens);

// end <part test_provider>
