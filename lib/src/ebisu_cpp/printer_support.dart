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

  // custom <class PrinterSupport>

  PrinterSupport(this.typeDisplayName, this.printMemberNames);

  // end <class PrinterSupport>

}

/// The C++ instances for the [print_instance] methods of a class.
class PrintInstanceMethods {
  /// Class for which the [print_instance] applies
  Class get classType => _classType;
  PrinterSupport get printerSupport => _printerSupport;

  /// The print method contents
  String get printInstance => _printInstance;

  // custom <class PrintInstanceMethods>
  // end <class PrintInstanceMethods>

  Class _classType;
  PrinterSupport _printerSupport;
  String _printInstance;
}

/// Given a class, provides [print_instance] support for that and its *children*
/// recursively.
class PrinterSupportProvider {
  /// Class for which the [print_instance] applies
  Class get classType => _classType;
  PrinterSupport get printerSupport => _printerSupport;
  PrintInstanceMethods get printInstanceMethods => _printInstanceMethods;

  // custom <class PrinterSupportProvider>

  PrinterSupportProvider(this._classType, this._printerSupport) {
    _printInstanceMethods = new Printinstancemethods(_classType);
  }

  // end <class PrinterSupportProvider>

  Class _classType;
  PrinterSupport _printerSupport;
  PrintInstanceMethods _printInstanceMethods;
}

// custom <part printer_support>

PrinterSupport printerSupport(
        [String typeDisplayName, bool printMemberNames]) =>
    new PrinterSupport(typeDisplayName, printMemberNames);

// end <part printer_support>
