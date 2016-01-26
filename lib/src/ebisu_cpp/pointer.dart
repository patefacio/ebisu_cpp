/// Deals with pointers and references
part of ebisu_cpp.ebisu_cpp;

/// Reference type
enum RefType {
  /// Indicates a reference to type: *T &*
  ref,

  /// Indicates a const reference to type: *T const&*
  cref,

  /// Indicates a volatile reference to type: *T volatile&*
  vref,

  /// Indicates a const volatile reference to type: *T const volatile&*
  cvref,

  /// Indicates not a reference
  value
}

/// Convenient access to RefType.ref with *ref* see [RefType].
///
/// Indicates a reference to type: *T &*
///
const RefType ref = RefType.ref;

/// Convenient access to RefType.cref with *cref* see [RefType].
///
/// Indicates a const reference to type: *T const&*
///
const RefType cref = RefType.cref;

/// Convenient access to RefType.vref with *vref* see [RefType].
///
/// Indicates a volatile reference to type: *T volatile&*
///
const RefType vref = RefType.vref;

/// Convenient access to RefType.cvref with *cvref* see [RefType].
///
/// Indicates a const volatile reference to type: *T const volatile&*
///
const RefType cvref = RefType.cvref;

/// Convenient access to RefType.value with *value* see [RefType].
///
/// Indicates not a reference
///
const RefType value = RefType.value;

/// Standard pointer type declaration
enum PtrType {
  /// Indicates a *naked* or *dumb* pointer - T*
  ptr,

  /// Indicates a *naked* or *dumb* pointer - T const *
  cptr,

  /// Indicates *std::shared_ptr< T >*
  sptr,

  /// Indicates *std::unique_ptr< T >*
  uptr,

  /// Indicates *std::shared_ptr< const T >*
  scptr,

  /// Indicates *std::unique_ptr< const T >*
  ucptr
}

/// Convenient access to PtrType.ptr with *ptr* see [PtrType].
///
/// Indicates a *naked* or *dumb* pointer - T*
///
const PtrType ptr = PtrType.ptr;

/// Convenient access to PtrType.cptr with *cptr* see [PtrType].
///
/// Indicates a *naked* or *dumb* pointer - T const *
///
const PtrType cptr = PtrType.cptr;

/// Convenient access to PtrType.sptr with *sptr* see [PtrType].
///
/// Indicates *std::shared_ptr< T >*
///
const PtrType sptr = PtrType.sptr;

/// Convenient access to PtrType.uptr with *uptr* see [PtrType].
///
/// Indicates *std::unique_ptr< T >*
///
const PtrType uptr = PtrType.uptr;

/// Convenient access to PtrType.scptr with *scptr* see [PtrType].
///
/// Indicates *std::shared_ptr< const T >*
///
const PtrType scptr = PtrType.scptr;

/// Convenient access to PtrType.ucptr with *ucptr* see [PtrType].
///
/// Indicates *std::unique_ptr< const T >*
///
const PtrType ucptr = PtrType.ucptr;

// custom <part pointer>

const Map _ptrSuffixMap = const {
  ptr: 'ptr',
  cptr: 'cptr',
  sptr: 'sptr',
  uptr: 'uptr',
  scptr: 'scptr',
  ucptr: 'ucptr',
};

ptrSuffix(PtrType ptrType) => _ptrSuffixMap[ptrType];

Map _ptrStdTypeMap = {
  ptr: (String T) => '$T *',
  cptr: (String T) => '$T const*',
  sptr: (String T) => 'std::shared_ptr< $T >',
  uptr: (String T) => 'std::unique_ptr< $T >',
  scptr: (String T) => 'std::shared_ptr< const $T >',
  ucptr: (String T) => 'std::unique_ptr< const $T >',
};

/// Given [ptrType] and a type specified by [t], returns a corresponding C++
/// type suitable for the rhs of a using statement
ptrType(PtrType ptrType, String t) => _ptrStdTypeMap[ptrType](t);

/// Provide standardized using of dumb pointer to referenced
///
///    print(usingPtr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_ptr_t = SomeType*;
usingPtr(name, referenced) =>
    using(addSuffixToId('ptr', name), '$referenced *');

/// Provide standardized using of dumb pointer to const referenced
///
///    print(usingCptr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_cptr_t = SomeType*;
usingCptr(name, referenced) =>
    using(addSuffixToId('cptr', name), '$referenced const*');

/// Provide standardized using of shared pointer to referenced
///
///    print(usingSptr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_sptr_t = std::shared_ptr<SomeType>;
usingSptr(name, referenced) =>
    using(addSuffixToId('sptr', name), 'std::shared_ptr<$referenced>');

/// Provide standardized using of unique pointer to referenced
///
///    print(usingUptr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_uptr_t = std::unique_ptr<SomeType>;
usingUptr(name, referenced) =>
    using(addSuffixToId('uptr', name), 'std::unique_ptr<$referenced>');

/// Provide standardized using of shared pointer to const referenced
///
///    print(usingScptr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_scptr_t = std::shared_ptr<SomeType const>;
usingScptr(name, referenced) =>
    using(addSuffixToId('scptr', name), 'std::shared_ptr<$referenced const>');

/// Provide standardized using of unique pointer to const referenced
///
///    print(usingUcptr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_ucptr_t = std::unique_ptr<SomeType const>;
usingUcptr(name, referenced) =>
    using(addSuffixToId('ucptr', name), 'std::unique_ptr<$referenced const>');

/// Provide standardized using of pointer to boost thread specific storage
///
///    print(usingTsPtr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_tscptr_t = boost::thread_specific_ptr<SomeType const>;
usingTscptr(name, referenced) => using(addSuffixToId('tscptr', name),
    'boost::thread_specific_ptr<$referenced const>');

/// Provide standardized using of pointer to boost thread specific storage
///
///    print(usingTsPtr('an_id', 'SomeType'));
///
/// Prints:
///
///    using An_id_tsptr_t = boost::thread_specific_ptr<SomeType>;
usingTsptr(name, referenced) => using(
    addSuffixToId('tsptr', name), 'boost::thread_specific_ptr<$referenced>');

// end <part pointer>
