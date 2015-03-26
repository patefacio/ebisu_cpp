/// Library to facilate generation of c++ code.
///
/// The intent is to get as declarative as possible with the specification of C++
/// entities to make code generation as simple and fun as possible. The primary
/// focus of these utilities is in generating the *structure* of c++ code. This is
/// achieved by modeling the C++ language at a relatively high level and selectively
/// choosing what parts of the language lend themselves to the approach.
///
/// For sample code that uses this library to generate its structure see:
/// [fcs project](https://github.com/patefacio/fcs)
///
/// For a small taste, the following is the current description of a small C++
/// library called *raii* which provides a few utilities for handling the *resource
/// acquisition is initialization* idiom.
///
///     import 'package:ebisu_cpp/cpp.dart';
///     import '../../lib/installation.dart';
///
///     final raii = lib('raii')
///       ..namespace = namespace([ 'fcs', 'raii' ])
///       ..headers = [
///         header('change_tracker')
///         ..includes = [ 'boost/call_traits.hpp' ]
///         ..classes = [
///           class_('change_tracker')
///           ..descr = '''
///     Tracks current/previous values of the given type of data. For some
///     algorithms it is useful to be able to examine/perform logic on
///     current value and compare or evalutate how it has changed since
///     previous value.'''
///           ..template = [ 'typename T' ]
///           ..customBlocks = [clsPublic]
///           ..members = [
///             member('current')..type = 'T'..access = ro,
///             member('previous')..type = 'T'..access = ro,
///           ],
///           ...
///         ],
///         header('api_initializer')
///         ..test.customBlocks = [ fcbPreNamespace ]
///         ..test.includes.addAll(['vector', 'fcs/utils/streamers/containers.hpp', ])
///         ..includes = [ 'list', 'map', 'memory' ]
///         ..usings = [
///           'Void_func_t = void (*)(void)',
///         ]
///         ..classes = [
///           class_('functor_scope_exit')
///           ..includesTest = true
///           ..template = [ 'typename FUNCTOR = Void_func_t' ]
///           ..usings = [ 'Functor_t = FUNCTOR' ]
///           ..customBlocks = [ clsPublic ]
///           ..memberCtors = [ memberCtor(['functor']) ]
///           ..members = [
///             member('functor')..type = 'Functor_t'..hasNoInit = true..access = ro,
///           ],
///           ...
///           class_('api_initializer')
///           ..usings = [
///             'Api_initializer_registry_t = Api_initializer_registry< INIT_FUNC, UNINIT_FUNC >'
///           ]
///           ..template = [
///             'typename INIT_FUNC = Void_func_t',
///             'typename UNINIT_FUNC = Void_func_t',
///           ]
///           ..customBlocks = [ clsPublic ]
///         ]
///       ];
///
///     addItems() => installation.addLib(raii);
///
///     main() {
///       addItems();
///       installation.generate();
///     }
///
/// When that script is run, the following is output:
///
///     No change: $TOP/fcs/cpp/fcs/raii/change_tracker.hpp
///     No change: $TOP/fcs/cpp/fcs/raii/api_initializer.hpp
///     No change: $TOP/fcs/cpp/tests/fcs/raii/test_change_tracker.cpp
///     No change: $TOP/fcs/cpp/tests/fcs/raii/test_api_initializer.cpp
///
/// So when the script is run the code is *regenerated* and any changed files will
/// be indicated as such. In this case, since the code was previously generated, it
/// indicates there were no updates.
///
library ebisu_cpp.ebisu_cpp;

import 'dart:collection';
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';
// custom <additional imports>
// end <additional imports>

part 'src/ebisu_cpp/utils.dart';
part 'src/ebisu_cpp/file.dart';
part 'src/ebisu_cpp/enum.dart';
part 'src/ebisu_cpp/member.dart';
part 'src/ebisu_cpp/class.dart';
part 'src/ebisu_cpp/method.dart';
part 'src/ebisu_cpp/serializer.dart';
part 'src/ebisu_cpp/header.dart';
part 'src/ebisu_cpp/impl.dart';
part 'src/ebisu_cpp/lib.dart';
part 'src/ebisu_cpp/app.dart';
part 'src/ebisu_cpp/cmake_support.dart';
part 'src/ebisu_cpp/jam_support.dart';
part 'src/ebisu_cpp/script.dart';
part 'src/ebisu_cpp/test.dart';
part 'src/ebisu_cpp/installation.dart';

final _logger = new Logger('ebisu_cpp');

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
  /// Indicates *std::shared_ptr< T >*
  sptr,
  /// Indicates *std::unique_ptr< T >*
  uptr,
  /// Indicates *std::shared_ptr< const T >*
  scptr,
  /// Indicates *std::unique_ptr< const T >*
  ucptr
}
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

/// Establishes an interface to allow decoration of classes and updates
/// (primarily additions) to an [Installation].
///
abstract class InstallationDecorator {
  // custom <class InstallationDecorator>

  void decorate(Installation);

  // end <class InstallationDecorator>
}

