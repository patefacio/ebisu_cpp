part of ebisu_cpp.cpp;

class CppMember extends Entity {

  /// Type of member
  String type;
  /// Initialization of member
  String init;
  /// Access of member
  Access access = ro;
  /// Ref type of member
  RefType refType = value;
  /// Is the member static
  bool static = false;
  /// Is the member mutable
  bool mutable = false;

  // custom <class CppMember>

  CppMember(Id id) : super(id);

  String toString() {
    if(static && mutable)
      throw "Member $id may not be both static and mutable";

    return combine(_parts);
  }

  String get initializer => init==null? '{}' : '{ $init }';

  get _parts => [
    briefComment,
    detailedComment,
    _decl,
  ];

  get _descr => descr != null? blockComment(descr) : descr;

  get _refType {
    switch(refType) {
      case value: return type;
      case ref: return '$type &';
      case cref: return '$type const&';
      case vref: return '$type volatile&';
      case cvref: return '$type const volatile&';
    }
  }

  get _static => static? 'static ' : '';
  get _mutable => mutable? 'mutable ' : '';
  get _init => initializer;
  get _decl => '$_static$_mutable$_refType $id $_init;';

  // end <class CppMember>
}
// custom <part member>

CppMember
  member(Object id) =>
  new CppMember(id is Id? id : new Id(id));


// end <part member>
