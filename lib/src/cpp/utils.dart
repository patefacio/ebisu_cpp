part of ebisu_cpp.cpp;

class Namespace {

  List<String> names;

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
// custom <part utils>

Namespace namespace(List<String> ns) =>
  new Namespace()..names = ns;

Headers headers([ List<String> headers ]) =>
  new Headers(headers);

// end <part utils>
