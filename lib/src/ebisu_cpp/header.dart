part of ebisu_cpp.ebisu_cpp;

/// A single c++ header
///
class Header extends CppFile {

  // custom <class Header>

  Header(Id id) : super(id);

  Namespace get namespace => super.namespace;

  get includeFilePath => path.join(namespace.asPath, namer.nameHeader(id));

  get requiresLogging => classes.any((cls) => cls.requiresLogging);

  setFilePathFromRoot(String rootFilePath, [name]) {
    __basename = name == null ? namer.nameHeader(id) : name;
    return _filePath = path.join(rootFilePath, namespace.asPath, _basename);
  }

  String get contents {
    if (classes.any((c) => c.isStreamable) &&
        !this.includes.contains('iostream')) {
      this.includes.add('iosfwd');
    }

    if (classes.any((c) => c.serializers.any((s) => s is Cereal))) {
      this.includes.addAll([
        'cereal/cereal.hpp',
        'fcs/timestamp/cereal.hpp',
        'cereal/archives/json.hpp',
      ]);
    }

    if (classes.any((c) => c.serializers.any((s) => s is DsvSerializer))) {
      this.includes.addAll(['cppformat/format.h',]);
    }

    addIncludesForCommonTypes(
        concat(classes.map((c) => c.typesReferenced)), this.includes);

    return _wrapIncludeGuard(_contentsWithBlocks);
  }

  String toString() => '''
header($id)
  classes:
${indentBlock(br(classes.map((cls) => cls.className)))}
  testScenarios:
${indentBlock(br(testScenarios))}
''';

  String get _includeGuard => namespace == null
      ? '__${id.shout}__'
      : '__${namespace.names.map((n) => new Id(n).shout).join("_")}_${id.shout}_HPP__';

  String _wrapIncludeGuard(String text) => '''
#ifndef $_includeGuard
#define $_includeGuard

$text
#endif // $_includeGuard
''';

  // end <class Header>

}

// custom <part header>
Header header(Object id) => new Header(id is Id ? id : new Id(id));
// end <part header>
