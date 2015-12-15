part of ebisu_cpp.ebisu_cpp;

class Traits {
  Map<String, Using> usings = {};
  List<ConstExpr> get constExprs => _constExprs;

  // custom <class Traits>

  set constExprs(Iterable constExprs) =>
      _constExprs = new List.from(constExprs);

  // end <class Traits>

  List<ConstExpr> _constExprs = [];
}

/// Collection of requirements for a [Traits] entry in a [TraitsFamily]
class TraitsRequirements {
  List<Id> get usings => _usings;
  List<Id> get constExprs => _constExprs;

  // custom <class TraitsRequirements>
  // end <class TraitsRequirements>

  List<Id> _usings;
  List<Id> _constExprs;
}

class TraitsFamily extends CppEntity {
  TraitsRequirements traitsRequirements;
  List<Traits> traits;

  // custom <class TraitsFamily>

  TraitsFamily(Id id) : super(id);

  Iterable<Entity> get children => [];

  // end <class TraitsFamily>

}

// custom <part generic>
// end <part generic>
