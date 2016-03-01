library ebisu_cpp.test_print_instance;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final _logger = new Logger('test_print_instance');

// custom <library test_print_instance>

// end <library test_print_instance>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('print_instance', () {
    final a = class_('a')
      ..isStruct = true
      ..defaultCppAccess = public
      ..members = [member('m')..init = 'a.m']
      ..giveDefaultPrinterSupport();

    final b = class_('b')
      ..defaultCppAccess = public
      ..members = [member('a')..type = 'A', member('n')..init = 'b.n']
      ..giveDefaultPrinterSupport();

    final c = class_('c')
      ..defaultCppAccess = public
      ..members = [
        member('b')..type = b.className,
        member('x')..init = "foo",
        member('y')..init = 3,
        member('z')..init = 3.14,
      ]
      ..giveDefaultPrinterSupport();

    final d = class_('d')
      ..members = [member('z')..init = 3.14,]
      ..giveDefaultPrinterSupport()
      ..printerSupport.customPrinters = true;

    final h = header('h')
      ..namespace = namespace(['test'])
      ..classes = [a, b, c, d]
      ..setAsRoot();

    expect(darkMatter(h.contents), darkMatter(r'''
#ifndef __TEST_H_HPP__
#define __TEST_H_HPP__

#include "ebisu/utils/streamers/printer.hpp"
#include <string>

namespace test {
struct A {
  friend inline std::ostream& print_instance(
      std::ostream& out, A const& item,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;

    printer_descriptor.printer_state.frame++;

    std::string indent;
    if (spec.nested_indent) {
      indent = std::string(2 * printer_descriptor.printer_state.frame, ' ');
    }

    if (spec.name_types) {
      out << "<A>\n";
    }

    if (spec.name_members) {
      item.print_members_named(out, indent, printer_descriptor);
    } else {
      item.print_members_anonymous(out, indent, printer_descriptor);
    }

    printer_descriptor.printer_state.frame--;

    if (printer_descriptor.printer_state.frame == 0) {
      out << spec.final_separator;
    }

    return out;
  }

  std::string m{"a.m"};

 private:
  std::ostream& print_members_named(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    out << indent << "m" << spec.name_value_separator;
    print_instance(out, m, printer_descriptor);

    return out;
  }

  std::ostream& print_members_anonymous(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    print_instance(out, m, printer_descriptor);

    return out;
  }
};

class B {
 public:
  friend inline std::ostream& print_instance(
      std::ostream& out, B const& item,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;

    printer_descriptor.printer_state.frame++;

    std::string indent;
    if (spec.nested_indent) {
      indent = std::string(2 * printer_descriptor.printer_state.frame, ' ');
    }

    if (spec.name_types) {
      out << "<B>\n";
    }

    if (spec.name_members) {
      item.print_members_named(out, indent, printer_descriptor);
    } else {
      item.print_members_anonymous(out, indent, printer_descriptor);
    }

    printer_descriptor.printer_state.frame--;

    if (printer_descriptor.printer_state.frame == 0) {
      out << spec.final_separator;
    }

    return out;
  }

  A a{};
  std::string n{"b.n"};

 private:
  std::ostream& print_members_named(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    out << indent << "a" << spec.name_value_separator;
    print_instance(out, a, printer_descriptor);
    out << spec.member_separator;
    out << indent << "n" << spec.name_value_separator;
    print_instance(out, n, printer_descriptor);

    return out;
  }

  std::ostream& print_members_anonymous(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    print_instance(out, a, printer_descriptor);
    out << spec.member_separator;
    print_instance(out, n, printer_descriptor);

    return out;
  }
};

class C {
 public:
  friend inline std::ostream& print_instance(
      std::ostream& out, C const& item,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;

    printer_descriptor.printer_state.frame++;

    std::string indent;
    if (spec.nested_indent) {
      indent = std::string(2 * printer_descriptor.printer_state.frame, ' ');
    }

    if (spec.name_types) {
      out << "<C>\n";
    }

    if (spec.name_members) {
      item.print_members_named(out, indent, printer_descriptor);
    } else {
      item.print_members_anonymous(out, indent, printer_descriptor);
    }

    printer_descriptor.printer_state.frame--;

    if (printer_descriptor.printer_state.frame == 0) {
      out << spec.final_separator;
    }

    return out;
  }

  B b{};
  std::string x{"foo"};
  int y{3};
  double z{3.14};

 private:
  std::ostream& print_members_named(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    out << indent << "b" << spec.name_value_separator;
    print_instance(out, b, printer_descriptor);
    out << spec.member_separator;
    out << indent << "x" << spec.name_value_separator;
    print_instance(out, x, printer_descriptor);
    out << spec.member_separator;
    out << indent << "y" << spec.name_value_separator;
    print_instance(out, y, printer_descriptor);
    out << spec.member_separator;
    out << indent << "z" << spec.name_value_separator;
    print_instance(out, z, printer_descriptor);

    return out;
  }

  std::ostream& print_members_anonymous(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    print_instance(out, b, printer_descriptor);
    out << spec.member_separator;
    print_instance(out, x, printer_descriptor);
    out << spec.member_separator;
    print_instance(out, y, printer_descriptor);
    out << spec.member_separator;
    print_instance(out, z, printer_descriptor);

    return out;
  }
};

class D {
 public:
  friend inline std::ostream& print_instance(
      std::ostream& out, D const& item,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;

    printer_descriptor.printer_state.frame++;

    std::string indent;
    if (spec.nested_indent) {
      indent = std::string(2 * printer_descriptor.printer_state.frame, ' ');
    }

    if (spec.name_types) {
      out << "<D>\n";
    }

    if (spec.name_members) {
      item.print_members_named(out, indent, printer_descriptor);
    } else {
      item.print_members_anonymous(out, indent, printer_descriptor);
    }

    printer_descriptor.printer_state.frame--;

    if (printer_descriptor.printer_state.frame == 0) {
      out << spec.final_separator;
    }

    return out;
  }

 private:
  std::ostream& print_members_named(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    // custom <members named>
    // end <members named>

    return out;
  }

  std::ostream& print_members_anonymous(
      std::ostream& out, std::string const& indent,
      ebisu::utils::streamers::Printer_descriptor& printer_descriptor) const {
    using namespace ebisu::utils::streamers;
    Printer_spec const& spec = printer_descriptor.printer_spec;
    // custom <members anonymous>
    // end <members anonymous>

    return out;
  }
  double z_{3.14};
};

}  // namespace test

#endif  // __TEST_H_HPP__
'''));
  });

// end <main>
}
