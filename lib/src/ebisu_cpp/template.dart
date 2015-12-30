/// Classes to facilitate generating C++ template code
part of ebisu_cpp.ebisu_cpp;

enum TemplateParmType {
  /// Indicates the template parameter names a type
  type,

  /// Indicates the template parameter indicates a non-type
  /// (e.g. *MAX_SIZE = 10* - a constant literal)
  nonType
}

abstract class TemplateParm extends CppEntity {
  // custom <class TemplateParm>
  TemplateParm(id) : super(id);
  Iterable<Entity> get children => [];
  // end <class TemplateParm>

}

/// Unparsed text template parm
class RawTemplateParm extends TemplateParm {
  String typeId;

  /// Text for the template parm
  String text;

  // custom <class RawTemplateParm>

  RawTemplateParm(id, this.text) : super(id);

  toString() => text;

  // end <class RawTemplateParm>

}

class TypeTemplateParm extends TemplateParm {
  String defaultType;

  // custom <class TypeTemplateParm>

  TypeTemplateParm(id, this.defaultType) : super(id);

  toString() => defaultType != null
      ? 'typename $typename = $defaultType'
      : 'typename $typename';

  get typename => id.shout;

  // end <class TypeTemplateParm>

}

class NonTypeTemplateParm extends TemplateParm {
  /// Type of the parm
  String type;
  String defaultValue;

  // custom <class NonTypeTemplateParm>

  NonTypeTemplateParm(id, this.type, [this.defaultValue]) : super(id);

  toString() => defaultValue != null
      ? '$type $valueVariable = $defaultValue'
      : '$type $valueVariable';

  get valueVariable => id.shout;

  // end <class NonTypeTemplateParm>

}

class TemplateGrammar extends GrammarParser {
  // custom <class TemplateGrammar>

  TemplateGrammar() : super(const TemplateGrammarDefinition());

  // end <class TemplateGrammar>

}

class TemplateGrammarDefinition extends GrammarDefinition {
  // custom <class TemplateGrammarDefinition>

  const TemplateGrammarDefinition();

  get prod => super.ref;

  start() => prod(prodTemplateDecl).end();

  Parser token(input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Function) {
      input = prod(input);
    }
    if (input is! Parser && input is TrimmingParser) {
      throw new StateError('Invalid token parser: $input');
    }
    return input.token().trim(prod(prodHidden));
  }

  prodTemplateDecl() => prod(token, 'template') & prod(prodTemplateParmList);

  prodTemplateParm() => prod(token, 'typename') & prod(prodIdentifier);

  prodTemplateParmList() =>
      prod(token, char('<')) &
      prod(prodTemplateParms).optional() &
      prod(token, char('>'));

  prodTemplateParms() => prod(prodTemplateParm)
      .separatedBy(prod(token, char(',')), includeSeparators: false);

  prodNewline() => pattern('\n\r');

  prodHidden() => prod(prodHiddenStuff).plus();

  prodHiddenStuff() =>
      prod(prodWhitespace) |
      prod(prodSingleLineComment) |
      prod(prodMultiLineComment);

  prodWhitespace() => whitespace();

  prodSingleLineComment() =>
      string('//') &
      prod(prodNewline).neg().star() &
      prod(prodNewline).optional();

  prodMultiLineComment() =>
      string('/*') &
      (prod(prodMultiLineComment) | string('*/').neg()).star() &
      string('*/');

  prodIdentifier() => letter() & word().star();

  // end <class TemplateGrammarDefinition>

}

class TemplateParser extends GrammarParser {
  // custom <class TemplateParser>

  TemplateParser() : super(const TemplateParserDefinition());

  // end <class TemplateParser>

}

class TemplateParserDefinition extends TemplateGrammarDefinition {
  // custom <class TemplateParserDefinition>

  const TemplateParserDefinition();

  prodTemplateDecl() => super.prodTemplateDecl().map((e) => null);

  // end <class TemplateParserDefinition>

}

/// Represents a template declaration comprized of a list of [decls]
class Template extends CppEntity {
  List<TemplateParm> parms;

  // custom <class Template>

  Iterable<Entity> get children => parms;

  Template(id, Iterable<String> decls_)
      : super(id),
        parms = decls_.map((d) => templateParm(d)).toList();

  addAll(Iterable decls) => parms.addAll(decls.map((d) => templateParm(d)));

  String get decl => '''
template< ${parms.join(',\n          ')} >''';

  toString() => decl;

  // end <class Template>

}

/// Specifies a set of specialization template parameters
class TemplateSpecialization {
  List<String> parms;

  // custom <class TemplateSpecialization>
  // end <class TemplateSpecialization>

}

// custom <part template>

final _namedTemplateTypeRe = new RegExp(r'^\s*typename\s+(\w+)\s*$');
final _assignedNamedTypeParmRe =
    new RegExp(r'^\s*typename\s+(\w+)\s*=\s*([\w:]+)\s*$');
final _templatizedTypeParmRe =
    new RegExp(r'^\s*template\s+<([^>]+)>\s+class\s+(\w+)\s*$');
final _namedTemplateValueRe = new RegExp(r'^\s*(\w+)\s+(\w+)\s*$');
final _assignedNamedTemplateValueRe =
    new RegExp(r'^\s*([\w:]+)\s+(\w+)\s*=\s*(\w+)\s*$');

Template template([Iterable<String> decls]) => new Template('id', decls);

_makeTemplatepParm(tparm) {
  if (tparm is RawTemplateParm) return tparm;
  var match;
  if ((match = _assignedNamedTypeParmRe.firstMatch(tparm)) != null) {
    final typename = match.group(1);
    final defaultType = match.group(2);
    final id = makeId(typename);
    _logger.info(
        'making initialized TypeTemplateParm $id from $tparm with $defaultType');
    return new TypeTemplateParm(id, defaultType);
  } else if ((match = _namedTemplateTypeRe.firstMatch(tparm)) != null) {
    final typename = match.group(1);
    final id = makeId(typename);
    _logger.info('making simple TypeTemplateParm $id from $tparm');
    return new TypeTemplateParm(id, null);
  } else if ((match = _templatizedTypeParmRe.firstMatch(tparm)) != null) {
    final typename = match.group(2);
    final id = makeId(typename);
    _logger.info('using RawTemplateParm for templatized type parm $tparm');
    return new RawTemplateParm(id, tparm);
  } else if ((match = _assignedNamedTemplateValueRe.firstMatch(tparm)) !=
      null) {
    final typename = match.group(1);
    final varname = match.group(2);
    final defaultValue = match.group(3);
    final id = makeId(varname);
    _logger.info(
        'making defaulted NonTypeTemplateParm $id from $tparm with $defaultValue');
    return new NonTypeTemplateParm(id, typename, defaultValue);
  } else if ((match = _namedTemplateValueRe.firstMatch(tparm)) != null) {
    final typename = match.group(1);
    final varname = match.group(2);
    final id = makeId(varname);
    _logger.info('making NonTypeTemplateParm $id from $tparm');
    return new NonTypeTemplateParm(id, typename);
  } else {
    _logger.info('using RawTemplateParm for templatized type parm $tparm');
    return new RawTemplateParm('unknown', tparm);
  }
}

TemplateParm templateParm(tparm) => tparm is TemplateParm
    ? tparm
    : tparm is String
        ? _makeTemplatepParm(tparm)
        : throw 'templateParm(..) takes TemplateParm or String';

TemplateParm rawTemplateParm(id, tparm) => new RawTemplateParm(id, tparm);

// end <part template>
