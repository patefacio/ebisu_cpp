part of ebisu_cpp.cpp;

abstract class CppFile extends Entity {

  Namespace namespace;
  List<FileCodeBlock> customBlocks = [];
  Includes get includes => _includes;
  List<String> usings = [];

  // custom <class CppFile>

  CppFile(Id id) : super(id);

  String get contents;
  String get filePath;
  List<Class> get classes;

  set includes(Object h) => _includes = _makeIncludes(h);

  _makeIncludes(Object h) =>
    h is Iterable? new Includes(h) :
    h is String? new Includes([h]) :
    h is Includes? h :
    throw 'Includes must be String, List<String> or Includes';

  generate() => mergeWithFile(contents, filePath);

  CodeBlock getCodeBlock(FileCodeBlock fcb) {
    final result = _codeBlocks[fcb];
    return result == null? (_codeBlocks[fcb] = codeBlock()) : result;
  }

  String _contentsWithBlocks(String original) {
    if(classes.any((c) => c._opMethods.any((m) => m is OpOut))) {
      _includes.add('fcs/utils/block_indenter.hpp');
    }
    customBlocks.forEach((cb) => getCodeBlock(cb).tag = '$cb ${id.snake}');

    return combine([
      br(_includes.includes),
      _codeBlockText(FileCodeBlock.FCB_CUSTOM_INCLUDES),
      _codeBlockText(FileCodeBlock.FCB_PRE_NAMESPACE),
      namespace.wrap(
        combine([
          _codeBlockText(FileCodeBlock.FCB_BEGIN_NAMESPACE),
          br(usings.map((u) => 'using $u;')),
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
  Includes _includes = new Includes();
}
// custom <part file>

// end <part file>
