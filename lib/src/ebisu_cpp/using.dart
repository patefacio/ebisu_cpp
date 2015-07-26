part of ebisu_cpp.ebisu_cpp;

/// Object corresponding to a using statement
class Using extends CppEntity {
  /// The right hand side of using (ie the type decl being named)
  String get rhs => _rhs;

  // custom <class Using>

  Using(lhs_, String this._rhs) : super(addSuffixToId('t', lhs_));

  Iterable<Entity> get children => [];

  toString() => 'using $type = $rhs;';

  get lhs => id;

  get type => namer.nameUsingType(id);

  usingStatement(Namer namer) =>
      brCompact([this.docComment, 'using $type = $rhs;']);

  // end <class Using>

  String _rhs;
}

// custom <part using>

final _usingSpecRe = new RegExp(r"(\w+)\s*=\s*((?:.|\n)*)", multiLine: true);

Using using([u, decl]) {
  if (u is Using) {
    return u;
  } else if (u is String || u is Id) {
    if (decl == null) {
      final match = _usingSpecRe.firstMatch(u);
      return new Using(match.group(1), match.group(2));
    } else {
      return new Using(u, decl);
    }
  } else {
    throw 'using($u) requires string like r"\w+\s*=\s(.*)" or Using';
  }
}

// end <part using>
