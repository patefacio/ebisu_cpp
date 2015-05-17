part of ebisu_cpp.cookbook;

enum DispatchCppType { dctStdString, dctCptr, dctInteger, dctByteArray }
/// Convenient access to DispatchCppType.dctStdString with *dctStdString* see [DispatchCppType].
///
const DispatchCppType dctStdString = DispatchCppType.dctStdString;

/// Convenient access to DispatchCppType.dctCptr with *dctCptr* see [DispatchCppType].
///
const DispatchCppType dctCptr = DispatchCppType.dctCptr;

/// Convenient access to DispatchCppType.dctInteger with *dctInteger* see [DispatchCppType].
///
const DispatchCppType dctInteger = DispatchCppType.dctInteger;

/// Convenient access to DispatchCppType.dctByteArray with *dctByteArray* see [DispatchCppType].
///
const DispatchCppType dctByteArray = DispatchCppType.dctByteArray;

/// Provides support for generating functions to dispach on a set of one or more
/// elements.
///
/// Covers things like switch, if-else-if, jump tables in a predefined way. A common
/// task is: given input data categorized by some type enumeration, dispatch a
/// function to handle associated data.
///
/// For example, you might have an XML Element that is one of a predefined set of
/// known element types. The XML Element has a *tag* which you can use to
/// descriminate on. Suppose the elements of interest are:
///
///   - <typeDeclaration>
///
///   - <struct>
///
///   - <member>
///
///   - <function>
///
/// Often you will need code that effectively does a switch on a *tag* associated
/// with the data and passes that data to its proper handler.
abstract class EnumeratedDispatcher {

  /// Set of valid values *all of same type* to index on.
  ///
  /// For example, to discriminate on a set of named tags:
  ///
  ///   - <typeDeclaration>
  ///
  ///   - <struct>
  ///
  ///   - <member>
  ///
  ///   - <function>
  ///
  /// use:
  ///
  ///     ..enumeration = ['typeDeclaration', 'struct', 'member', 'function']
  List<dynamic> get enumeration => _enumeration;
  /// C++ expression suitable for a switch or variable assignment,
  /// representing the enumerated value
  String enumerator;
  /// Functor allowing client to dictate the dispatch on the enumerant.
  Dispatcher dispatcher;
  /// Type associated with the enumerated values. That type may be *string* or some
  /// form of int.
  String type;
  /// Type of the enumerator entries
  DispatchCppType enumeratorType;
  /// Type of the discriminator
  DispatchCppType discriminatorType;
  /// Functor allowing client to dictate the dispatch of an unidentified
  /// enumerator.
  Dispatcher errorDispatcher;
  String usesMemcmp;

  // custom <class EnumeratedDispatcher>

  EnumeratedDispatcher(enumeration_, this.dispatcher,
      {this.errorDispatcher, this.enumerator: 'discriminator'}) {
    enumeration = enumeration_;
    if (errorDispatcher == null) {
      errorDispatcher = (_, enumerator) =>
          'assert(!"Enumerator not in {${enumeration.join(", ")}}");';
    }
  }

  DispatchCppType _inferredType(e) {
    final guess = inferCppType(e);
    switch (guess) {
      case 'std::string':
        return dctStdString;
      case 'int':
        return dctInteger;
      default:
        return dctCptr;
    }
  }

  cppType(DispatchCppType dct) {
    switch (dct) {
      case dctStdString:
        return 'std::string';
      case dctInteger:
        return 'int';
      default:
        return 'char const*';
    }
    ;
  }

  get discriminatorCppType => cppType(discriminatorType);
  get enumeratorCppType => cppType(enumeratorType);

  /// Sets the values used to discriminate the dispatch
  ///
  /// Attempts to infer a type
  set enumeration(List<dynamic> enumerates) {
    _enumeration = new List.from(enumerates);
    if (enumeratorType == null) {
      final inferreds = new Set.from(enumeration.map((e) => _inferredType(e)));
      if (inferreds.isEmpty) return;
      if (inferreds.length > 1) {
        throw 'All types in enumeration must be the same: $enumeration';
      }
      enumeratorType = inferreds.first;
      _logger.info('Inferred enumerate type $enumeratorType');
      if (discriminatorType == null) {
        discriminatorType = enumeratorType;
      }
    }
  }

