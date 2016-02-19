part of ebisu_cpp.ebisu_cpp;

abstract class Using {
  // custom <class Using>

  get usingStatement;

  // end <class Using>

}

/// Object corresponding to a using statement
class UsingDirective extends CppEntity implements Using {
  /// The right hand side of using (ie the type decl being named)
  String get rhs => _rhs;

  /// Template associated with the using (C++11)
  Template get template => _template;

  // custom <class UsingDirective>

  UsingDirective(lhs_, this._rhs) : super(addSuffixToId('t', lhs_));

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

  // end <class UsingDirective>

  String _rhs;
  Template _template;
}

/// Object corresponding to a using statement
class UsingDeclaration extends CppEntity implements Using {
  String get qualifiedName => _qualifiedName;

  // custom <class UsingDeclaration>

  UsingDeclaration(qualifiedName)
      : super(qualifiedName.replaceAll('::', '_')),
        _qualifiedName = qualifiedName;

  Iterable<Entity> get children => [];

  toString() => usingStatement;

  //// The using statement with documentation
  get usingStatement => brCompact([this.docComment, 'using $qualifiedName;']);

  // end <class UsingDeclaration>

  String _qualifiedName;
}

// custom <part using>

final _usingSpecRe = new RegExp(r"(\w+)\s*=\s*((?:.|\n)*)", multiLine: true);

/// Returns a [UsingDirective] from [u], which may be a String or [Id]
///
/// If [decl] is provided, it is parsed and the [Using] is constructed from that:
///
///     usingDirective('using int = int') => 'using Int_t = int;'
///
///     usingDirective('vec_int', 'std::vector< int >') => 'using Vec_int_t = std::vector< int >;'
///
///     usingDirective('vec_int', 'std::vector< T >')
///     ..template = [ 'typename T' ]) => 'template <typename T > using Vec_int_t = std::vector< T >;'
///
UsingDirective usingDirective(u, [decl]) {
  if (u is Using) {
    return u;
  } else if (u is String || u is Id) {
    if (decl == null) {
      final match = _usingSpecRe.firstMatch(u);
      return new UsingDirective(match.group(1), match.group(2));
    } else {
      return new UsingDirective(u, decl);
    }
  } else {
    throw 'using($u) requires string like r"\w+\s*=\s(.*)" or Using';
  }
}

/// Returns a [UsingDeclaration] from [qualifiedName]
///
///  using('std::string') => 'using std::string'
///
UsingDeclaration usingDeclaration(qualifiedName) =>
    new UsingDeclaration(qualifiedName);

final _qualifiedNameRe = new RegExp(r'^\w+(?:::\w+)+$');

/// Returns either a [UsingDeclaration] or a [UsingDirective] based on [u] and
/// [decl]. If only [u] is provided then if it looks like a qualifiedName it
/// returns a [UsingDeclaration]. Otherwise returns a [UsingDirective].
/// see [usingDirective].
///
Using using(u, [decl]) {
  if (u is Using || decl != null || !_qualifiedNameRe.hasMatch(u)) {
    return usingDirective(u, decl);
  }
  return usingDeclaration(u);
}

// end <part using>
