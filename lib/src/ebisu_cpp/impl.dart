part of ebisu_cpp.ebisu_cpp;

/// A single implementation file (i.e. *cpp* file)
class Impl extends CppFile {

  // custom <class Impl>

  Impl(Id id) : super(id);

  Namespace get namespace => super.namespace;

  String get contents => _contentsWithBlocks;

  setLibFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    _filePath = path.join(rootFilePath, 'lib', namespace.asPath, _basename);
  }

  setLibFilePath(String libFilePath) {
    _basename = path.basename(libFilePath);
    _filePath = libFilePath;
  }

  setAppFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    return _filePath = path.join(rootFilePath, 'app', id.snake, _basename);
  }

  // end <class Impl>

}

// custom <part impl>

Impl impl(Object id) => new Impl(id is Id ? id : new Id(id));

// end <part impl>
