library ebisu_cpp.cpp_utils;

import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
// custom <additional imports>
// end <additional imports>

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

// custom <library cpp_utils>

Namespace namespace(List<String> ns) =>
  new Namespace()..names = ns;

// end <library cpp_utils>
