/// Support for creating standard based exception hierarchies
part of ebisu_cpp.ebisu_cpp;

/// Creates a new *exception* class derived from std::exception.
class ExceptionClass extends Class {
  /// Base class for this exception class
  String baseException;

  /// Additional includes required for exception class
  List<String> exceptionIncludes = [];

  // custom <class ExceptionClass>

  ExceptionClass(id, [this.baseException = 'std::runtime_error']) : super(id) {
    bases = [base(baseException)..isVirtual = true];
    if(!baseException.contains('std::')) {
      throw '*baseException* of ExceptionClass must be an std:: exception';
    }
  }

  onOwnershipEstablished() {
    if(baseException != 'std::exception') {
      getCodeBlock(clsPublic).snippets.add('''

/// Constructs exception object with explanatory what_arg accessible through what().
explicit ${className}( const std::string& what_arg ) : $baseException(what_arg) {
}

/// Constructs exception object with explanatory what_arg accessible through what().
explicit ${className}( const char* what_arg )  : $baseException(what_arg) {
}
''');
    }
  }

  get includes => new Includes(exceptionIncludes)..addAll(super.includes.included);

  // end <class ExceptionClass>

}

// custom <part exception>

ExceptionClass exceptionClass(id,
        [String baseException = 'std::runtime_error']) =>
    new ExceptionClass(id, baseException)
  ..bases.add(base('boost::exception')..isVirtual = true)
  ..exceptionIncludes = ['stdexcept', 'boost/exception/exception.hpp'];

ExceptionClass boostExceptionClass(id) => new ExceptionClass(id, 'std::exception')
  ..exceptionIncludes = ['stdexcept', 'boost/exception/exception.hpp']
  ..bases.add(base('boost::exception')..isVirtual = true);

// end <part exception>
