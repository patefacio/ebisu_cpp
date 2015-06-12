part of ebisu_cpp.cookbook;

enum DispatchCppType {
  dctStdString,
  dctCptr,
  dctStringLiteral,
  dctInteger,
  dctByteArray
}
/// Convenient access to DispatchCppType.dctStdString with *dctStdString* see [DispatchCppType].
///
const DispatchCppType dctStdString = DispatchCppType.dctStdString;

/// Convenient access to DispatchCppType.dctCptr with *dctCptr* see [DispatchCppType].
///
const DispatchCppType dctCptr = DispatchCppType.dctCptr;

/// Convenient access to DispatchCppType.dctStringLiteral with *dctStringLiteral* see [DispatchCppType].
///
const DispatchCppType dctStringLiteral = DispatchCppType.dctStringLiteral;

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
/// discriminate on. Suppose the elements of interest are:
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
  /// Functor allowing client to dictate the dispatch on the
  /// enumerant. *Note* client must supply trailing semicolon if needed.
  Dispatcher dispatcher;
  /// Type associated with the enumerated values. That type may be *string*
  /// or some form of int.
  String type;
  /// Type of the enumerator entries
  DispatchCppType enumeratorType;
  /// Type of the discriminator
  DispatchCppType discriminatorType;
  /// Functor allowing client to dictate the dispatch of an unidentified
  /// enumerator. *Note* client must supply trailing semicolon if needed.
  ErrorDispatcher errorDispatcher;
  /// For [dctStdString] type enumerations.
  ///
  /// If true does not declare separate *descriminator_* local variable, but
  /// rather uses the enumerator value directly. Since the enumerator might
  /// be some function call (e.g. String  const& get_value()), the defulat behavior
  /// is to assign to local:
  ///
  ///     std::string const& discriminator_ { $enumerator };
  ///
  /// Setting this to true bypasses that and uses $enumerator directly.
  bool usesEnumeratorDirectly = false;

  // custom <class EnumeratedDispatcher>

  EnumeratedDispatcher(enumeration_, this.dispatcher,
      {this.errorDispatcher, this.enumerator: 'discriminator'}) {
    enumeration = enumeration_;
    if (errorDispatcher == null) {
      errorDispatcher =
          (_) => 'assert(!"Enumerator not in {${enumeration.join(", ")}}");';
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
  }

  get discriminatorCppType => cppType(discriminatorType);
  get enumeratorCppType => cppType(enumeratorType);

  /// Sets the values used to discriminate the dispatch
  ///
  /// Attempts to infer a type
  set enumeration(Iterable<dynamic> enumerates) {
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

  get cppDiscriminatorLength {
    final dct = discriminatorCppType;
    return dct == 'std::string'
        ? 'discriminator_.length()'
        : dct == 'char const*'
            ? 'strlen(discriminator_)'
            : throw 'Can not get length of discriminator_';
  }

  get _discriminatorVar =>
      usesEnumeratorDirectly ? enumerator : 'discriminator_';

  get _discriminatorDecl =>
    usesEnumeratorDirectly? null :
    '$discriminatorCppType const& discriminator_ { $enumerator };';

  get _discriminatorLengthDecl =>
    hasNoLengthChecks? null :
    'size_t discriminator_length_ { $cppDiscriminatorLength };';

  // end <class EnumeratedDispatcher>

  List<dynamic> _enumeration = [];
}

/// Dispatcher implemented with *switch* statement
class SwitchDispatcher extends EnumeratedDispatcher {

  // custom <class SwitchDispatcher>

  SwitchDispatcher(enumeration, dispatcher, {enumerator: 'discriminator'})
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
}
'''),
      '''
default: ${indentBlock(errorDispatcher(this))}
      }
