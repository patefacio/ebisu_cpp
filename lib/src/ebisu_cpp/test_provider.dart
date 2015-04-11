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
class TestClause {
  Id clause;
  CodeBlock startCodeBlock;
  CodeBlock endCodeBlock;

  // custom <class TestClause>

  TestClause(testClause) : clause = idFromString(testClause);

  // end <class TestClause>

}

class Then extends TestClause {
  bool isAnd = false;

  // custom <class Then>

  Then(String thenClause, [this.isAnd]) : super(thenClause);

  // end <class Then>

}

class When extends TestClause {
  List<Then> thens = [];

  // custom <class When>

  When(String whenClause, [this.thens]) : super(whenClause);

  // end <class When>

}

class Given extends TestClause {
  List<When> whens = [];

  // custom <class Given>

  Given(String givenClause, [this.whens]) : super(givenClause);

  toString() => '''
Given(${clause.snake})
${indentBlock(br(whens))}
''';

  // end <class Given>

}

class Scenario {
  Id id;
  List<Given> givens = [];

  // custom <class Scenario>
  Scenario(this.id, [this.givens]);

  toString() => '''
Scenario(${id.snake})
${indentBlock(br(givens))}
''';

  // end <class Scenario>

}

class Testable {
  List<Scenario> scenarios = [];

  // custom <class Testable>
  // end <class Testable>

}

abstract class TestProvider {

  // custom <class TestProvider>
  // end <class TestProvider>

}

class BoostTestProvider extends TestProvider {

  // custom <class BoostTestProvider>
  // end <class BoostTestProvider>

}

class CatchTestProvider extends TestProvider {

  // custom <class CatchTestProvider>
  // end <class CatchTestProvider>

}

// custom <part test_provider>

/// Create a Then sans new, for more declarative construction
Then then([String clause, bool isAnd]) => new Then(clause, isAnd);
/// Create a When sans new, for more declarative construction
When when([String clause, List<Then> thens]) => new When(clause, thens);
/// Create a Given sans new, for more declarative construction
Given given([String clause, List<When> when]) => new Given(clause, when);
/// Create a Scenario sans new, for more declarative construction
Scenario scenario(id, [List<Given> givens]) =>
    new Scenario(id is String ? idFromString(id) : id, givens);

// end <part test_provider>
