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

    final l =
      lib('lib1')
      ..namespace = namespace(['foo','bar'])
      ..headers = [
        header('guts')    
        ..headers = [ 'cmath', 'boost/filesystem.hpp' ]
        ..classes = [
          class_('c_1')
          ..streamable = true
          ..bases = [
            base('Foo'),
            base('Bar')..access = protected,
            base('Goo')..virtual = true
          ]
          ..enums = [
            enum_('letters')
            ..streamable = true
            ..hasFromCStr = false
            ..values = [ 'a','b','c' ],
          ]
          ..enumsForward = [
            enum_('abcs')..streamable = true..values = [ 'a','b','c'],
          ]
          ..members = [
            member('foo_bar')..type = 'std::string'..init = '"Foo"',
            member('foo_bor')..type = 'int',
            member('foo_bur')..type = 'std::string',
            member('letters')..type = 'Letters'..init = 'C_1::B_e',
          ]
          ..getCodeBlock(clsProtected).snippets.addAll(['//Sample code block stuff...'])
          ..methods = [ equal, less ]
          ..customBlocks = [ clsPublic, clsPrivate ]
          ..forwardPtrs = [ sptr, uptr, scptr, ucptr ]
        ]
      ];

    l.generate();

    //print('Headers for ${c.className} => ${c.headers}');
  });
// end <main>

}
