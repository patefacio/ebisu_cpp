library ebisu_cpp.test.test_cpp_class;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_class>
// end <library test_cpp_class>
main() {
// custom <main>

  test('basic', () {

    final c = class_('c_1')
      ..basesPublic = ['Foo', 'Bar']
      ..enums = [
        enum_('letters')
        ..hasToCStr = true
        ..hasFromCStr = true
        ..values = [ 'a','b','c' ],
      ]
      ..enumsForward = [
        enum_('abcs')..values = [ 'a','b','c'],
      ]
      ..members = [
        member('foo_bar')..type = 'string'..init = '"Foo"',
        member('foo_bor')..type = 'int',
        member('foo_bur')..type = 'string',
      ]
      ..getCodeBlock(cbProtected).snippets.addAll(['Foobargoo', 'int foobargoo'])
      ..methods = [ equal, less ]
      ..customBlocks = [ cbPublic, cbPrivate ]
      ..headers = [ 'cmath', 'boost/filesystem.hpp' ]
      ..implHeaders = [ 'cmath', 'boost/filesystem.hpp' ]
      ..forwardPtrs = [ sptr, uptr, scptr, ucptr ];

    final d = c.definition;
    print(d);

    //print('Headers for ${c.className} => ${c.headers}');
  });
// end <main>

}
