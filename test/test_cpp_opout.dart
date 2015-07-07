library ebisu_cpp.test_cpp_opout;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_opout');

// custom <library test_cpp_opout>
// end <library test_cpp_opout>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('basic opOut', () {
    final c = class_('cls')
      ..isStreamable = true
      ..members = [
        member('a')..init = 1,
        member('b')..init = 3.14,
        member('c')
          ..type = 'std::string'
          ..init = "foo",
      ];

    expect(darkMatter(c.definition), darkMatter(r'''
class Cls
{

public:
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           Cls const& item) {
    out << "Cls(" << &item << ") {";
    out << "\n  a:" << item.a_;
    out << "\n  b:" << item.b_;
    out << "\n  c:" << item.c_;
    out << "\n}\n";
    return out;
  }

private:
  int a_ { 1 };
  double b_ { 3.14 };
  std::string c_ { "foo" };

};
'''));
  });

  test('basic opOut with indentation', () {
    final c = class_('cls')
      ..usesNestedIndent = true
      ..members = [
        member('a')..init = 1,
        member('b')..init = 3.14,
        member('c')
          ..type = 'std::string'
          ..init = "foo",
      ];
    expect(darkMatter(c.definition), darkMatter(r'''
class Cls
{

public:
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           Cls const& item) {
    ebisu::utils::Block_indenter indenter;
    char const* indent(indenter.current_indentation_text());
    out << indent << "Cls(" << &item << ") {";
    out << '\n' << indent << "  a:" << item.a_;
    out << '\n' << indent << "  b:" << item.b_;
    out << '\n' << indent << "  c:" << item.c_;
    out << '\n' << indent << "}\n";
    return out;
  }

private:
  int a_ { 1 };
  double b_ { 3.14 };
  std::string c_ { "foo" };

};
'''));
  });

  test('opOut with bases', () {
    final c = class_('cls')
      ..bases = [base('Base')..isStreamable = true]
      ..isStreamable = true
      ..members = [
        member('a')..init = 1,
        member('b')..init = 3.14,
        member('c')
          ..type = 'std::string'
          ..init = "foo",
      ];

    expect(darkMatter(c.definition), darkMatter(r'''
class Cls :
  public Base
{

public:
  friend inline
  std::ostream& operator<<(std::ostream &out,
                           Cls const& item) {
    out << "Cls(" << &item << ") {";
    out << "\n  " << static_cast<Base>(item);
    out << "\n  a:" << item.a_;
    out << "\n  b:" << item.b_;
    out << "\n  c:" << item.c_;
    out << "\n}\n";
    return out;
  }

private:
  int a_ { 1 };
  double b_ { 3.14 };
  std::string c_ { "foo" };

};
'''));
  });

// end <main>

}
