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
      header
        ..namespace = namespace
        .._filePath = '${installation.cppPath}/${namespace.asPath}/${header.id.snake}.hpp'
        ..generate();
    });
  }

  String toString() => '''
    lib($id)
      headers:\n${headers.map((h) => h.toString()).join('\n')}
''';

  // end <class Lib>
}

class Header extends CppFile {

  Namespace namespace;
  String get filePath => _filePath;
  List<Class> classes = [];

  // custom <class Header>

  Header(Id id) : super(id);

  String get contents =>
    _wrapIncludeGuard(
      _contentsWithBlocks(
        combine([
          classes.map((Class cls) => cls.definition),
        ])));

  String toString() => '''
        header($id)
          classes:[${classes.map((cls) => cls.className).join(', ')}]
''';

  String get _includeGuard => namespace == null? '__${id.shout}__' :
    '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${id.shout}_HPP__';

  String _wrapIncludeGuard(String text) =>'''
#ifndef $_includeGuard
#define $_includeGuard

$text
#endif // $_includeGuard
''';

  // end <class Header>
  String _filePath;
}

class Impl extends CppFile {

  String get filePath => _filePath;
  List<Class> classes = [];

  // custom <class Impl>
  
  Impl(Id id) : super(id);

  String get contents =>
    _contentsWithBlocks(
      combine(classes.map((Class cls) => cls.definition)));
 
  // end <class Impl>
  String _filePath;
}
// custom <part lib>

Lib lib(Object id) => new Lib(id is Id? id : new Id(id));
Header header(Object id) => new Header(id is Id? id : new Id(id));

const fcbPreNamespace = FileCodeBlock.FCB_PRE_NAMESPACE;
const fcbPostNamespace = FileCodeBlock.FCB_POST_NAMESPACE;
const fcbBeginNamespace = FileCodeBlock.FCB_BEGIN_NAMESPACE;
const fcbEndNamespace = FileCodeBlock.FCB_END_NAMESPACE;

// end <part lib>
