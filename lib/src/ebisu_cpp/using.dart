part of ebisu_cpp.ebisu_cpp;

/// Object corresponding to a using statement
class Using extends CppEntity {
  /// The right hand side of using (ie the type decl being named)
  String get rhs => _rhs;

  /// Template associated with the using (C++11)
  Template get template => _template;

  // custom <class Using>

  Using(lhs_, String this._rhs) : super(addSuffixToId('t', lhs_));

  Iterable<Entity> get children => [];

  toString() => usingStatement;

  /// Returns the _left hand side_, ie the Id of the using.
  get lhs => id;

  /// Returns the type associated with the using statement.
  ///
  /// The type text makes use of the [Namer]
  get type => namer.nameUsingType(id);

  /// Set the [template] associated with the using statement.
  ///
  /// Use this to templatized using statements
  set template(Object t) => _template = _makeTemplate(id, t);

  //// The using statement with documentation
  get usingStatement => brCompact([this.docComment, _templateUsing]);

  get _templateUsing => _template != null
      ? '${template.decl} using $type = $rhs;'
      : 'using $type = $rhs;';


  // end <class Using>

  String _rhs;
  Template _template;
}

// custom <part using>

final _usingSpecRe = new RegExp(r"(\w+)\s*=\s*((?:.|\n)*)", multiLine: true);

/// Returns a [Using] from [u], which may be a String or [Id]
///
/// If [decl] is provided, it is parsed and the [Using] is constructed from that:
///
///     using('using int = int') => 'using Int_t = int;'
///
///     using('vec_int', 'std::vector< int >') => 'using Vec_int_t = std::vector< int >;'
///
///     using('vec_int', 'std::vector< T >')
///     ..template = [ 'typename T' ]) => 'template <typename T > using Vec_int_t = std::vector< T >;'
///
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