/// Exposes common elements for named entities, including their [id] and
/// documentation. Additionally tracks parentage/ownership of entities.
///
/// This is abstract for purposes of ownership. Each [Entity] knows its
/// owning entity up until [Installation] which is the root entity. A call
/// to [generate] on [Installation] will [setOwnership] which subclasses
/// can trick down establishing ownership.
///
/// The purpose of linking all [Entity] instances in a virtual tree type
/// structure is so lookups can be done for entities.
///
/// [Entity] must be created with an argument representing an Id.  That
/// argument may be a string, in which case it is converted to an [Id].
/// That argument may be an [Id].
///
/// For many/most [Entity] subclasses there is often a corresponding
/// method that simply creates in instance of the subclass. For example,
///
///     class Lib extends Entity... {
///        Lib(Id id) : super(id);
///        ...
///     }
///
///     Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));
///
/// This now allows this approach:
///
///       final myLib = lib('my_awesome_lib')
///         ..headers = [
///           header('my_header')
///           ..classes = [
///             class_('my_class')
///             ..members = [
///               member('my_member')
///             ]
///           ]
///         ];
///
///       print(myLib);
///
/// prints:
///
///     lib(myAwesomeLib)
///       headers:
///         header(myHeader)
///           classes:[My_class]
///
///       tests:
///
abstract class Entity {
  /// Id for the entity
  Id id;
  /// Brief description for the entity
  String brief;
  /// Description of entity
  String descr;
  /// The entity containing this entity (e.g. the [Class] containing the [Member]).
  /// [Installation] is a top level entity and has no owner.
  Entity get owner => _owner;
  /// Path from root to this entity
  List<Entity> get entityPath => _entityPath;
  // custom <class Entity>

  Entity(Object id) : this.id = id is String
          ? idFromString(id)
          : id is Id
              ? id
              : throw '''
Entities must be created with an id of type String or Id''';

  String get briefComment => brief != null ? '//! $brief' : null;

  String get detailedComment => descr != null ? blockComment(descr, ' ') : null;

  String get docComment => br([briefComment, detailedComment]);

  Iterable<Id> get entityPathIds => _entityPath.map((e) => e.id);

  /// *doc* is a synonym for descr
  set doc(String d) {
    print('For $id Doc set to $d');
    descr = d;
  }
  get doc => descr;

  /// Establishes the [Entity] that *this* [Entity] is owned by. This
  /// function should be called only when all declarative information
  /// is available and the [Installation] is ready to be
  /// generated. Entities wanting to perform any actions required
  /// prior to code genreation can hook into this flow by implementing
  /// [_finalizeEntity] which is called after ownership is
  /// established.
  set owner(Entity newOwner) {
    bool isRoot = newOwner == null;
    _owner = newOwner;
    _finalizeEntity();

    if (!isRoot) {
      _entityPath
        ..addAll(newOwner.entityPath)
        ..add(this);
    }

    _logger.info('Set owner $id to ${newOwner == null? "root" : newOwner.id}');

    for (final child in children) {
      child.owner = this;
    }
  }

  set namer(Namer namer) {
    if (_owner != null) {
      throw new Exception('Namer should only be set on root entity');
    }
    _namer = namer;
  }

  /// Returns the [Namer] associated with the entity
  Namer get namer => _namer == null ? defaultNamer : _namer;

  /// All entities must provide iteration on [children] entities
  Iterable<Entity> get children;

  /// This is called after ownership has been established and provides a
  /// mechanism for any work required before code generation but after all
  /// declarations are in.
  /// An example would be the act of doing lookups on
  /// [Interfaces] required by classes. When a class is defined it may
  /// implement one or more [Interfaces]. Rather than require those
  /// interfaces to be named, they may be created elsewhere and
  /// referenced by [Id] in the class. The act of finding the relevant
  /// [Interfaces] prior to generating the class needs to be done at a
  /// time when all declarations are complete but before generation.
  ///
  void _finalizeEntity() {}

  List<Entity> get progeny => children.fold([], (all, child) => all
    ..add(child)
    ..addAll(child.progeny));

  Installation get installation => _owner == null ? this : _owner.installation;

  // end <class Entity>
  Entity _owner;
  List<Entity> _entityPath = [];
  /// Namer to be used when generating names during generation. There is a
  /// default namer, [EbisuCppNamer] that is used if one is not provide. To
  /// create your own naming conventions, provide an implementation of
  /// [Namer] and set an assign that namer to a top-level [Entity], such as
  /// the [Installation]. The assigned namer will be propogated to all
  /// genration utilities.
  Namer _namer;
}

/// Represents a template declaration comprized of a list of [decls]
///
class Template {
  /// List of decls in the template (i.e. the typename entries)
  List<String> decls;
  // custom <class Template>

  Template(Iterable<String> decls_) : decls = new List<String>.from(decls_);

  String get decl => '''
template< ${decls.join(',\n          ')} >''';

  toString() => decl;

  // end <class Template>
}

// custom <library ebisu_cpp>

