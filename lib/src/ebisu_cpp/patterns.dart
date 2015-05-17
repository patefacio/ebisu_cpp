part of ebisu_cpp.ebisu_cpp;

/// Provides support for generating functions to dispach on a set of one or more
/// elements.
///
/// Covers things like switch, if-else-if, jump tables.
abstract class EnumeratedDispatcher {

  /// Set of valid values *all of same type* to index on
  List<dynamic> get enumeration => _enumeration;
  /// C++ expression suitable for a switch or variable assignment,
  /// representing the enumerated value
  String enumerateAccessor;
  /// Functor allowing client to dictate how the dispatch may be called on the
  /// enumerant.
  Dispatcher dispatchFunction;
  /// Type associated with the enumerated values. That type may be *string* or some
  /// form of int.
  String type;

  // custom <class EnumeratedDispatcher>

  EnumeratedDispatcher(enumeration_, this.dispatchFunction,
      [this.enumerateAccessor = 'discriminator']) {
    enumeration = enumeration_;
  }

  /// Sets the values used to discriminate the dispatch
  ///
  /// Attempts to infer a type
  set enumeration(List<dynamic> enumerates) {
    _enumeration = new List.from(enumerates);
    if (type == null) {
      final inferredTypes =
          new Set.from(enumeration.map((e) => inferCppType(e)));
      if (inferredTypes.length > 1) {
        throw 'EnumeratedDispatcher enumeration entries must be same type:'
            'found ${inferredTypes.join(", ")}';
      } else if (inferredTypes.length == 1) {
        type = inferredTypes.first;
        _logger.info('Inferred enumerate type $type');
      }
    }
  }

  /// Generate a suitable block that uses the enumeration to dispatch.
  ///
  /// The mechanism for dispatching is not specified, but rather user provided
  /// via [dispatchFunction]
  String get dispatchBlock;

  // end <class EnumeratedDispatcher>

  List<dynamic> _enumeration = [];
}

/// Dispatcher implemented with *switch* statement
class SwitchEnumeratedDispatcher extends EnumeratedDispatcher {

  // custom <class SwitchEnumeratedDispatcher>

  SwitchEnumeratedDispatcher(enumeration, dispatchFunction, [enumerateAccessor = 'discriminator'])
    : super(enumeration, dispatchFunction, enumerateAccessor);

  String get dispatchBlock {
    if (type.contains('string')) {
      throw 'Switch requires an integer type, not string';
    }

    return brCompact([
      'switch($enumerateAccessor) {',
      _enumeration.map((var e) => '''
case $e: {
  ${dispatchFunction(this, e)}
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
  CompareExpression compareExpression = (a, b) => "$a == $b";

  // custom <class IfElseIfEnumeratedDispatcher>

  IfElseIfEnumeratedDispatcher(enumeration, dispatchFunction)
      : super(enumeration, dispatchFunction);

  String get dispatchBlock {
    return brCompact([
      'auto discriminator_ { $enumerateAccessor };',
      'if(${compareExpression(enumeration.first, 'discriminator_')}) {',
      indentBlock(dispatchFunction(this, enumeration.first)),
      _enumeration.skip(1).map((var e) => '''
} else if(${compareExpression(e, "discriminator_")}) {
${indentBlock(dispatchFunction(this, e))}
}
'''),
    ]);
  }

  // end <class IfElseIfEnumeratedDispatcher>

}

/// Dipatcher implemented with *if-else-if* statements visiting character by
/// character - *only* valid for strings
class CharBinaryEnumeratedDispatcher extends EnumeratedDispatcher {

  // custom <class CharBinaryEnumeratedDispatcher>
  // end <class CharBinaryEnumeratedDispatcher>

}

// custom <part patterns>

/// Given a dispatcher and enumerant, returns suitable dispatch function
/// invocation on the enumerant
typedef String Dispatcher(EnumeratedDispatcher dispatcher, var enumerant);

/// Given the [enumerateAccessor] expression (ie the item being tested) and one
/// of the enumerants - returns a comparison expression suitable for if statement
typedef String CompareExpression(String enumerateAccessor, var enumerant);

// end <part patterns>
