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

  // custom <class Lib>

  Lib(Id id) : super(id);

  generate() {
    headers.forEach((Header header) {
      print('********* Generating header $id *********');
      header.namespace = namespace;
      header.generate();
    });
  }

  // end <class Lib>
}

class Header extends Entity {

  Namespace namespace = new Namespace();
  List<Class> classes = [];

  // custom <class Header>

  Header(Id id) : super(id);

  generate() {
    classes.forEach((Class cls) {
      print('**** Generating class ${cls.id} ****');
      print(namespace.wrap(cls.definition));
    });
  }

  // end <class Header>
}
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id? id : new Id(id));
Header header(Object id) => new Header(id is Id? id : new Id(id));

// end <part lib>
