part of ebisu_cpp.cpp;

abstract class CppFile extends Entity {

  Namespace namespace;
  List<FileCodeBlock> customBlocks = [];
  Headers get headers => _headers;

  // custom <class CppFile>

  CppFile(Id id) : super(id);

  String get contents;
  String get filePath;

  set headers(Object h) => _headers = _makeHeaders(h);
  _makeHeaders(Object h) =>
    h is Iterable? new Headers(h) :
    h is String? new Headers([h]) :
    h is Headers? h :
    throw 'Headers must be String, List<String> or Headers';

  generate() => mergeWithFile(contents, filePath);

  CodeBlock getCodeBlock(FileCodeBlock fcb) {
    final result = _codeBlocks[fcb];
    return result == null? (_codeBlocks[fcb] = codeBlock()) : result;
  }

  String _contentsWithBlocks(String original) {
    customBlocks.forEach((cb) => getCodeBlock(cb).tag = '$cb ${id.snake}');

    return combine([
      br(_headers.includes),
      _codeBlockText(FileCodeBlock.FCB_PRE_NAMESPACE),
      namespace.wrap(
        combine([
          _codeBlockText(FileCodeBlock.FCB_BEGIN_NAMESPACE),
          original,
          _codeBlockText(FileCodeBlock.FCB_END_NAMESPACE)
        ])),
      _codeBlockText(FileCodeBlock.FCB_POST_NAMESPACE),
    ]);
  }

  _codeBlockText(FileCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null? codeBlock.toString() : null;
  }

  // end <class CppFile>
  Map<FileCodeBlock, CodeBlock> _codeBlocks = {};
  Headers _headers = new Headers();
}
// custom <part file>

// end <part file>
