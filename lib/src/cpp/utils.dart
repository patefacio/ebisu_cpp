part of ebisu_cpp.cpp;

abstract class CodeGenerator {


  // custom <class CodeGenerator>

  void generate();

  // end <class CodeGenerator>
}

class Namespace {

  List<String> names = [];

  // custom <class Namespace>

  String wrap(String txt) =>
    _helper(names.iterator, txt);

  String get using => 'using namespace $this';

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

/// Collection of header includes
class Includes {

  Set<String> get included => _included;

  // custom <class Includes>

  Includes([ Iterable<String> from ]) :
    _included = from == null? new Set() : new Set.from(from);

  Iterable<String> get includeEntries {
    final boostHeaders = [];
    final systemHeaders = [];
    final rest = [];
    _included.forEach((String include) {
      if(include.contains('boost/')) {
        boostHeaders.add(_sysInclude(include));
      } else if(isSystemHeader(include)) {
        systemHeaders.add(_sysInclude(include));
      } else {
        rest.add(_include(include));
      }
    });
    return concat([
      rest..sort(), boostHeaders..sort(), systemHeaders..sort()]);
  }

  String get includes =>
    includeEntries.map((h) => h).join('\n');

  add(String include) => _included.add(include);
  addAll(Iterable<String> more) => _included.addAll(more);

  String toString() => includes;

  static _sysInclude(String include) => '#include <$include>';
  static _include(String include) => '#include "$include"';

  // end <class Includes>
  Set<String> _included;
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

Includes includes([ List<String> includes ]) =>
  new Includes(includes);

// end <part utils>
