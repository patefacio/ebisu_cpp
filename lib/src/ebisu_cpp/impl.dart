part of ebisu_cpp.ebisu_cpp;

/// A single implementation file (i.e. *cpp* file)
class Impl extends CppFile {
  String get filePath => _filePath;
  // custom <class Impl>

  Impl(Id id) : super(id);

  Namespace get namespace => super.namespace;

  String get contents => _contentsWithBlocks;

  setLibFilePathFromRoot(String root) =>
      _filePath = path.join(root, 'lib', namespace.asPath, namer.nameImpl(id));

  setAppFilePathFromRoot(String root) =>
      _filePath = path.join(root, 'app', id.snake, '${id.snake}.cpp');

  // end <class Impl>
  String _filePath;
}
// custom <part impl>

Impl impl(Object id) => new Impl(id is Id ? id : new Id(id));

// end <part impl>
