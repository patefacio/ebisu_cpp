part of ebisu_cpp.cpp;

class Namespace {

  List<String> names = [];

  // custom <class Namespace>

  String wrap(String txt) =>
    _helper(names.iterator, txt);

  String _helper(Iterator<String> it, String txt) {
    if(it.moveNext()) {
      final name = it.current;
      return '''
namespace $name {
${_helper(it, txt)}
} // namespace $name''';
    } else {
      return indentBlock(txt);
    }
  }

  String toString() => names.join('::');
  String get asPath => names.join('/');

  // end <class Namespace>
}

/// Collection of headers to be included
class Headers {

  Set<String> get headers => _headers;

  // custom <class Headers>

  Headers([ Iterable<String> from ]) :
    _headers = new Set.from(from);

  String get includes {
    final boostHeaders = [];
    final systemHeaders = [];
    final rest = [];
    _headers.forEach((String header) {
      if(header.contains('boost/')) {
        boostHeaders.add(_sysInclude(header));
      } else if(isSystemHeader(header)) {
        systemHeaders.add(_sysInclude(header));
      } else {
        rest.add(_include(header));
      }
    });
    return
    concat([rest..sort(), boostHeaders..sort(), systemHeaders..sort()])
    .map((h) => h).join('\n');
  }

  add(String header) => _headers.add(header);
  addAll(Iterable<String> more) => _headers.addAll(more);

  String toString() => includes;

  static _sysInclude(String header) => '#include <$header>';
  static _include(String header) => '#include "$header"';

  // end <class Headers>
  Set<String> _headers;
}

/// Wraps an optional protection block with optional code injection
class CodeBlock {

  CodeBlock(this.tag);

  /// Tag for protect block. If present includes protect block
  String tag;
  List<String> snippets = [];
  bool hasSnippetsFirst = false;

  // custom <class CodeBlock>

  bool get hasTag => tag != null && tag.length > 0;

  String toString() {
    if(hasTag) {
      return hasSnippetsFirst?
        combine([ ]..addAll(snippets)..add(customBlock(tag))) :
        combine([ customBlock(tag) ]..addAll(snippets));
    }
    return combine(snippets);
  }

  // end <class CodeBlock>
}

/// Create a CodeBlock sans new, for more declarative construction
CodeBlock
codeBlock([String tag]) =>
  new CodeBlock(tag);

/// Base class
class Base {

  Base(this.className);

  String className;
  /// Is base class public, protected, or private
  CppAccess access = public;
  /// How to initiailize the base class in ctor initializer
  String init;
  /// If true inheritance is virtual
  bool virtual = false;
  /// If true and streamers are being provided, base is streamed first
  bool streamable = false;

  // custom <class Base>

  String get decl => '$access $_virtual$className';
  String get _virtual => virtual? 'virtual ' : '';

  // end <class Base>
}

/// Create a Base sans new, for more declarative construction
Base
base([String className]) =>
  new Base(className);
// custom <part utils>

Namespace namespace(List<String> ns) =>
  new Namespace()..names = ns;

Headers headers([ List<String> headers ]) =>
  new Headers(headers);

// end <part utils>
