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
class Member extends CppEntity {
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
  set access(Access access) => _access = access;

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

  /// A function that may be used to modify the value returned from a
  /// getter.  If a modifier function of type [GetReturnModifier] is
  /// provided it will be used to update what the accessor returns.
  ///
  /// For example:
  ///
  ///     print(clangFormat(
  ///             (member('message_length')
  ///                 ..type = 'int32_t'
  ///                 ..access = ro
  ///                 ..getterReturnModifier =
  ///                   ((member, oldValue) => 'endian_convert($oldValue)'))
  ///             .getter));
  ///
  /// prints:
  ///
  ///     //! getter for message_length_ (access is Ro)
  ///     int32_t message_length() const { return endian_convert(message_length_); }
  ///
  /// Notes: No required *parens* when used inline with cascades. A trailing
  /// semicolon is *not* required and the modifier accessor must return the
  /// same type as the member.
  GetterReturnModifier getterReturnModifier;

  /// A single customBlock that will be injected in the public section
  /// of the owning class. For example, if generating code that needs
  /// special getters/setters (e.g. atypical coding pattern) then the
  /// member could be set with *access = ro* and custom accessors may
  /// be provided.
  CodeBlock customBlock = new CodeBlock(null);

  /// Will create the getter. To provide custom getter implement
  /// GetterCreator and assign
  GetterCreator getterCreator;

  /// Will create the setter. To provide custom setter implement
  /// SetterCreator and assign
  SetterCreator setterCreator;

  /// Indicates member should be streamed if class is streamable.
  /// One of the few flags defaulted to *true*, this flag provides
  /// an opportunity to *not* stream specific members
  bool isStreamable = true;

  /// If not-null a custom streamable block. Use this to either hand code or
  /// generate a streamable entry in the containing [Class].
  CodeBlock get customStreamable => _customStreamable;

  // custom <class Member>

  Member(id) : super(id);

  Class get ownerClass => owner as Class;

  /// Member has no children - returns empty [Iterable]
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  /// Returns true if member has customized out streaming
  get hasCustomStreamable => _customStreamable != null;

  /// Returns true if member has customized getter
  ///
  /// The purpose here is to ensure that if some modification is done on the
  /// member for a general access (e.g. a network byte swap), that same
  /// modification is done when streaming out.
  ///
  /// Note: If getter is customized by setting [Member] to *ro* or *ia* and
  /// providing a hand written getter, this will not help and you should provide
  /// custom streaming support
  get hasCustomGetter => getterReturnModifier != null;

  get _ownerDefaultAccess =>
      owner == null ? null : ownerClass.defaultMemberAccess;

  get _ownerCppAccess => owner == null ? null : ownerClass.defaultCppAccess;

  get access => _access == null
      ? (_ownerDefaultAccess != null ? _ownerDefaultAccess : ia)
      : _access;

  getCustomStreamable() {
    _customStreamable != null
        ? _customStreamable
        : (_customStreamable = codeBlock('${id}::out'));
    return _customStreamable;
  }

  withCustomStreamable(void f(CodeBlock)) => f(getCustomStreamable());

  withCustomBlock(void f(Member, CodeBlock)) => f(this, customBlock);

  String toString() {
    if (isStatic &&
        isMutable) throw "Member $id may not be both static and mutable";
    return brCompact(_parts);
  }

  get isByRef =>
      _isByRef == null ? (type == 'std::string' ? true : false) : _isByRef;

  set initText(String txt) => _init = txt;
  get isRefType => refType != null && refType != value;

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
      type = inferCppType(init_);
    }
    _init = init_.toString();

    if (type == 'std::string') {
      _init = smartDoubleQuote(_init);
    }
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

  String get getter {
    if (getterCreator == null) {
      getterCreator = new StandardGetterCreator(this);
    }
    return getterCreator.getter;
  }

  String get setter {
    if (setterCreator == null) {
      setterCreator = new StandardSetterCreator(this);
    }
    return setterCreator.setter;
  }

  CppAccess get cppAccess => _cppAccess != null
      ? _cppAccess
      : _ownerCppAccess != null
          ? _ownerCppAccess
          : access != null ? private : public;

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
  Access _access;
  CppAccess _cppAccess;
  bool _isByRef;
  bool _isConst = false;
  CodeBlock _customStreamable;
}

/// Responsible for creating the getter (i.e. reader) for member
abstract class GetterCreator {
  GetterCreator(this.member);

  /// Member this creator will create getter for
  Member member;

  // custom <class GetterCreator>

  // Returns the text of the getter method
  String get getter;

  // end <class GetterCreator>

}

class StandardGetterCreator extends GetterCreator {
  // custom <class StandardGetterCreator>

  StandardGetterCreator(Member member) : super(member);

  get member => super.member;
  get name => member.name;
  get vname => member.vname;
  get getterReturnModifier => member.getterReturnModifier;
  get _constAccess => member._constAccess;
  get access => member.access;

  String get _getterOpener => '''
//! getter for ${vname} (access is ${evCap(access)})
$_constAccess $name() const {''';
  get _getterReturnValue =>
      getterReturnModifier != null ? getterReturnModifier(this, vname) : vname;
  get _getterImpl => 'return $_getterReturnValue;';
  get _getterCloser => '}';

  String get getter => access == ro || access == rw
      ? brCompact([_getterOpener, _getterImpl, _getterCloser])
      : null;

  // end <class StandardGetterCreator>

}

/// Responsible for creating the setter (i.e. writer) for member
abstract class SetterCreator {
  SetterCreator(this.member);

  /// Member this creator will create setter for
  Member member;

  // custom <class SetterCreator>

  // Returns the text of the setter method
  String get setter;

  // end <class SetterCreator>

}

class StandardSetterCreator extends SetterCreator {
  // custom <class StandardSetterCreator>

  StandardSetterCreator(Member member) : super(member);

  get member => super.member;
  get name => member.name;
  get vname => member.vname;
  get access => member.access;
  get argType => member._argType;

  String get _setterOpener => '''
//! setter for ${vname} (access is $access)
void $name($argType $name) {''';
  String get _setterImpl => '$vname = $name;';
  String get _setterCloser => '}';

  String get _setterByAccess => member._isByRef
      ? '''
//! updater for ${vname} (access is $access)
$argType $name() {
  return $vname;
}
'''
      : null;

  String get setter => (access == rw || access == wo)
      ? br([
          brCompact([_setterOpener, _setterImpl, _setterCloser]),
          _setterByAccess,
        ])
      : null;

  // end <class StandardSetterCreator>

}

// custom <part member>

Member member(id) => new Member(id);

typedef String GetterReturnModifier(Member member, String oldValue);

// end <part member>