  /// Generate a suitable block that uses the enumeration to dispatch.
  ///
  /// The mechanism for dispatching is not specified, but rather user provided
  /// via [dispatcher]
  String get dispatchBlock;

  // end <class EnumeratedDispatcher>

  List<dynamic> _enumeration = [];
}

/// Dispatcher implemented with *switch* statement
class SwitchEnumeratedDispatcher extends EnumeratedDispatcher {

  // custom <class SwitchEnumeratedDispatcher>

  SwitchEnumeratedDispatcher(enumeration, dispatcher,
      {enumerator: 'discriminator'})
      : super(enumeration, dispatcher, enumerator: enumerator);

  String get dispatchBlock {
    if (discriminatorType != dctInteger) {
      throw 'Switch requires an integer type, not $discriminatorType';
    }

    return brCompact([
      'switch($enumerator) {',
      _enumeration.map((var e) => '''
case $e: {
  ${dispatcher(this, e)}
  break;
}
'''),
      '}'
    ]);
  }

  // end <class SwitchEnumeratedDispatcher>

}

/// Dipatcher implemented with *if-else-if* statements
class IfElseIfEnumeratedDispatcher extends EnumeratedDispatcher {
  CompareExpression compareExpression;

  // custom <class IfElseIfEnumeratedDispatcher>

  _compareWithTypes(
      DispatchCppType enumeratorType, e, DispatchCppType discriminatorType, d) {
    if (enumeratorType == dctStdString || discriminatorType == dctStdString) {
      return (enumeratorType == dctStdString) ? '$e == $d' : '$d == $e';
    } else if (enumeratorType == dctCptr && discriminatorType == dctCptr) {
      return 'strcmp($e, $d)';
    } else {
      return '$e == $d';
    }
  }

  _compareEnumeratorToDiscriminator(a, b) => compareExpression != null
      ? compareExpression(a, b)
      : _compareWithTypes(enumeratorType, a, discriminatorType, b);

  IfElseIfEnumeratedDispatcher(enumeration, dispatcher,
      {enumerator: 'discriminator'})
      : super(enumeration, dispatcher, enumerator: enumerator);

  String get dispatchBlock {
    return brCompact([
      '$discriminatorCppType const& discriminator_ { $enumerator };',
      'if(${_compareEnumeratorToDiscriminator(enumeration.first, 'discriminator_')}) {',
      indentBlock(dispatcher(this, enumeration.first)),
      _enumeration.skip(1).map((var e) => '''
} else if(${_compareEnumeratorToDiscriminator(e, "discriminator_")}) {
${indentBlock(dispatcher(this, e))}
'''),
      '''
} else {
${indentBlock(errorDispatcher(this, "discriminator_"))}
}'''
    ]);
  }

  // end <class IfElseIfEnumeratedDispatcher>

}

/// Dipatcher implemented with *if-else-if* statements visiting character by
/// character - *only* valid for strings
class CharBinaryEnumeratedDispatcher extends EnumeratedDispatcher {

  // custom <class CharBinaryEnumeratedDispatcher>

  CharBinaryEnumeratedDispatcher(enumeration, dispatcher)
      : super(enumeration, dispatcher, {enumerator: 'discriminator'});

  String get dispatchBlock {
    return brCompact([
      'auto const& discriminator_ { $enumerator };',
      'if(${compareExpression(enumeration.first, 'discriminator_')}) {',
      indentBlock(dispatcher(this, enumeration.first)),
      _enumeration.skip(1).map((var e) => '''
} else if(${compareExpression(e, "discriminator_")}) {
${indentBlock(dispatcher(this, e))}
}
'''),
    ]);
  }

  // end <class CharBinaryEnumeratedDispatcher>

}

// custom <part dispatch>

/// Given a dispatcher and enumerator, returns suitable dispatch function
/// invocation on the enumerator
typedef String Dispatcher(EnumeratedDispatcher dispatcher, var enumerator);

/// Given the [enumerator] expression (ie the item being tested) and one of the
/// testEnumerators - returns a comparison expression suitable for if statement
typedef String CompareExpression(String enumerator, var testEnumerator);

// end <part dispatch>
