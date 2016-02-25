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
abstract class TestClause extends CppEntity {
  CodeBlock preCodeBlock = new CodeBlock(null);
  CodeBlock startCodeBlock = new CodeBlock(null);
  CodeBlock endCodeBlock = new CodeBlock(null);
  CodeBlock postCodeBlock = new CodeBlock(null);

  // custom <class TestClause>

  TestClause(testClause) : super(makeId(testClause)) {
    startCodeBlock = new CodeBlock(null);
  }

  get clause => id;

  /// Give the clause codeblock a uniqueId to allow for clauses in different
  /// places in the same file with the same name. The uniqueId is simply a hash
  /// of the *entityPathIds* so its value is unique and random looking but
  /// reproducibly determinnistic by virtue of its plath in the entity tree
  get _uniqueTag => '(${uniqueId})';

  _setUniqueTag() {
    if (!startCodeBlock.hasContent && !endCodeBlock.hasContent)
      startCodeBlock.tag = _uniqueTag;
  }

  get startBlockText {
    _setUniqueTag();
    return startCodeBlock.toString();
  }

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
  List<Then> thens;

  // custom <class Given>

  Given(Id givenClause, this.whens, [this.thens]) : super(givenClause) {
    if (thens == null) thens = [];
  }
  Iterable<Entity> get children => concat([whens, thens]);

  addWhen(clause, [withThens]) => (whens..add(when(clause, withThens))).last;
  withWhen(clause, f(when)) => f((whens..add(when(clause))).last);

  addThen(clause) => (thens..add(then(clause))).last;
  withThen(clause, f(then)) => f((thens..add(then(clause))).last);

  toString() => '''
Given(${clause.snake})
${indentBlock(br(whens))}
${indentBlock(br(thens))}
''';

  // end <class Given>

}

class TestScenario extends TestClause {
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

abstract class Testable {
  List<TestScenario> testScenarios = [];

  /// The single test for this [Testable]
  set test(Test test) => _test = test;

  // custom <class Testable>

  Test get test => _test == null
      ? (_test = new Test(this)..owner = (this as CppEntity))
      : _test;

  // All tests must belong to an entity within a [Lib]
  get owningLib;

  get hasTest => testScenarios.isNotEmpty;

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
      lib.installation.testsPath, lib.id.snake, 'lib.${_dottedId}.cpp');

  _classTestFile(Class class_) => path.join(class_.installation.testsPath,
      _ownerBasedPathPart(class_, 'class.${_dottedId}.cpp'));

  _headerTestFile(Header header_) => path.join(header_.installation.testsPath,
      _ownerBasedPathPart(header_, 'header.${_dottedId}.cpp'));

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
Catch Test: ${runtimeType}:${(this as Entity).id}:${br(testScenarios)}
''';

  // end <class Testable>

  Test _test;
}

abstract class TestProvider {
  // custom <class TestProvider>

  generateTests(Installation installation);

  // end <class TestProvider>

}

class CatchTestProvider extends TestProvider {
  // custom <class CatchTestProvider>

  generateTests(Installation installation) {
    final testables = installation.testables;
    if (testables.isNotEmpty) {
      testables.forEach((Testable testable) {
        final testableEntity = testable as Entity;
        final test = testable.test;
        final testOwner = testableEntity.owner;

        test
          ..namespace = namespace(['test'])
          ..setLibFilePath(testable.testFileName)
          ..withCustomBlock(fcbPreIncludes,
              (cb) => cb.snippets.add('#define CATCH_CONFIG_MAIN'))
          ..includes.add('catch.hpp')
          ..getCodeBlock(fcbCustomIncludes).tag = 'custom includes'
          ..getCodeBlock(fcbBeginNamespace).tag =
              '${testable.id.snake} begin namespace'
          ..namespace =
              testable is Class ? testOwner.namespace : testable.namespace;

        ///////////////////////////////////////////////////////////////////
        // If this test is owned by something in a header, that header
        // will be needed to test.
        ///////////////////////////////////////////////////////////////////
        Header owningHeader = testableEntity is Header
            ? testableEntity
            : testableEntity.ancestry
                .firstWhere((a) => a is Header, orElse: () => null);

        if (owningHeader != null) {
          test._includes.add(owningHeader.includeFilePath);
        }

        testable.testScenarios.forEach((TestScenario testScenario) {
          _logger.info(scenarioTestText(testScenario));

          test
              .getCodeBlock(fcbBeginNamespace)
              .snippets
              .add(scenarioTestText(testScenario));

          test.includes.mergeIncludes(testScenario.includes);
        });

        test.generate();
      });
    }
  }

  // end <class CatchTestProvider>

}

// custom <part test_provider>

thenTestText(Then then) {
  return brCompact([
    then.preCodeBlock,
    'THEN("${then.id.sentence}") {',
    then.startBlockText,
    then.endBlockText,
    '}',
    then.postCodeBlock
  ]);
}

whenTestText(When when) {
  return brCompact([
    when.preCodeBlock,
    'WHEN("${when.id.sentence}") {',
    when.startBlockText,
    indentBlock(chomp(brCompact(when.thens.map((t) => thenTestText(t))))),
    when.endBlockText,
    '}',
    when.postCodeBlock
  ]);
}

givenTestText(Given given) {
  return brCompact([
    given.preCodeBlock,
    'GIVEN("${given.id.sentence}") {',
    given.startBlockText,
    indentBlock(chomp(brCompact(given.whens.map((w) => whenTestText(w))))),
    indentBlock(chomp(brCompact(given.thens.map((t) => thenTestText(t))))),
    given.endBlockText,
    '}',
    given.postCodeBlock
  ]);
}

scenarioTestText(TestScenario ts) {
  return brCompact([
    ts.preCodeBlock,
    'SCENARIO("${ts.id.sentence}") {',
    ts.startBlockText,
    indentBlock(chomp(brCompact(ts.givens.map((g) => givenTestText(g))))),
    ts.endBlockText,
    '}',
    ts.postCodeBlock
  ]);
}

/// Create a Then sans new, for more declarative construction
Then then([String clause, bool isAnd = false]) =>
    new Then(idFromWords(clause), isAnd);

/// Create a Then sans new, for more declarative construction
Then andThen([String clause]) => new Then(idFromWords(clause), true);

/// Create a When sans new, for more declarative construction
When when([String clause, thens]) => new When(
    idFromWords(clause), thens == null ? [] : thens is Then ? [thens] : thens);

/// Create a Given sans new, for more declarative construction
Given given([String clause, whens, thens]) => new Given(
    idFromWords(clause),
    whens == null ? [] : whens is When ? [whens] : whens,
    thens is Then ? [thens] : thens);

/// Create a TestScenario sans new, for more declarative construction
TestScenario testScenario(id, [givens]) => new TestScenario(
    idFromWords(id), givens == null ? [] : givens is Given ? [givens] : givens);

TestScenario taggedTestScenario(id, [givens]) =>
    testScenario(id, givens)..startCodeBlock.tag = id;

// end <part test_provider>
