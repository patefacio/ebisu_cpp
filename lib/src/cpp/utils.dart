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
// custom <part utils>

Namespace namespace(List<String> ns) =>
  new Namespace()..names = ns;

// end <part utils>
