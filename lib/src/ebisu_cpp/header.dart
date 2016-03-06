part of ebisu_cpp.ebisu_cpp;

/// A single c++ header
class Header extends CppFile {
  /// If set will use `#pragma once` instead of include guards
  set usePragmaOnce(bool usePragmaOnce) => _usePragmaOnce = usePragmaOnce;

  // custom <class Header>

  Header(Id id) : super(id);

  Namespace get namespace => super.namespace;

  get includeFilePath => _includeFilePrefix == null
      ? path.join(namespace.asPath, namer.nameHeader(id))
      : path.join(_includeFilePrefix, namespace.asPath, namer.nameHeader(id));

  /// returns true if will use pragma once to prevent duplicates instead of
  /// default include guards.
  get usePragmaOnce =>
      _usePragmaOnce ?? (((this.installation)?.usePragmaOnce) ?? false);

  /// returns true if any class requires logging
  get requiresLogging => classes.any((cls) => cls.requiresLogging);

  setFilePathFromRoot(String rootFilePath, [name]) {
    __basename = name == null ? namer.nameHeader(id) : name;
    return _filePath == null
        ? _filePath = path.join(rootFilePath, namespace.asPath, _basename)
        : _filePath;
  }

  String get contents {
    if (classes.any((c) => c.isStreamable) &&
        !this.includes.contains('iostream')) {
      this.includes.add('iosfwd');
    }

    if (classes.any((c) => c.serializers.any((s) => s is Cereal))) {
      this.includes.addAll([
        'cereal/cereal.hpp',
        'ebisu/timestamp/cereal.hpp',
        'cereal/archives/json.hpp',
      ]);
    }

    if (classes.any((c) => c.serializers.any((s) => s is DsvSerializer))) {
      this.includes.addAll(['cppformat/format.h',]);
    }

    addIncludesForCommonTypes(
        concat(classes.map((c) => c.typesReferenced)), this.includes);

    return _duplicateProtection(_contentsWithBlocks);
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
      : '__${namespace.names.map((n) => idFromString(n).shout).join("_")}_${id.shout}_HPP__';

  String _duplicateProtection(text) => usePragmaOnce
      ? '''
#pragma once

$text
'''
      : _wrapIncludeGuard(text);

  String _wrapIncludeGuard(String text) => '''
#ifndef $_includeGuard
#define $_includeGuard

$text
#endif // $_includeGuard
''';

  setIncludeFilePrefix(includePrefix) {
    _includeFilePrefix = includePrefix;
  }

  setHeaderFilePath(filePath, [name]) {
    __basename = name == null ? namer.nameHeader(id) : name;
    return _filePath = path.join(filePath, _basename);
  }

  String _includeFilePrefix;

  // end <class Header>

  bool _usePragmaOnce;
}

// custom <part header>
Header header(Object id) => new Header(id is Id ? id : new Id(id));
// end <part header>
