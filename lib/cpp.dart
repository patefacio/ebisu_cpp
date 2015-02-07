/// Library to facility generation of c++ code.
///
/// The intent is to get as declarative as possible with the specification
/// of C++ entities to make code generation as simple and fun as possible.
///
///
library ebisu_cpp.cpp;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';
// custom <additional imports>
// end <additional imports>

part 'src/cpp/utils.dart';
part 'src/cpp/file.dart';
part 'src/cpp/enum.dart';
part 'src/cpp/member.dart';
part 'src/cpp/class.dart';
part 'src/cpp/serializer.dart';
part 'src/cpp/lib.dart';
part 'src/cpp/app.dart';
part 'src/cpp/cmake_support.dart';
part 'src/cpp/jam_support.dart';
part 'src/cpp/script.dart';
part 'src/cpp/test.dart';
part 'src/cpp/installation.dart';

final _logger = new Logger('cpp');

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access implements Comparable<Access> {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);
  static const WO = const Access._(3);

  static get values => [
    IA,
    RO,
    RW,
    WO
  ];

  final int value;

  int get hashCode => value;

  const Access._(this.value);

  copy() => this;

  int compareTo(Access other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case IA: return "Ia";
      case RO: return "Ro";
      case RW: return "Rw";
      case WO: return "Wo";
    }
    return null;
  }

  static Access fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Ia": return IA;
      case "Ro": return RO;
      case "Rw": return RW;
      case "Wo": return WO;
      default: return null;
    }
  }

}

/// Cpp access
class CppAccess implements Comparable<CppAccess> {
  static const PUBLIC = const CppAccess._(0);
  static const PRIVATE = const CppAccess._(1);
  static const PROTECTED = const CppAccess._(2);

  static get values => [
    PUBLIC,
    PRIVATE,
    PROTECTED
  ];

  final int value;

  int get hashCode => value;

  const CppAccess._(this.value);

  copy() => this;

  int compareTo(CppAccess other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case PUBLIC: return "public";
      case PRIVATE: return "private";
      case PROTECTED: return "protected";
    }
    return null;
  }

  static CppAccess fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "public": return PUBLIC;
      case "private": return PRIVATE;
      case "protected": return PROTECTED;
      default: return null;
    }
  }

}

/// Reference type
class RefType implements Comparable<RefType> {
  static const REF = const RefType._(0);
  static const CREF = const RefType._(1);
  static const VREF = const RefType._(2);
  static const CVREF = const RefType._(3);
  static const VALUE = const RefType._(4);

  static get values => [
    REF,
    CREF,
    VREF,
    CVREF,
    VALUE
  ];

  final int value;

  int get hashCode => value;

  const RefType._(this.value);

  copy() => this;

  int compareTo(RefType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case REF: return "Ref";
      case CREF: return "Cref";
      case VREF: return "Vref";
      case CVREF: return "Cvref";
      case VALUE: return "Value";
    }
    return null;
  }

  static RefType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Ref": return REF;
      case "Cref": return CREF;
      case "Vref": return VREF;
      case "Cvref": return CVREF;
      case "Value": return VALUE;
      default: return null;
    }
  }

}

/// Standard pointer type declaration
class PtrType implements Comparable<PtrType> {
  static const SPTR = const PtrType._(0);
  static const UPTR = const PtrType._(1);
  static const SCPTR = const PtrType._(2);
  static const UCPTR = const PtrType._(3);

  static get values => [
    SPTR,
    UPTR,
    SCPTR,
    UCPTR
  ];

  final int value;

  int get hashCode => value;

  const PtrType._(this.value);

  copy() => this;

  int compareTo(PtrType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case SPTR: return "Sptr";
      case UPTR: return "Uptr";
      case SCPTR: return "Scptr";
      case UCPTR: return "Ucptr";
    }
    return null;
  }

  static PtrType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Sptr": return SPTR;
      case "Uptr": return UPTR;
      case "Scptr": return SCPTR;
      case "Ucptr": return UCPTR;
      default: return null;
    }
  }

}

class Entity {
  Entity(this.id);

  /// Id for the entity
  Id id;
  /// Brief description for the entity
  String brief;
  /// Description of entity
  String descr;
  // custom <class Entity>

  String get briefComment => brief != null? '//! $brief' : null;
  String get detailedComment => descr != null?
    blockComment(descr, ' ') : null;

  // end <class Entity>
}

class Template {
  List<String> decls;
  // custom <class Template>

  Template(Iterable<String> decls_) : decls = new List<String>.from(decls_);

  String get decl => '''
template< ${decls.join(',\n          ')} >''';


  // end <class Template>
}

// custom <library cpp>

const ia = Access.IA;
const ro = Access.RO;
const rw = Access.RW;
const wo = Access.WO;

const public = CppAccess.PUBLIC;
const private = CppAccess.PRIVATE;
const protected = CppAccess.PROTECTED;

const ref = RefType.REF;
const cref = RefType.CREF;
const vref = RefType.VREF;
const cvref = RefType.CVREF;
const value = RefType.VALUE;

const sptr = PtrType.SPTR;
const uptr = PtrType.UPTR;
const scptr = PtrType.SCPTR;
const ucptr = PtrType.UCPTR;

const Map _ptrSuffixMap = const {
  sptr : 'sptr',
  uptr : 'uptr',
  scptr : 'scptr',
  ucptr : 'ucptr',
};

