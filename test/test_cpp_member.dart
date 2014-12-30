library ebisu_cpp.test.test_cpp_member;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:ebisu_cpp/cpp.dart';

// end <additional imports>

// custom <library test_cpp_member>
// end <library test_cpp_member>
main() {
// custom <main>

  test('basic', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..static = true
      ..mutable = false
      ..init = '{"foo",1.2}, {"bar", 2.3}';
  });

  test('vref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('volatile& foo'), true);
  });

    test('cref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('const& foo'), true);
  });

  test('cvref', () {
    final m = member('foo')
      ..brief = 'This is a foo'
      ..refType = cvref
      ..descr = '''
Wee willy winkee went through the town.'''
      ..type = 'std::map<std::string, double>'
      ..mutable = false;
    expect(m.toString().contains('const volatile& foo'), true);
  });


  test('ref fields can not have init', () {
    try {
      final m = member('foo')
        ..brief = 'This is a foo'
        ..refType = cvref
        ..descr = '''
Wee willy winkee went through the town.'''
        ..type = 'std::map<std::string, double>'
        ..mutable = false
        ..init = '{"foo",1.2}, {"bar", 2.3}';

      fail('Excpected an exception since ref fields can not have init');
    } catch(e) {}
  });

// end <main>

}