'''
    ]);
  }

  // end <class SwitchDispatcher>

}

/// Dipatcher implemented with *if-else-if* statements
class IfElseIfDispatcher extends EnumeratedDispatcher {
  CompareExpression compareExpression;

  // custom <class IfElseIfDispatcher>

  _isCharPtr(t) => t == dctCptr || t == dctStringLiteral;
  _asCharPtr(t, v) => t == dctCptr
      ? v
      : t == dctStringLiteral
          ? doubleQuote(v)
          : t == dctStdString
              ? '${v}.c_str()'
              : throw 'Not convertion from $t to char*';
  _eAsCharPtr(e) => _asCharPtr(enumeratorType, e);
  _dAsCharPtr(d) => _asCharPtr(discriminatorType, d);

  _compareWithTypes(
      DispatchCppType enumeratorType, e, DispatchCppType discriminatorType, d) {
    if (enumeratorType == dctStdString || discriminatorType == dctStdString) {
      return (enumeratorType == dctStdString) ? '$e == $d' : '$d == $e}';
    } else if (_isCharPtr(enumeratorType) && _isCharPtr(discriminatorType)) {
      return 'strcmp(${_eAsCharPtr(e)}, ${_dAsCharPtr(d)}) == 0';
    } else {
      return '$e == $d';
    }
  }

  _compareEnumeratorToDiscriminator(a, b) => compareExpression != null
      ? compareExpression(a, b)
      : _compareWithTypes(enumeratorType, a, discriminatorType, b);

  IfElseIfDispatcher(enumeration, dispatcher, {enumerator: 'discriminator'})
      : super(enumeration, dispatcher, enumerator: enumerator);

  _dispatchCall(e) => indentBlock(dispatcher(this, e));

  String get dispatchBlock {
    return brCompact([
      _discriminatorDecl,
      'if(${_compareEnumeratorToDiscriminator(enumeration.first, _discriminatorVar)}) {',
      _dispatchCall(enumeration.first),
      _enumeration.skip(1).map((var e) => '''
} else if(${_compareEnumeratorToDiscriminator(e, _discriminatorVar)}) {
${_dispatchCall(e)}
'''),
      '''
} else {
${indentBlock(errorDispatcher(this))}
}'''
    ]);
  }

  // end <class IfElseIfDispatcher>

}

/// A node in a tree-structure.
///
/// The tree-structure represents a set of strings where a traversal of
/// the tree can visit all characters in all strings. Any node that has
/// [isLeaf] set indicates the path from root to said node is a complete
/// string from the set.
///
/// For example:
///
///     final strings = [
///       '125',
///       '32',
///       '1258',
///     ];
///
///     final tree = new CharNode.from(null, 'root', strings, false);
///     print(tree);
///
/// Prints:
///
///     root in null
///     isLeaf:false
///       1 in 1
///       isLeaf:false
///         2 in 12
///         isLeaf:false
///           5 in 125
///           isLeaf:true
///             8 in 1258
///             isLeaf:true
///       3 in 3
///       isLeaf:false
///         2 in 32
///         isLeaf:true
///
/// The tree shrunk by calling flatten:
///
///     tree.flatten();
///     print(tree);
///
///     root in null
///     isLeaf:false
///       12 in 12
///       isLeaf:false
///         5 in 125
///         isLeaf:true
///           8 in 1258
///           isLeaf:true
///       32 in 32
///       isLeaf:true
class CharNode {
  String char;
  bool isLeaf;
  CharNode parent;
  List<CharNode> children = [];

  // custom <class CharNode>

  CharNode.from(
      this.parent, this.char, Iterable<String> literals, this.isLeaf) {
    final literalsSorted = new List.from(literals);
    literalsSorted.sort();

    Map headToTail = {};
    for (String literal in literalsSorted) {
      if (literal.isEmpty) continue;

      final head = literal.substring(0, 1);
      var tail = literal.substring(1);

      headToTail.putIfAbsent(head, () => []).add(tail);
    }

    headToTail.forEach(
        (k, v) => children.add(new CharNode.from(this, k, v, v.first == '')));
  }

  get fullName => _fullName();

  _fullName([name = '']) =>
      parent == null ? '' : combine([parent._fullName(name), char], '');

  /// Reduce unnecessary character by character checks when *strncmp* can be
  /// done on a larger string of characters.
  flatten() {
    children.forEach((c) => c.flatten());

    ////////////////////////////////////////////////////////////////////////////
    // If we have just one child which is not a leaf node, combine the child's
    // string with this's and make his children our children. The purpose here
    // is to avoid a character-by-character check on a long string that has no
    // other strings similar to it.
    if (parent != null && children.length == 1 && !isLeaf) {
      _adoptChild(children.first);
    }

    return this;
  }

  _adoptChild(onlyChild) {
    // Combine this name with the child's name
    char += onlyChild.char;
    assert(!isLeaf);
    // this was not a leaf. After combining if our only child was a leaf then we
    // become one
    isLeaf = onlyChild.isLeaf;
    // Replace our children with our children's children
    children = new List.from(onlyChild.children);
    // We are now the parent of our children
    children.forEach((c) => c.parent = this);
  }

  get length => char.length;
  get asCpp => length == 1 ? "'$char'" : doubleQuote(char);

  toString() => brCompact([
    '$char in $fullName',
    'isLeaf:$isLeaf',
    indentBlock(brCompact(children))
  ]);

  // end <class CharNode>

}

/// Dipatcher implemented with *if-else-if* statements visiting character by
/// character - *only* valid for strings as discriminators.
class CharBinaryDispatcher extends EnumeratedDispatcher {

  /// Bypasses normal length checks.
  ///
  /// Applicable when caller all enumerants of same length and caller
  /// ensures dispatch is as large as that length
  bool hasNoLengthChecks = false;

  // custom <class CharBinaryDispatcher>

  CharBinaryDispatcher(enumeration, dispatcher, {enumerator: 'discriminator'})
      : super(enumeration, dispatcher, enumerator: enumerator);

  String get dispatchBlock {
    if (enumeratorType != dctStringLiteral) {
      throw 'CharBinaryDispatcher requires literal enumeration: not $enumeratorType';
    }

    final enumeratorsSorted = new List.from(enumeration);
    enumeratorsSorted.sort();

    final root = new CharNode.from(null, 'root', enumeratorsSorted, false);
    root.flatten();
    _logger.fine(root);

    return (brCompact([
      _discriminatorDecl,
      _discriminatorLengthDecl,
      _sizeCheck(0),
      root.children.map((c) => visitNodes(c))
    ]));
  }

  _sizeCheck(index) => hasNoLengthChecks? null :
      'if(${index + 1} > discriminator_length_) ${errorDispatcher(this)}';

  _cmpNode(node, index) => node.length == 1
      ? 'if(${node.asCpp} == discriminator_[$index]) {'
      : 'if(strncmp(${node.asCpp}, &discriminator_[$index], ${node.length}) == 0) {';

  _hitNode(node) => '''