ptrSuffix(PtrType ptrType) => _ptrSuffixMap[ptrType];

Map _ptrStdTypeMap = {
  sptr : (String T) => 'std::shared_ptr< $T >',
  uptr : (String T) => 'std::unique_ptr< $T >',
  scptr : (String T) => 'std::shared_ptr< const $T >',
  ucptr : (String T) => 'std::unique_ptr< const $T >',
};

ptrType(PtrType ptrType, String t) =>
  _ptrStdTypeMap[ptrType](t);

String br(Object o) =>
  o == null? null :
  o is Iterable? br(combine(o)) :
  (o is String && o.length > 0) ? '$o\n' : '';

bool ignored(Object o) =>
  o == null || (o is String && (o as String).length == 0);

String combine(Iterable<Object> parts) {
  final result =
    parts
    .map((o) => (o is Iterable)? combine(o) : o)
    .where((o) => !ignored(o))
    .join('\n');
  return result;
  //return result == '' ? null : result;
}

String quote(String s) => '"$s"';

const _systemHeaders = const [
  'algorithm', 'array', 'atomic', 'bitset', 'cassert', 'ccomplex',
  'cctype', 'cerrno', 'cfenv', 'cfloat', 'chrono', 'cinttypes',
  'ciso646', 'climits', 'clocale', 'cmath', 'codecvt', 'complex',
  'condition_variable', 'csetjmp', 'csignal', 'cstdalign', 'cstdarg',
  'cstdbool', 'cstddef', 'cstdint', 'cstdio', 'cstdlib', 'cstring',
  'ctgmath', 'ctime', 'cuchar', 'cwchar', 'cwctype', 'deque',
  'exception', 'forward_list', 'fstream', 'functional', 'future',
  'initializer_list', 'iomanip', 'ios', 'iosfwd', 'iostream', 'istream',
  'iterator', 'limits', 'list', 'locale', 'map', 'memory', 'mutex',
  'new', 'numeric', 'ostream', 'queue', 'random', 'ratio', 'regex',
  'scoped_allocator', 'set', 'shared_mutex', 'sstream', 'stack',
  'stdexcept', 'streambuf', 'string', 'strstream', 'system_error',
  'thread', 'tuple', 'type_traits', 'typeindex', 'typeinfo',
  'unordered_map', 'unordered_set', 'utility', 'valarray', 'vector',
];

const _posixHeaders = const [
  'aio.h', 'arpa/inet.h', 'assert.h', 'complex.h', 'cpio.h',
  'ctype.h', 'dirent.h', 'dlfcn.h', 'errno.h', 'fcntl.h',
  'fenv.h', 'float.h', 'fmtmsg.h', 'fnmatch.h', 'ftw.h',
  'glob.h', 'grp.h', 'iconv.h', 'inttypes.h', 'iso646.h',
  'langinfo.h', 'libgen.h', 'limits.h', 'locale.h', 'math.h',
  'monetary.h', 'mqueue.h', 'ndbm.h', 'net/if.h', 'netdb.h',
  'netinet/in.h', 'netinet/tcp.h', 'nl_types.h', 'poll.h',
  'pthread.h', 'pwd.h', 'regex.h', 'sched.h', 'search.h',
  'semaphore.h', 'setjmp.h', 'signal.h', 'spawn.h', 'stdarg.h',
  'stdbool.h', 'stddef.h', 'stdint.h', 'stdio.h', 'stdlib.h',
  'string.h', 'strings.h', 'stropts.h', 'sys/ipc.h',
  'sys/mman.h', 'sys/msg.h', 'sys/resource.h', 'sys/select.h',
  'sys/sem.h', 'sys/shm.h', 'sys/socket.h', 'sys/stat.h',
  'sys/statvfs.h', 'sys/time.h', 'sys/times.h', 'sys/types.h',
  'sys/uio.h', 'sys/un.h', 'sys/utsname.h', 'sys/wait.h',
  'syslog.h', 'tar.h', 'termios.h', 'tgmath.h', 'time.h',
  'trace.h', 'ulimit.h', 'unistd.h', 'utime.h', 'utmpx.h',
  'wchar.h', 'wctype.h', 'wordexp.h',
];

const _linuxHeaders = const [
  'sys/prctl.h',
];

bool isSystemHeader(String h) =>
  _systemHeaders.contains(h) ||
  _posixHeaders.contains(h) ||
  _linuxHeaders.contains(h);

//final _accessRegex = new RegExp(r"(public:|private:|protected:)(.+?)(public:|private:|protected:)", multiLine: true);
final _accessRegex = new RegExp(r"\s*public:|private:|protected:\s*", multiLine: true);

String cleanAccess(String txt) {
  var result = [];
  var prior = null;
  var start = 0;

  _accessRegex.allMatches(txt).forEach((Match m) {
    final pre = txt.substring(start, m.start);
    final current = txt.substring(m.start, m.end);
    final rest = txt.substring(m.end);

    result.add(pre);
    result.add(current);
    prior = current;
    start = m.end;
  });

  result.add(txt.substring(start));

  return result.join('');
}

String cppStringLit(String original) =>
  original.split('\n').map((l) => '"$l\\n"').join('\n');

Template
template([Iterable<String> decls]) =>
  new Template(decls);

// end <library cpp>
