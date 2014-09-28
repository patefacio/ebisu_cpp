part of ebisu_cpp.cpp;

class CppFile {

  CppFile(this.filename, [ this.namespace ]);

  Id filename;
  Namespace namespace;
  bool isHeader = true;
  String includeGuard;
  Map<FileCodeBlock, CodeBlock> get customBlocks => _customBlocks;

  // custom <class CppFile>

  String get contents => wrapIncludeGuard(combine([
'guts'
  ]));

  String get _includeGuard => namespace == null? '__${filename.shout}__' :
    '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${filename.shout}__';

  String wrapIncludeGuard(String text) =>
    isHeader? '''
#ifndef $_includeGuard
#define $_includeGuard
$text
#endif // $_includeGuard
''': text;

  // end <class CppFile>
  Map<FileCodeBlock, CodeBlock> _customBlocks = {};
}
// custom <part file>

CppFile
  cppFile(Object f, [namespace]) =>
  f is String?
  new CppFile(new Id(f), namespace) :
  new CppFile(f, namespace);

// end <part file>