const Map _ptrSuffixMap = const {
  sptr: 'sptr',
  uptr: 'uptr',
  scptr: 'scptr',
  ucptr: 'ucptr',
};

ptrSuffix(PtrType ptrType) => _ptrSuffixMap[ptrType];

Map _ptrStdTypeMap = {
  sptr: (String T) => 'std::shared_ptr< $T >',
  uptr: (String T) => 'std::unique_ptr< $T >',
  scptr: (String T) => 'std::shared_ptr< const $T >',
  ucptr: (String T) => 'std::unique_ptr< const $T >',
};

ptrType(PtrType ptrType, String t) => _ptrStdTypeMap[ptrType](t);

/// Enclose [s] in double quotes
String quote(String s) => '"$s"';

const _systemHeaders = const [
  'algorithm',
  'array',
  'atomic',
  'bitset',
  'cassert',
  'ccomplex',
  'cctype',
  'cerrno',
  'cfenv',
  'cfloat',
  'chrono',
  'cinttypes',
  'ciso646',
  'climits',
  'clocale',
  'cmath',
  'codecvt',
  'complex',
  'condition_variable',
  'csetjmp',
  'csignal',
  'cstdalign',
  'cstdarg',
  'cstdbool',
  'cstddef',
  'cstdint',
  'cstdio',
  'cstdlib',
  'cstring',
  'ctgmath',
  'ctime',
  'cuchar',
  'cwchar',
  'cwctype',
  'deque',
  'exception',
  'forward_list',
  'fstream',
  'functional',
  'future',
  'initializer_list',
  'iomanip',
  'ios',
  'iosfwd',
  'iostream',
  'istream',
  'iterator',
  'limits',
  'list',
  'locale',
  'map',
  'memory',
  'mutex',
  'new',
  'numeric',
  'ostream',
  'queue',
  'random',
  'ratio',
  'regex',
  'scoped_allocator',
  'set',
  'shared_mutex',
  'sstream',
  'stack',
  'stdexcept',
  'streambuf',
  'string',
  'strstream',
  'system_error',
  'thread',
  'tuple',
  'type_traits',
  'typeindex',
  'typeinfo',
  'unordered_map',
  'unordered_set',
  'utility',
  'valarray',
  'vector',
];

const _posixHeaders = const [
  'aio.h',
  'arpa/inet.h',
  'assert.h',
  'complex.h',
  'cpio.h',
  'ctype.h',
  'dirent.h',
  'dlfcn.h',
  'errno.h',
  'fcntl.h',
  'fenv.h',
  'float.h',
  'fmtmsg.h',
  'fnmatch.h',
  'ftw.h',
  'glob.h',
  'grp.h',
  'iconv.h',
  'inttypes.h',
  'iso646.h',
  'langinfo.h',
  'libgen.h',
  'limits.h',
  'locale.h',
  'math.h',
  'monetary.h',
  'mqueue.h',
  'ndbm.h',
  'net/if.h',
  'netdb.h',
  'netinet/in.h',
  'netinet/tcp.h',
  'nl_types.h',
  'poll.h',
  'pthread.h',
  'pwd.h',
  'regex.h',
  'sched.h',
  'search.h',
  'semaphore.h',
  'setjmp.h',
  'signal.h',
  'spawn.h',
  'stdarg.h',
  'stdbool.h',
  'stddef.h',
  'stdint.h',
  'stdio.h',
  'stdlib.h',
  'string.h',
  'strings.h',
  'stropts.h',
  'sys/ipc.h',
  'sys/mman.h',
  'sys/msg.h',
  'sys/resource.h',
  'sys/select.h',
  'sys/sem.h',
  'sys/shm.h',
  'sys/socket.h',
  'sys/stat.h',
  'sys/statvfs.h',
  'sys/time.h',
  'sys/times.h',
  'sys/types.h',
  'sys/uio.h',
  'sys/un.h',
  'sys/utsname.h',
  'sys/wait.h',
  'syslog.h',
  'tar.h',
  'termios.h',
  'tgmath.h',
  'time.h',
  'trace.h',
  'ulimit.h',
  'unistd.h',
  'utime.h',
  'utmpx.h',
  'wchar.h',
  'wctype.h',
  'wordexp.h',
];

const _linuxHeaders = const ['sys/prctl.h',];

/// Returns true if [h] is system header
bool isSystemHeader(String h) => _systemHeaders.contains(h) ||
    _posixHeaders.contains(h) ||
    _linuxHeaders.contains(h);

final _accessRegex =
    new RegExp(r"\s*public:|private:|protected:\s*", multiLine: true);

/// Returns [original] as a C++ string literal
///
///    print("std::string x = ${cppStringLit('''
///    This is a test
///    Of the emergency
///    ''')};");
///
/// prints:
///
///    std::string x = "This is a test\n"
///    "Of the emergency\n"
///    "\n";
String cppStringLit(String original) =>
    original.split('\n').map((l) => '"$l\\n"').join('\n');

Template template([Iterable<String> decls]) => new Template(decls);

// end <library ebisu_cpp>
