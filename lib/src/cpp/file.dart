part of ebisu_cpp.cpp;

class CppFile {

  CppFile(this.filename, this.path, this.contents, [ this.namespace ]);

  Id filename;
  String path;
  String contents;
  Namespace namespace;
  bool isHeader = true;
  String includeGuard;
  Map<FileCodeBlock, CodeBlock> codeBlocks = {};

  // custom <class CppFile>

  generate() {
    final headerPath = '$path/${filename.snake}${isHeader? ".hpp" : ".cpp"}';
    mergeWithFile(_contents, headerPath);
  }

  String get _insides => combine([
    _codeBlockText(FileCodeBlock.FCB_PRE_NAMESPACE),
    namespace.wrap(
      combine([
        _codeBlockText(FileCodeBlock.FCB_BEGIN_NAMESPACE),
        contents,
        _codeBlockText(FileCodeBlock.FCB_END_NAMESPACE)
      ])),
    _codeBlockText(FileCodeBlock.FCB_POST_NAMESPACE),
  ]);

  _codeBlockText(FileCodeBlock cb) {
    final codeBlock = codeBlocks[cb];
    return codeBlock != null? codeBlock.toString() : null;
  }

  String get _contents => isHeader?
    _wrapIncludeGuard(_insides) : _insides;

  String get _includeGuard => namespace == null? '__${filename.shout}__' :
    '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${filename.shout}__';

  String _wrapIncludeGuard(String text) =>
    isHeader? '''
#ifndef $_includeGuard
#define $_includeGuard
$text
#endif // $_includeGuard
''': text;

  // end <class CppFile>
}
// custom <part file>

// end <part file>
