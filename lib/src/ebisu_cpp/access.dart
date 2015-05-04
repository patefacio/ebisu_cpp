/// Focuses on stylized *access* and standard C++ access
part of ebisu_cpp.ebisu_cpp;

/// Access designation for a class member variable.
///
/// C++ supports *public*, *private* and *protected* designations. This designation
/// is at a higher abstraction in that selecting access determines both the c++
/// protection as well as the set of accessors that are generated. *Member*
/// instances have both *access* and *cppAccess* so full range is available, but
/// general cases should be covered by setting only the *access* variable of a
/// member.
///
/// * IA: *inaccessible* which provides no accessor with c++ access *private*.
///   It is aliased to *ia*.
///
/// * RO: *read-only* which provides a read accessor with c++ access *private*.
///   It is aliased to *ro*.
///
/// * RW: *read-write* which provides read and write accessor with c++ access *private*.
///   It is aliased to *rw*.
///
/// * WO: *write-only* which provides write access and the c++ access is *private*.
///   It is aliased to *wo*. It may sound counterintuitive, but a use case for this
///   might be to accept the generated write accessor but hand code a read accessor
///   requiring special logic.
///
/// Note: If the desire is to have a public member that is public and has no
/// accessors, set *cppAccess* to *public* andd set *access* to null.
///
/// # Examples
///
/// *cppAccess* null with *access* of *ro* gives:
///
///     class C_1
///     {
///     public:
///       //! getter for x_ (access is Ro)
///       std::string const& x() const { return x_; }
///     private:
///       std::string x_ {};
///     };
///
/// *cppAccess* CppAccess.protected with *access* of *ro* gives:
///
///     class C_1
///     {
///     public:
///       //! getter for x_ (access is Ro)
///       std::string const& x() const { return x_; }
///     protected:
///       std::string x_ {};
///     };
///
enum Access {
  /// **Inaccessible**. Designates a member that is *private* by default and no accessors
  ia,
  /// **Read-Only**. Designates a member tht is *private* by default and a read accessor
  ro,
  /// **Read-Write**. Designates a member tht is *private* by default and both read and write accessors
  rw,
  /// **Write-Only**. Designates a member tht is *private* by default and
  /// write accessor only.  Useful if you want the standard write accessor
  /// but a custom reader.
  wo
}
/// Convenient access to Access.ia with *ia* see [Access].
///
/// **Inaccessible**. Designates a member that is *private* by default and no accessors
///
const Access ia = Access.ia;

/// Convenient access to Access.ro with *ro* see [Access].
///
/// **Read-Only**. Designates a member tht is *private* by default and a read accessor
///
const Access ro = Access.ro;

/// Convenient access to Access.rw with *rw* see [Access].
///
/// **Read-Write**. Designates a member tht is *private* by default and both read and write accessors
///
const Access rw = Access.rw;

/// Convenient access to Access.wo with *wo* see [Access].
///
/// **Write-Only**. Designates a member tht is *private* by default and
/// write accessor only.  Useful if you want the standard write accessor
/// but a custom reader.
///
const Access wo = Access.wo;

/// Cpp access designations:
///
///   * public
///   * private
///   * protected
///
/// This designation is used in multiple contexts such as:
///
///   * Overriding the protection of a member
///   * On *Base* instances to indicate the access associated with inheritance
///   * On class methods (ctor, dtor, ...) to designate access
///
enum CppAccess {
  /// C++ public designation
  public,
  /// C++ protected designation
  protected,
  /// C++ private designation
  private
}
/// Convenient access to CppAccess.public with *public* see [CppAccess].
///
/// C++ public designation
///
const CppAccess public = CppAccess.public;

/// Convenient access to CppAccess.protected with *protected* see [CppAccess].
///
/// C++ protected designation
///
const CppAccess protected = CppAccess.protected;

/// Convenient access to CppAccess.private with *private* see [CppAccess].
///
/// C++ private designation
///
const CppAccess private = CppAccess.private;

// custom <part access>

// end <part access>