// Hit on "${node.fullName}"
${dispatcher(this, node.fullName)}
''';

  visitNodes(CharNode node, [int charIndex = 0]) => brCompact([
    combine([
      _cmpNode(node, charIndex),
      node.isLeaf
          ? br([
            indentBlock(brCompact([
              hasNoLengthChecks? _hitNode(node) :
              '''

// Leaf node: potential hit on "${node.fullName}"
if(${node.fullName.length} == discriminator_length_) {
${indentBlock(_hitNode(node))}
}
'''])),
          ])
          : null,
    ]),
    indentBlock(br([
      node.children.isNotEmpty ? _sizeCheck(charIndex + 1) : null,
      node.children.map((c) => visitNodes(c, charIndex + node.length))
    ])),
    hasNoLengthChecks? null : indentBlock(errorDispatcher(this)),
    '}',
  ]);

  // end <class CharBinaryDispatcher>

}

/// Dipatcher that first partitions the discriminator by length then implemented
/// with *if-else-if* statements visiting character by character - *only* valid for
/// strings as discriminators.
class StrlenBinaryDispatcher extends EnumeratedDispatcher {

  /// Map the length of the enumerant to the set of enumerants of same length
  Map get lengthMap => _lengthMap;

  // custom <class StrlenBinaryDispatcher>

  StrlenBinaryDispatcher(enumeration, dispatcher, {enumerator: 'discriminator'})
      : super(enumeration, dispatcher, enumerator: enumerator) {
    _lengthMap = enumeration.fold(
        {}, (prev, elm) => prev..putIfAbsent(elm.length, () => []).add(elm));
  }

  String get dispatchBlock {
    return brCompact([
      '''
${cppType(discriminatorType)} const& discriminator_ { $enumerator };
size_t discriminator_length_ { $cppDiscriminatorLength };
switch(discriminator_length_) {
${brCompact(_lengthMap.keys.map((length) => _innerCase(length)))}
default: ${errorDispatcher(this)}
}
'''
    ]);
  }

  _innerSwitch(values) {
    return (new CharBinaryDispatcher(values, dispatcher, enumerator: enumerator)
      ..usesEnumeratorDirectly = true
      ..hasNoLengthChecks = true
      ..enumeratorType = dctStringLiteral).dispatchBlock;
  }

  _innerCase(length) => '''
case $length: {
${brCompact(_innerSwitch(_lengthMap[length]))}
  ${errorDispatcher(this)}
  break;
}
''';

  // end <class StrlenBinaryDispatcher>

  Map _lengthMap = {};
}

// custom <part dispatchers>

/// Given a dispatcher and enumerator, returns suitable dispatch function
/// invocation on the enumerator
typedef String Dispatcher(EnumeratedDispatcher dispatcher, var enumerator);

/// Returns text suitable for handling the case where the discriminator could
/// not be found
typedef String ErrorDispatcher(EnumeratedDispatcher dispatcher);

/// Given the [enumerator] expression (ie the item being tested) and one of the
/// testEnumerators - returns a comparison expression suitable for if statement
typedef String CompareExpression(String enumerator, var testEnumerator);

// end <part dispatchers>
