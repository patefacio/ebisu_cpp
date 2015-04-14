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
  CodeBlock startCodeBlock;
  CodeBlock endCodeBlock;

  // custom <class TestClause>

  TestClause(testClause) : super(makeId(testClause));
  get clause => id;

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
  // end <class BoostTestProvider>

}

class CatchTestProvider extends TestProvider {

  // custom <class CatchTestProvider>

  generateTests(Iterable<Testable> testables) {
    if (testables.isNotEmpty) {
      final installation = testables.first.installation;
      print(
          'For installation ${installation.id} Generating tests for ${br(testables)}');
    }
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
