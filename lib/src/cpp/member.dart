part of ebisu_cpp.cpp;

/// A member or field included in a class
class Member extends Entity {
  /// Type of member
  String type;
  /// Initialization of member (if type is null and Dart type is key in { int:int, double:double }, cpp type is set to value type)
  String get init => _init;
  /// Rare usage - member b depends on member a (e.g. b is just a string rep of a
  /// which is int), a is passed in for construction but b can be initialized directly
  /// from a. If ctorInit is set on a member, any memberCtor will include this text to
  /// initialize it
  String ctorInit;
  /// Idiomatic access of member
  Access access = ia;
  /// C++ style access of member
  set cppAccess(CppAccess cppAccess) => _cppAccess = cppAccess;
  /// Ref type of member
  RefType refType = value;
  /// Pass member around by reference
  set byRef(bool byRef) => _byRef = byRef;
  /// Is the member static
  bool static = false;
  /// Is the member mutable
  bool mutable = false;
  /// Is the member const
  set isConst(bool isConst) => _isConst = isConst;
  /// Is the member a constexprt
  bool isConstExpr = false;
  /// If set will not initialize variable - use sparingly
  bool noInit = false;
  /// Indicates this member is an enum and if serialized should be serialized as int
  bool serializeInt = false;
  /// Indicates this member should not be serialized via cereal
  bool cerealTransient = false;
  // custom <class Member>

  Member(Id id) : super(id);

  String toString() {
    if(static && mutable)
      throw "Member $id may not be both static and mutable";

    return combine(_parts);
  }

  get byRef =>
    _byRef == null?
    (type == 'std::string'? true : false) : _byRef;

  set initText(String txt) => _init = txt;
  get isRefType => refType != value;

  get passType =>
    refType == value? (byRef? '$type const &' : type) :
    refType == ref? '$type &' :
    refType == cref? '$type const &' :
    refType == vref? '$type volatile &' :
    refType == cvref? '$type const volatile &' :
    throw '$id has invalid refType $refType';

  get passDecl => '$passType $name';

  set init(Object init_) {
    if(isRefType)
      throw '$id can not have an init since it is a reference type ($refType)';

    if(type == null) {
      if(init_ is double) {
        type = 'double';
      } else if(init_ is String) {
        type = 'std::string';
        init_ = quote(init_);
      } else if(init_ is bool) {
        type = 'bool';
      } else {
        type = 'int';
      }
    }
    _init = init_.toString();
  }

  //  String get _initValue => init is! String? init.toString() : init;
  String get initializer =>
    noInit || isRefType ? '' :
    init==null? ' {}' :
    ' { $init }';

  set isStatic(bool v) => static = v;
  bool get isConst => _isConst || isConstExpr;
  bool get isStatic => static;
  bool get isStaticConst => isConst && isStatic;
  bool get isPublic => cppAccess == public;
  bool get isPublicStaticConst => isConst && isStatic && isPublic;
  set isStaticConst(bool v) => isConst = isStatic = v;

  String get name => isStaticConst? id.shout : id.snake;
  String get vname => (isStaticConst || isPublic)? name : '${name}_';
  String get getter =>
    access == ro || access == rw ? '''
//! getter for ${vname} (access is ${evCap(access)})
$_constAccess $name() const { return $vname; }''' :
    null;

  String get setter => access == rw? '''
//! setter for ${vname} (access is $access)
void $name($_argType $name) { $vname = $name; }''' : null;

  CppAccess get cppAccess =>
    _cppAccess != null? _cppAccess :
    (access == ia || access == ro || access == rw) ? private :
    public;

  get _argType => byRef? '$type &' : type;
  get _constAccess => byRef? '$type const&' : type;

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
  get _constDecl => _isConst? 'const ' : '';
  get _decl =>
    isConstExpr? '${_static}constexpr $_mutable$_refType $vname$initializer;' :
    '$_static$_mutable$_refType $_constDecl$vname$initializer;';

  // end <class Member>
  String _init;
  CppAccess _cppAccess;
  bool _byRef;
  bool _isConst = false;
}
// custom <part member>

Member
  member(Object id) =>
  new Member(id is Id? id : new Id(id));


// end <part member>
