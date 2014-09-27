part of ebisu_cpp.cpp;

class Member extends Entity {

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

  // custom <class Member>

  Member(Id id) : super(id);

  String toString() {
    if(static && mutable)
      throw "Member $id may not be both static and mutable";

    return combine(_parts);
  }

  String get initializer => init==null? '{}' : '{ $init }';
  String get name => '${id.snake}_';

  CppAccess get cppAccess =>
    (access == ia || access == ro) ? private :
    public;

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
  get _decl => '$_static$_mutable$_refType $name $_init;';
  // end <class Member>
}
// custom <part member>

Member
  member(Object id) =>
  new Member(id is Id? id : new Id(id));


// end <part member>
