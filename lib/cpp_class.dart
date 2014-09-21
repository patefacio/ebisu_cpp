library ebisu_cpp.cpp_class;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/cpp_member.dart';
import 'package:id/id.dart';
// custom <additional imports>
// end <additional imports>

class CppClass {

  CppClass(this.id);

  /// Id for the class
  Id id;
  /// Brief description for the class
  String brief;

  // custom <class CppClass>

  String get definition {
    return '''
class ${id.capCamel}
};
''';
  }

  // end <class CppClass>
}

// custom <library cpp_class>

CppClass
cppClass([Object id]) =>
  new CppClass(id is Id? id : new Id(id));

// end <library cpp_class>
