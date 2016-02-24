part of ebisu_cpp.ebisu_cpp;

/// Describes details of how a class should support [print_instance] method.
///
/// The [print_instance] method supports a more flexible approach to streaming
/// objects than basic `operator<<(...)`. For instance, allowing nested structures
/// to be streamed as nicely formatted output or as dense one-line output.
///
/// The C++ signature for the function is:
/// ```
/// void print_instance(st::ostream &out, Printer_descriptor & printer_descriptor);
/// ```
///
/// Most decisions on the format of the printed instance is dictated by the
/// [Printer_descriptor] passed in. However, sometimes you just want a specific look
/// to the output of a class, regardless of the desire of the highest frames
/// original request. For example, if you might want a
///
/// ```C++
/// struct Point {
///   int x;
///   int y;
/// };
/// ```
///
/// to always be printed as `Point(0,0)`.
///
/// Instances of [PrinterSupport] decorate a class and are used to modify how the
/// [print_instance] is generated. The flags in this class are not initialized, so
/// if they are set either way, the generated [print_instance] will honor these and
/// not even attempt to support a more generalized formatting.
class PrinterSupport {
  /// If present open the output with the name of type being printed
  String typeDisplayName;

  /// If set requests that the member names be shown along with member values
  bool printMemberNames;

  /// If set supports the max bytes feature
  bool supportsMaxBytes;

  // custom <class PrinterSupport>

  PrinterSupport(
      this.typeDisplayName, this.printMemberNames, this.supportsMaxBytes);

  // end <class PrinterSupport>

}

/// Given a class, provides [print_instance] support for that and its *children*
/// recursively.
class PrinterSupportProvider {
  /// Class for which the [print_instance] applies
  Class get classType => _classType;
  PrinterSupport get printerSupport => _printerSupport;

  // custom <class PrinterSupportProvider>

  get className => classType.className;
  get members => classType.members;

  PrinterSupportProvider(this._classType, this._printerSupport) {
    _logger.info('Adding printer support to ${classType.className}');

    bool includeClassName = _printerSupport.typeDisplayName != null;
    bool includeMemberNames = _printerSupport.printMemberNames != false;

    final publicCodeBlock = classType.getCodeBlock(clsPublic);
    final privateCodeBlock = classType.getCodeBlock(clsPrivate);

    publicCodeBlock.snippets.add(brCompact([
      '''
friend inline std::ostream& print_instance(std::ostream& out, ${className} const& item, ebisu::utils::streamers::Printer_descriptor & printer_descriptor) {
  using namespace ebisu::utils::streamers;
  Printer_spec const& spec = printer_descriptor.printer_spec;

  printer_descriptor.printer_state.frame++;

  std::string indent;
  if(spec.nested_indent) {
    indent = std::string(2 * printer_descriptor.printer_state.frame, ' ');
  }

  if(spec.name_types) {
    out << "<${className}>\\n";
  }

  if(spec.name_members) {
    item.print_members_named(out, indent, printer_descriptor);
  } else {
    item.print_members_anonymous(out, indent, printer_descriptor);
  }

  printer_descriptor.printer_state.frame--;

  if(printer_descriptor.printer_state.frame == 0) {
    out << spec.final_separator;
  }

  return out;
}
'''
    ]));

    privateCodeBlock.snippets.add(brCompact([
      '''
std::ostream& print_members_named(std::ostream& out, std::string const& indent, ebisu::utils::streamers::Printer_descriptor & printer_descriptor) const {
  using namespace ebisu::utils::streamers;
  Printer_spec const& spec = printer_descriptor.printer_spec;
${indentBlock(brCompact(members.map(_namedMemberOut).join('out << spec.member_separator;')))}
  return out;
}

std::ostream& print_members_anonymous(std::ostream& out, std::string const& indent, ebisu::utils::streamers::Printer_descriptor & printer_descriptor) const {
  using namespace ebisu::utils::streamers;
  Printer_spec const& spec = printer_descriptor.printer_spec;
${indentBlock(brCompact(members.map(_anonymousMemberOut).join('out << spec.member_separator;')))}
  return out;
}
'''
    ]));
  }

  _namedMemberOut(Member m) => brCompact([
        'out << indent << "${m.name}" << spec.name_value_separator;',
        _memberValueOut(m),
      ]);

  _anonymousMemberOut(Member m) => brCompact([
    _memberValueOut(m),
  ]);

  _memberValueOut(Member m) =>
    'print_instance(out, ${m.vname}, printer_descriptor);';

  // end <class PrinterSupportProvider>

  Class _classType;
  PrinterSupport _printerSupport;
}

// custom <part printer_support>

PrinterSupport printerSupport(
        [String typeDisplayName,
        bool printMemberNames,
        bool supportsMaxBytes]) =>
    new PrinterSupport(typeDisplayName, printMemberNames, supportsMaxBytes);

// end <part printer_support>
