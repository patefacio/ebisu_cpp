/// Classes to facilitate generating C++ template code
part of ebisu_cpp.ebisu_cpp;

enum TemplateParmType {
  /// Indicates the template parameter names a type
  type,

  /// Indicates the template parameter indicates a non-type
  /// (e.g. *MAX_SIZE = 10* - a constant literal)
  nonType
}

class TemplateParser {
  // custom <class TemplateParser>
  // end <class TemplateParser>

}

abstract class TemplateParm extends CppEntity {
  // custom <class TemplateParm>
  TemplateParm(id) : super(id);
  Iterable<Entity> get children => [];
  // end <class TemplateParm>

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

// end <part template>
