part of ebisu_cpp.ebisu_cpp;

/// A single implementation file (i.e. *cpp* file)
class Impl extends CppFile {
  // custom <class Impl>

  Impl(id) : super(id);

  Namespace get namespace => super.namespace;

  String get contents => _contentsWithBlocks;

  get requiresLogging => false;

  setLibFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    _filePath = path.join(rootFilePath, 'lib', namespace.asPath, _basename);
  }

  setLibFilePath(String libFilePath) {
    _basename = path.basename(libFilePath);
    _filePath = libFilePath;
  }

  setFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    return _filePath = path.join(rootFilePath, id.snake, _basename);
  }

  setAppFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    return _filePath = path.join(rootFilePath, 'app', id.snake, _basename);
  }

  setBenchmarkFilePathFromRoot(String rootFilePath, [name]) {
    _basename = name == null ? namer.nameImpl(id) : name;
    return _filePath =
        path.join(rootFilePath, 'benchmarks', 'app', id.snake, _basename);
  }

  _setImplFilePath(filePath, [name]) {
    __basename = name == null ? namer.nameImpl(id) : name;
    return _filePath = path.join(filePath, _basename);
  }

  // end <class Impl>

}

// custom <part impl>

Impl impl(id) => new Impl(id);

// end <part impl>
