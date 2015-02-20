part of ebisu_cpp.ebisu_cpp;

class ParmDecl extends Entity {
  String type;
  // custom <class ParmDecl>

  ParmDecl(id) => super(id);

  static RegExp declRe = new RegExp(r'^(.*?)\s+(\w+)\s*$');

  factory ParmDecl.fromDecl(String decl) {
    final declMatch = declRe.firstMatch(decl);
    if(declMatch == null) {
      throw ArgumentError('''
Invalid parm decl: $decl
Try something familiar like these:
  int x
  char const* name
  Reduce_func_t reducer
''');
    }

    final id = idFromString(declMatch.group(1));
    final type = declMatch.group(2);

    return new ParmDecl(id)
      ..type = type;
  }

  // end <class ParmDecl>
}

class MethodDecl extends Entity {
  List<ParmDecl> parmDecls = [];
  String returnType;
  // custom <class MethodDecl>

  MethodDecl(id) => super(id);

  static RegExp declRe =
    new RegExp(r'^(.*?)\s+(\w+)\s*\(([^\)]*)\)\s*$');

  factory MethodDecl.fromDecl(String decl) {
    final declMatch = declRe.firstMatch(decl);
    if(declMatch == null) {
      throw ArgumentError('''
Invalid method decl: $decl
Try something familiar like: "void add(int a, int b)"
''');
    }

    final returnType = declMatch.group(1);
    final id = idFromString(declMatch.group(2));
    final parmsText = declMatch.group(3);

    final parmDecls = parmsText
      .split(',')
      .map((String parm) => new ParmDecl.fromDecl(parm))
      .toList();

    return new MethodDecl(id)
      ..returnType = returnType
      ..parmDecls = parmDecls;
  }

  // end <class MethodDecl>
}

class Interface extends Entity {
  /// If true interface results in pure abstract class, else *static
  /// polymorphic* base.
  bool isVirtual = false;
  List<MethodDecl> methodDecls = [];
  // custom <class Interface>

  MethodDecl(id) => super(id);

  // end <class Interface>
}

class AccessInterface extends Interface {
  CppAccess cppAccess = public;
  // custom <class AccessInterface>

  AccessInterface(id) : super(id);

  // end <class AccessInterface>
}
// custom <part method>
// end <part method>
