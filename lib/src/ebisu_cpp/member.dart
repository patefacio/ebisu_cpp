part of ebisu_cpp.ebisu_cpp;

/// A member or field included in a class.
///
/// ## Basics
///
/// Members are typed (i.e. have [type]) and optionally initialized.
///
/// For example:
///
///     member('widget')..type = 'Widget'..init = 'Widget()'
///
/// gives:
///
///     Widget widget_ { Widget() };
///
/// For some C++ types (*double*, *int*, *std::string*, *bool*) the type
/// can be inferred if a suitable [init] is provided:
///
/// Examples:
///
///     member('number')..init = 4
///     member('pi')..init = 3.14
///     member('default_tag')..init = 'empty'
///     member('is_strong')..init = false
///
/// give respectively:
///
///     int number_ { 4 };
///     double pi_ { 3.14 };
///     std::string default_tag_ { "empty" };
///     bool is_strong_ { false };
///
/// ## Encapsulation
///
/// Encapsulation can be achieved by setting [access] and/or
/// [cppAccess]. Setting [access] is the preferred approach since it
/// provides a consistent, sensible pattern for hiding and accessing
/// members (See [Access]).
///
/// *Read-Only* Example:
///
///     (class_('c')
///         ..members = [
///           member('readable')..init = 'foo'..access = ro
///         ])
///     .definition
///
/// Gives:
///
///     class C
///     {
///     public:
///       //! getter for readable_ (access is Ro)
///       std::string const& readable() const { return readable_; }
///     private:
///       std::string readable_ { "foo" };
///     };
///
///
/// *Inaccessible* Example:
///
///     (class_('c')
///         ..members = [
///           member('inaccessible')..init = 'foo'..access = ia
///         ])
///     .definition
///
/// Gives:
///
///     class C
///     {
///     private:
///       std::string inaccessible_ { "foo" };
///     };
///
/// *Read-Write* Example:
///
///     (class_('c')
///       ..members = [
///         member('read_write')..init = 'foo'..access = rw
///       ])
///     .definition
///
/// Gives:
///
///     class C
///     {
///     public:
///       //! getter for read_write_ (access is Rw)
///       std::string const& read_write() const { return read_write_; }
///       //! setter for read_write_ (access is Access.rw)
///       void read_write(std::string & read_write) { read_write_ = read_write; }
///     private:
///       std::string read_write_ { "foo" };
///     };
///
///
/// Note that read-write keeps the member *private* by default and allows
/// access through methods. However, complete control over C++ access of
/// members can be obtained with [cppAccess]. Here are two such examples:
///
/// No accessors, just C++ public:
///
///     (class_('c')
///       ..members = [
///         member('full_control')..init = 'foo'..cppAccess = public
///       ])
///     .definition
///
/// Gives:
///
///     class C
///     {
///     public:
///       std::string full_control { "foo" };
///     };
///
/// Finally, using both [access] and [cppAccess] for more control:
///
///     (class_('c')
///       ..members = [
///         member('more_control')..init = 'foo'..access = ro..cppAccess = protected
///       ])
///     .definition
///
///
/// Gives:
///
///     class C
///     {
///     public:
///       //! getter for more_control_ (access is Ro)
///       std::string const& more_control() const { return more_control_; }
///     protected:
///       std::string more_control_ { "foo" };
///     };
///
///
///
///
class Member extends Entity {
  /// Type of member
  String type;
  /// Initialization of member.
  ///
  /// If [type] of [Member] is null and [init] is set with a Dart type
  /// which can reasonably map to a C++ type, then type is inferred.
  /// Currently the mappings are:
  ///     {
  ///       int : int,
  ///       double : double,
  ///       string : std::string,
  ///       bool : bool,
  ///       List(...) : std::vector<...>,
  ///     }
  ///
  /// For example:
  ///
  ///     member('name')..init = 'UNASSIGNED' => name is std::string
  ///     member('x')..init = 0               => x is int
  ///     member('pi')..init = 3.14           => pi is double
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
  set isByRef(bool isByRef) => _isByRef = isByRef;
  /// Is the member static
  bool isStatic = false;
  /// Is the member mutable
  bool isMutable = false;
  /// Is the member const
  set isConst(bool isConst) => _isConst = isConst;
  /// Is the member a constexprt
  bool isConstExpr = false;
  /// If set will not initialize variable - use sparingly
  bool hasNoInit = false;
  /// Indicates this member is an enum and if serialized should be serialized as int
  bool isSerializedAsInt = false;
  /// Indicates this member should not be serialized via cereal
  bool isCerealTransient = false;
  /// Indicates member should be streamed if class is streamable.
  /// One of the few flags defaulted to *true*, this flag provides
  /// an opportunity to *not* stream specific members
  bool isStreamable = true;
  /// Indicates a custom protect block is needed to hand code
  /// the streamable for this member
  bool hasCustomStreamable = false;
  // custom <class Member>

