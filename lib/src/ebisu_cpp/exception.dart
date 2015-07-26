/// Support for creating standard based exception hierarchies
part of ebisu_cpp.ebisu_cpp;

/// Creates a new *exception* class derived from std::exception.
class ExceptionClass extends Class {
  /// Base class for this exception class
  String baseException;

  // custom <class ExceptionClass>

  ExceptionClass(id, [this.baseException = 'std::runtime_error']) : super(id) {
    bases = [base(baseException)];
    getCodeBlock(clsPublic).snippets.add('''

/// Constructs exception object with explanatory what_arg accessible through what().
explicit ${className}( const std::string& what_arg ) : $baseException(what_arg) {
}

/// Constructs exception object with explanatory what_arg accessible through what().
explicit ${className}( const char* what_arg )  : $baseException(what_arg) {
}
''');
  }

  get includes => new Includes(['stdexcept']);

  // end <class ExceptionClass>

}

// custom <part exception>

ExceptionClass exceptionClass(id,
        [String baseException = 'std::runtime_error']) =>
    new ExceptionClass(id, baseException);

// end <part exception>
