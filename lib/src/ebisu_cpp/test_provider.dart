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

  TestClause(testClause) : super(makeId(testClause));
  get clause => id;

  get startBlockText =>
      startCodeBlock.hasContent ? startCodeBlock.toString() : '';
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

  // custom <class Testable>

  get _dottedId => (this as Entity).entityPathIds.map((e) => e.snake).join('.');

  _libTestFile(Lib lib) =>
      path.join('tests', lib.id.snake, 'lib.${_dottedId}.cpp');

  _classTestFile(Class class_) =>
      path.join('tests', _ownerBasedPathPart(class_, 'class.${_dottedId}.cpp'));

  _headerTestFile(Header header_) => path.join(
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
    installation.libs.forEach((Lib lib) => lib.generateTests());
  }

  // end <class BoostTestProvider>

}

class CatchTestProvider extends TestProvider {

  // custom <class CatchTestProvider>

  generateTests(Installation installation) {
    final testables = installation.testables;
    if (testables.isNotEmpty) {
      final installation = testables.first.installation;
      testables.forEach((Testable testable) {
        _logger.info(
            '${installation.id} processing test ${testable.runtimeType}'
            ':${testable.entityPathIds.map((id) => id.snake)}');

        testable.testScenarios.forEach((TestScenario ts) {
          _logger.info(_scenarioTestText(testable, ts));
        });
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
WHEN("${when.id.snake}") {
${
brCompact([
  when.startBlockText,
  indentBlock(chomp(brCompact(when.thens.map((t) => _thenTestText(t))))),
  when.endBlockText ])
}}''';
  }

  _givenTestText(Given given) {
    return '''
GIVEN("${given.id.snake}") {
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
// Testable is: ${testable.testFileName}
SCENARIO("${ts.id.snake}") {
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
