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

  // end <class RawTemplateParm>

}

class TypeTemplateParm extends TemplateParm {
  String typeId;

  // custom <class TypeTemplateParm>

  TypeTemplateParm(id, this.typeId) : super(id);

  toString() =>
      typeId != null ? 'typename $typename = $typeId' : 'typename $typename';

  get typename => id.shout;

  // end <class TypeTemplateParm>

}

class DeclTemplateParm extends TemplateParm {
  List<String> terms;

  /// Index into the terms indicating the id
  int idIndex;

  // custom <class DeclTemplateParm>

  DeclTemplateParm(id, this.terms, this.idIndex) : super(id);

  toString() => (new List.from(terms)
    ..[idIndex] = namer.nameTemplateDeclParm(id)).join(' ');

  // end <class DeclTemplateParm>

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

  prodTemplateParmList() => prod(token, char('<')) &
      prod(prodTemplateParms).optional() &
      prod(token, char('>'));

  prodTemplateParms() => prod(prodTemplateParm)
      .separatedBy(prod(token, char(',')), includeSeparators: false);

  prodNewline() => pattern('\n\r');

  prodHidden() => prod(prodHiddenStuff).plus();

  prodHiddenStuff() => prod(prodWhitespace) |
      prod(prodSingleLineComment) |
      prod(prodMultiLineComment);

  prodWhitespace() => whitespace();

  prodSingleLineComment() => string('//') &
      prod(prodNewline).neg().star() &
      prod(prodNewline).optional();

  prodMultiLineComment() => string('/*') &
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

  String get decl => '''
template< ${parms.join(',\n          ')} >''';

  toString() => decl;

  // end <class Template>

}

// custom <part template>

final _templateTypeParmRe = new RegExp(r'\s*typename\s+(\w+)(?:\s+(.+))?');
final _whiteSpaceRe = new RegExp(r'\s+');
final _equalsTextRe = new RegExp(r'\s*=\s*(.+?)\s*$');
final _word = new RegExp(r'^\w+$');

Template template([Iterable<String> decls]) => new Template('id', decls);

_makeTemplatepParm(tparm) {
  if (tparm is RawTemplateParm) return tparm;

  var match = _templateTypeParmRe.firstMatch(tparm);
  if (match != null) {
    var defaultType = match.group(2);
    if (defaultType != null) {
      var rhs = _equalsTextRe.firstMatch(defaultType);
      if (rhs != null) {
        defaultType = rhs.group(1);
      }
    }
    final id = makeId(match.group(1));
    _logger.info('making typeTemplateParm $id from $tparm with $defaultType');
    return new TypeTemplateParm(id, defaultType);
  } else {
    final terms = tparm.split(_whiteSpaceRe);
    var equalIndex = terms.indexOf('=');
    var id;
    var idIndex;
    if (equalIndex >= 0) {
      assert(equalIndex > 0);
      idIndex = equalIndex - 1;
      id = idFromString(terms[idIndex]);
    } else {
      for (final indexValue in enumerate(terms.reversed)) {
        if (_word.firstMatch(indexValue.value) != null) {
          idIndex = terms.length - indexValue.index - 1;
          id = idFromString(indexValue.value);
          break;
        }
      }
    }
    _logger.info('making declTemplateParm $id from $tparm');
    return new DeclTemplateParm(id, terms, idIndex);
  }
}

TemplateParm templateParm(tparm) => tparm is TemplateParm
    ? tparm
    : tparm is String
        ? _makeTemplatepParm(tparm)
        : throw 'templateParm(..) takes TemplateParm or String';

TemplateParm rawTemplateParm(id, tparm) => new RawTemplateParm(id, tparm);

// end <part template>
