part of ebisu_cpp.ebisu_cpp;

class Switch {
  Switch(this.switchValue, cases, this.onCase, [this.onDefault, this.isChar])
      : cases = cases ?? [] {
    // custom <Switch>

    if (isChar == null) isChar = false;

    if (cases.first is String) {
      if (!cases.every((c) => c is String && c.length == 1)) {
        throw 'Switch with strings must have chars only: $cases';
      }
    }

    // end <Switch>
  }

  /// Text repesenting the value to be switched on
  String switchValue;
  List<int> cases = [];

  /// Function for providing a block for *case*
  CaseFunctor onCase;

  /// Block of text for the default case.
  ///
  /// Break will be provided. If default case is a one or more statements
  /// client must provide semicolons.
  String onDefault;

  /// If cases should be interpreted as char
  bool isChar;

  // custom <class Switch>

  _caseValue(c) => isChar ? c.substring(0, 1).codeUnits.first : c;

  _wrapChar(c) => isChar ? "'$c'" : c;

  get definition {
    final defaultCaseText = (this.onDefault == null)
        ? 'assert(!"value not in [${cases.map((c) => _wrapChar(c)).join(', ')}]");'
        : onDefault;

    return brCompact([
      'switch($switchValue) {',
      cases.map((c) => brCompact([
            isChar
                ? '// Following is for character (\'$c\'=${_caseValue(c)})'
                : null,
            '''
case ${_wrapChar(c)}: {
${indentBlock(onCase(c))}
  break;
}
'''
          ])),
      '''
default: {
  $defaultCaseText
  break;
}
''',
      '}'
    ]);
  }

  // end <class Switch>

}

// custom <part control_flow>

typedef String CaseFunctor(int caseValue);

switch_(String switchValue, Iterable cases, CaseFunctor caseFunctor,
        [String defaultCase, bool isChar = false]) =>
    new Switch(switchValue, cases, caseFunctor, defaultCase, isChar);

// end <part control_flow>