  Member(Id id) : super(id);

  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  String toString() {
    if (isStatic &&
        isMutable) throw "Member $id may not be both static and mutable";

    return combine(_parts);
  }

  get isByRef =>
      _isByRef == null ? (type == 'std::string' ? true : false) : _isByRef;

  set initText(String txt) => _init = txt;
  get isRefType => refType != value;

  get passType => refType == value
      ? (isByRef ? '$type const &' : type)
      : refType == ref
          ? '$type &'
          : refType == cref
              ? '$type const &'
              : refType == vref
                  ? '$type volatile &'
                  : refType == cvref
                      ? '$type const volatile &'
                      : throw '$id has invalid refType $refType';

  get passDecl => '$passType $name';

  set init(Object init_) {
    if (isRefType) throw '$id can not have an init since it is a reference type ($refType)';

    if (type == null) {
      type = inferType(init_);
    }
    _init = init_.toString();
  }

  static inferType(Object datum) {
    var inferredType = 'int';
    if (datum is double) {
      inferredType = 'double';
    } else if (datum is String) {
      inferredType = 'std::string';
      datum = quote(datum);
    } else if (datum is bool) {
      inferredType = 'bool';
    } else if (datum is List) {
      List list = datum;
      if (list.isEmpty) throw 'Can not infer type from emtpy list';
      final first = datum.first;
      final guess = inferType(first);
      if (list.sublist(1).every((i) => guess == inferType(first))) {
        inferredType = 'std::vector< $guess >';
      } else {
        throw 'Can not infer type from list with mixed types: $datum';
      }
    }
    return inferredType;
  }

  //  String get _initValue => init is! String? init.toString() : init;
  String get initializer =>
      hasNoInit || isRefType ? '' : init == null ? ' {}' : ' { $init }';

  bool get isConst => _isConst || isConstExpr;
  bool get isStaticConst => isConst && isStatic;
  bool get isPublic => cppAccess == public;
  bool get isPublicStaticConst => isConst && isStatic && isPublic;
  set isStaticConst(bool v) => isConst = isStatic = v;

  String get name =>
      isStaticConst ? namer.nameStaticConst(id) : namer.nameMember(id);
  String get vname => isStaticConst ? name : namer.nameMemberVar(id, isPublic);
  String get getter => access == ro || access == rw
      ? '''
//! getter for ${vname} (access is ${evCap(access)})
$_constAccess $name() const { return $vname; }'''
      : null;

  String get setter => (access == rw || access == wo)
      ? '''
//! setter for ${vname} (access is $access)
void $name($_argType $name) { $vname = $name; }'''
      : null;

  CppAccess get cppAccess =>
      _cppAccess != null ? _cppAccess : (access != null) ? private : public;

  get _argType => isByRef ? '$type &' : type;
  get _constAccess => isByRef ? '$type const&' : type;
  get _parts => [briefComment, detailedComment, _decl];

  get _refType {
    switch (refType) {
      case value:
        return type;
      case ref:
        return '$type &';
      case cref:
        return '$type const&';
      case vref:
        return '$type volatile&';
      case cvref:
        return '$type const volatile&';
    }
  }

  get _static => isStatic ? 'static ' : '';
  get _mutable => isMutable ? 'mutable ' : '';
  get _constDecl => _isConst ? 'const ' : '';
  get _decl => isConstExpr
      ? '${_static}constexpr $_mutable$_refType $vname$initializer;'
      : '$_static$_mutable$_refType $_constDecl$vname$initializer;';

  // end <class Member>
  String _init;
  CppAccess _cppAccess;
  bool _isByRef;
  bool _isConst = false;
}
// custom <part member>

Member member(Object id) => new Member(id is Id ? id : new Id(id));

// end <part member>
