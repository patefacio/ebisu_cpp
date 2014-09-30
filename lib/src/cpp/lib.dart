part of ebisu_cpp.cpp;

class FileCodeBlock implements Comparable<FileCodeBlock> {
  static const FCB_PRE_NAMESPACE = const FileCodeBlock._(0);
  static const FCB_POST_NAMESPACE = const FileCodeBlock._(1);
  static const FCB_BEGIN_NAMESPACE = const FileCodeBlock._(2);
  static const FCB_END_NAMESPACE = const FileCodeBlock._(3);

  static get values => [
    FCB_PRE_NAMESPACE,
    FCB_POST_NAMESPACE,
    FCB_BEGIN_NAMESPACE,
    FCB_END_NAMESPACE
  ];

  final int value;

  int get hashCode => value;

  const FileCodeBlock._(this.value);

  copy() => this;

  int compareTo(FileCodeBlock other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case FCB_PRE_NAMESPACE: return "FcbPreNamespace";
      case FCB_POST_NAMESPACE: return "FcbPostNamespace";
      case FCB_BEGIN_NAMESPACE: return "FcbBeginNamespace";
      case FCB_END_NAMESPACE: return "FcbEndNamespace";
    }
    return null;
  }

  static FileCodeBlock fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "FcbPreNamespace": return FCB_PRE_NAMESPACE;
      case "FcbPostNamespace": return FCB_POST_NAMESPACE;
      case "FcbBeginNamespace": return FCB_BEGIN_NAMESPACE;
      case "FcbEndNamespace": return FCB_END_NAMESPACE;
      default: return null;
    }
  }

}

class Lib extends Entity {

  Namespace namespace = new Namespace();
  List<Header> headers = [];
  Installation installation;

  // custom <class Lib>

  Lib(Id id) : super(id);

  generate() {
    final cpp = installation.paths["cpp"];
    headers.forEach((Header header) {
      header.namespace = namespace;
      final headerPath = '${installation.cppPath}/${namespace.asPath}';
      final headerFile = new CppFile(header.id, headerPath,
          header.contents(), namespace)
        ..codeBlocks = header.codeBlocks;
      headerFile.generate();
    });
  }

  String toString() => '''
    lib($id)
      headers:\n${headers.map((h) => h.toString()).join('\n')}
''';

  // end <class Lib>
}

class Header extends Entity {

  Namespace namespace = new Namespace();
  List<Class> classes = [];
  Map<FileCodeBlock, CodeBlock> get codeBlocks => _codeBlocks;

  // custom <class Header>

  Header(Id id) : super(id);

  contents() =>
      namespace.wrap(
        combine([
          classes.map((Class cls) => cls.definition),
                ]));

  String toString() => '''
        header($id)
          classes:[${classes.map((cls) => cls.className).join(', ')}]
''';

  // end <class Header>
  Map<FileCodeBlock, CodeBlock> _codeBlocks = {};
}
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id? id : new Id(id));
Header header(Object id) => new Header(id is Id? id : new Id(id));

// end <part lib>
