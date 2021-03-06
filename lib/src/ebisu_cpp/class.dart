part of ebisu_cpp.ebisu_cpp;

/// The various supported code blocks associated with a C++ class. The
/// name indicates where in the class it appears. Within the class
/// definition the order is *public*, *protected* then
/// *private*. Additional locations for just before the class and just
/// after the class.
///
/// So, the following spec:
///
///     final sample = class_('c')
///         ..customBlocks = [
///           clsClose,
///           clsOpen,
///           clsPostDecl,
///           clsPreDecl,
///           clsPrivate,
///           clsPrivateBegin,
///           clsPrivateEnd,
///           clsProtected,
///           clsProtectedBegin,
///           clsProtectedEnd,
///           clsPublic,
///           clsPublicBegin,
///           clsPublicEnd,
///         ];
///
///     print(sample.definition);
///
///
/// Gives the following content:
///
///     // custom <ClsPreDecl C>
///     // end <ClsPreDecl C>
///
///     class C {
///       // custom <ClsOpen C>
///       // end <ClsOpen C>
///
///      public:
///       // custom <ClsPublicBegin C>
///       // end <ClsPublicBegin C>
///
///       // custom <ClsPublic C>
///       // end <ClsPublic C>
///
///       // custom <ClsPublicEnd C>
///       // end <ClsPublicEnd C>
///
///      protected:
///       // custom <ClsProtectedBegin C>
///       // end <ClsProtectedBegin C>
///
///       // custom <ClsProtected C>
///       // end <ClsProtected C>
///
///       // custom <ClsProtectedEnd C>
///       // end <ClsProtectedEnd C>
///
///      private:
///       // custom <ClsPrivateBegin C>
///       // end <ClsPrivateBegin C>
///
///       // custom <ClsPrivate C>
///       // end <ClsPrivate C>
///
///       // custom <ClsPrivateEnd C>
///       // end <ClsPrivateEnd C>
///
///       // custom <ClsClose C>
///       // end <ClsClose C>
///     };
///
///     // custom <ClsPostDecl C>
///     // end <ClsPostDecl C>
///
enum ClassCodeBlock {
  /// The custom block appearing just after class is opened
  clsOpen,

  /// The custom block appearing at start *public* section
  clsPublicBegin,

  /// The custom block appearing in the standard *public* section
  clsPublic,

  /// The custom block appearing at end *public* section
  clsPublicEnd,

  /// The custom block appearing at start *protected* section
  clsProtectedBegin,

  /// The custom block appearing in the standard *protected* section
  clsProtected,

  /// The custom block appearing at end *protected* section
  clsProtectedEnd,

  /// The custom block appearing at start *private* section
  clsPrivateBegin,

  /// The custom block appearing in the standard *private* section
  clsPrivate,

  /// The custom block appearing at end *private* section
  clsPrivateEnd,

  /// The custom block appearing just before class is closed
  clsClose,

  /// The custom block appearing just before the class definition
  clsPreDecl,

  /// The custom block appearing just after the class definition
  clsPostDecl
}

/// Convenient access to ClassCodeBlock.clsOpen with *clsOpen* see [ClassCodeBlock].
///
/// The custom block appearing just after class is opened
///
const ClassCodeBlock clsOpen = ClassCodeBlock.clsOpen;

/// Convenient access to ClassCodeBlock.clsPublicBegin with *clsPublicBegin* see [ClassCodeBlock].
///
/// The custom block appearing at start *public* section
///
const ClassCodeBlock clsPublicBegin = ClassCodeBlock.clsPublicBegin;

/// Convenient access to ClassCodeBlock.clsPublic with *clsPublic* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *public* section
///
const ClassCodeBlock clsPublic = ClassCodeBlock.clsPublic;

/// Convenient access to ClassCodeBlock.clsPublicEnd with *clsPublicEnd* see [ClassCodeBlock].
///
/// The custom block appearing at end *public* section
///
const ClassCodeBlock clsPublicEnd = ClassCodeBlock.clsPublicEnd;

/// Convenient access to ClassCodeBlock.clsProtectedBegin with *clsProtectedBegin* see [ClassCodeBlock].
///
/// The custom block appearing at start *protected* section
///
const ClassCodeBlock clsProtectedBegin = ClassCodeBlock.clsProtectedBegin;

/// Convenient access to ClassCodeBlock.clsProtected with *clsProtected* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *protected* section
///
const ClassCodeBlock clsProtected = ClassCodeBlock.clsProtected;

/// Convenient access to ClassCodeBlock.clsProtectedEnd with *clsProtectedEnd* see [ClassCodeBlock].
///
/// The custom block appearing at end *protected* section
///
const ClassCodeBlock clsProtectedEnd = ClassCodeBlock.clsProtectedEnd;

/// Convenient access to ClassCodeBlock.clsPrivateBegin with *clsPrivateBegin* see [ClassCodeBlock].
///
/// The custom block appearing at start *private* section
///
const ClassCodeBlock clsPrivateBegin = ClassCodeBlock.clsPrivateBegin;

/// Convenient access to ClassCodeBlock.clsPrivate with *clsPrivate* see [ClassCodeBlock].
///
/// The custom block appearing in the standard *private* section
///
const ClassCodeBlock clsPrivate = ClassCodeBlock.clsPrivate;

/// Convenient access to ClassCodeBlock.clsPrivateEnd with *clsPrivateEnd* see [ClassCodeBlock].
///
/// The custom block appearing at end *private* section
///
const ClassCodeBlock clsPrivateEnd = ClassCodeBlock.clsPrivateEnd;

/// Convenient access to ClassCodeBlock.clsClose with *clsClose* see [ClassCodeBlock].
///
/// The custom block appearing just before class is closed
///
const ClassCodeBlock clsClose = ClassCodeBlock.clsClose;

/// Convenient access to ClassCodeBlock.clsPreDecl with *clsPreDecl* see [ClassCodeBlock].
///
/// The custom block appearing just before the class definition
///
const ClassCodeBlock clsPreDecl = ClassCodeBlock.clsPreDecl;

/// Convenient access to ClassCodeBlock.clsPostDecl with *clsPostDecl* see [ClassCodeBlock].
///
/// The custom block appearing just after the class definition
///
const ClassCodeBlock clsPostDecl = ClassCodeBlock.clsPostDecl;

/// Establishes an interface for generated class methods like
/// consructors, destructors, overloaded operators, etc.
abstract class ClassMethod extends Object with Loggable, CustomCodeBlock {
  Class get parent => _parent;

  /// If true add logging
  bool isLogged = false;
  Template get template => _template;

  /// C++ style access of method
  CppAccess cppAccess = public;

  /// Code snippet to inject at beginning of method. The intent is for the
  /// methods to have standard generated implementations, but to also
  /// support programatic injection of implmementation into the
  /// methods. This supports injection near the top of the method.
  String topInject = '';

  /// Supports injecting code near the bottom of the method. *See*
  /// *topInject*
  String bottomInject = '';

  /// If set will include protection block for hand-coding in method.
  ///
  /// Normally an a class mixing in [CustomCodeBlock] would provide a setter
  /// [includesProtectBlock] that would set the [tag] field of the [CodeBlock] mixed
  /// in by the [CustomCodeBlock] to some unique name. For example, [Class] has an
  /// [includesProtectBlock] that sets the [tag] to 'class $name'.
  ///
  /// In the case of [ClassMethod] the owning [Class] is not usually established early
  /// on so there is no easy way to name the protect block when the [ClassMethod] is
  /// constructed. This member is used to track the request to include a protection
  /// block and tagging is deferred until needed.
  bool includesProtectBlock = false;

  /// Method documentation
  String doc;

  /// If true the method is noexcept(true)
  bool isNoExcept = false;

  // custom <class ClassMethod>

  String get definition;
  String get className => _parent.className;

  /// Returns portion of *blockTag* associated with the class.
  ///
  /// NB: Unlike [className] it is not tied to a namer, so moving from one
  /// [Namer] style to another should not affect custom blocks using this tag.
  String get classBlockTag => _parent.id.capSnake;

  List<Member> get members => _parent.members;

  /// Set the [template] for the [ClassMethod]
  set template(Object t) =>
      _template = _makeTemplate('class_method', t); // TODO: make entity

  /// Given [signature] and [blockTag] returns the function contents
  String functionContents(String signature, String blockTag) {
    if (includesProtectBlock || super.includesProtectBlock) {
      customCodeBlock..tag = blockTag;
    }
    return brCompact([
      doc != null ? blockComment(doc, ' ') : doc,
      '${_decorateNoExcept(signature)} {',
      topInject,
      blockText,
      bottomInject,
      '}'
    ]);
  }

  _decorateNoExcept(s) =>
      (isNoExcept == null || !isNoExcept) ? s : '$s noexcept(true)';

  // end <class ClassMethod>

  Class _parent;
  Template _template;
}

/// Unifies the [ClassMethod]s that can be specified as *default*,
/// like [DefaultCtor], [CopyCtor], etc.
///
/// Also provides for *delete*d methods.
abstract class DefaultMethod extends ClassMethod {
  bool usesDefault = false;
  bool hasDelete = false;

  // custom <class DefaultMethod>

  String get customDefinition;
  String get prototype;

  String get definition => _templateWrap(usesDefault
      ? '${_decorateNoExcept(prototype)} = default;'
      : hasDelete
          ? '${_decorateNoExcept(prototype)} = delete;'
          : customDefinition);

  _templateWrap(s) => _template != null ? '$_template\n$s' : s;

  // end <class DefaultMethod>

}

/// Default ctor, autoinitialized on read
class DefaultCtor extends DefaultMethod {
  // custom <class DefaultCtor>

  String get prototype => '${className}()';

  String get customDefinition =>
      functionContents(prototype, '$classBlockTag defaultCtor');

  // end <class DefaultCtor>

}

/// Copy ctor, autoinitialized on read
class CopyCtor extends DefaultMethod {
  // custom <class CopyCtor>

  String get prototype => '${className}(${className} const& other)';

  String get customDefinition => functionContents(
      '${className}(${className} const& other)', '$classBlockTag copyCtor');

  // end <class CopyCtor>

}

/// Move ctor, autoinitialized on read
class MoveCtor extends DefaultMethod {
  // custom <class MoveCtor>

  String get prototype => '${className}(${className} && other)';

  String get customDefinition => 'Move Ctor';

  // end <class MoveCtor>

}

class AssignCopy extends DefaultMethod {
  // custom <class AssignCopy>

  String get prototype => '${className}& operator=(${className} const&)';
  String get customDefinition =>
      throw 'AssignCopy not generated - specify usesDefault or hasDelete for ${className}';

  // end <class AssignCopy>

}

class AssignMove extends DefaultMethod {
  // custom <class AssignMove>

  String get prototype => '${className}& operator=(${className} &&)';
  String get customDefinition =>
      throw 'AssignMove not generated - specify usesDefault or hasDelete for ${className}';

  // end <class AssignMove>

}

/// Provides a destructor
class Dtor extends DefaultMethod {
  bool isAbstract = false;

  // custom <class Dtor>

  String get definition => hasDelete
      ? throw "Don't delete the destructor for $className"
      : super.definition;

  String get prototype => '~${className}()';

  String get customDefinition => functionContents(
      isAbstract ? 'virtual ~${className}()' : '~${className}()',
      '$classBlockTag dtor');

  // end <class Dtor>

}

/// A *Member Constructor Parameter*. Defines a single parameter to be passed to a
/// MemberCtor in order to initialize a single member variable. MemberCtor will
/// convert strings automatically into instances of MemberCtorParm. For example:
///
///     memberCtor(['x', 'y'])
///
/// would produce the following constructor:
///
///     class Point {
///     public:
///       Point(int x, int y) : x_{x}, y_{y} {}
///     private:
///       int x_;
///       int y_;
///     }
///
/// But to modify the parameter definition or initializtaion you might rather
/// construct and modify the MemberCtorParm instead of taking the default:
///
///         final cls = class_('point')
///           ..members = [ member('x')..init = 0, member('y')..init = 0 ]
///           ..memberCtors = [
///             memberCtor( [
///               memberCtorParm('x')
///               ..defaultValue = '42',
///               memberCtorParm('y')
///               ..defaultValue = '42'] )
///           ];
///
/// which produces:
///
///     class Point
///     {
///     public:
///       Point(
///         int x = 42,
///         int y = 42) :
///         x_ { x },
///         y_ { y } {
///       }
///
///     private:
///       int x_ { 0 };
///       int y_ { 0 };
///     };
class MemberCtorParm {
  MemberCtorParm(this.name);

  /// Name of member initialized by argument to member ctor
  final String name;

  /// cpp member to be initialized
  Member member;

  /// *Override* for arguemnt declaration. This is rarely needed. Suppose
  /// you want to initialize member *Y y* from an input argument *X x* that
  /// requires a special function *f* to do the conversion:
  ///
  ///     Class(X x) : y_ {f(x)}
  ///
  /// Which would be achieved by:
  ///
  ///     memberCtor([
  ///       memberCtorParm("y")
  ///       ..parmDecl = "X x"
  ///       ..init = "f(x)"
  ///     ])
  String parmDecl;

  /// *Override* of initialization text. This is rarely needed since
  /// initialization of members in a member ctor is straightforward:
  ///
  /// This definition:
  ///
  ///     memberCtor(['x', 'y'])
  ///
  /// would produce the following constructor:
  ///
  ///     class Point {
  ///     public:
  ///       Point(int x, int y) : x_{x}, y_{y} {}
  ///     private:
  ///       int x_;
  ///       int y_;
  ///     }
  ///
  /// But sometimes you need more:
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  /// Which would be achieved by:
  ///
  ///     memberCtor([
  ///       memberCtorParm("previous_mode")
  ///       ..parmDecl = "mode_t new_mode"
  ///       ..init = "umask(new_mode)"
  ///     ])
  set init(String init) => _init = init;

  /// If set provides a default value for the parm in the ctor. For example:
  ///
  ///     memberCtorParm('x')..defaultValue = '42'
  ///
  /// where the type of member *x* is *int* might yield:
  ///
  ///     Cls(int x = 42) : x_{x}
  String defaultValue;

  // custom <class MemberCtorParm>

  /// The parameter as declared in the ctor, including any defaultValue. So, the:
  ///     mode_t new_mode
  /// in the following ctor
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  get decl => parmDecl != null
      ? parmDecl
      : defaultValue != null
          ? '${member.passType} ${member.name} = $defaultValue'
          : '${member.passType} ${member.name}';

  /// The complete initialization text for the member in the ctor. So, the:
  ///     previous_mode_{umask(new_mode)}
  /// in the following:
  ///
  ///     class Umask_scoped_set {
  ///     public:
  ///       Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
  ///     ...
  ///     }
  ///
  get memberInit => member.ctorInit != null
      ? '${member.vname} ${_memberInitExpression(member.ctorInit)}'
      : _init != null
          ? '${member.vname} ${_memberInitExpression(_init)}'
          : '${member.vname} ${_memberInitExpression(member.name)}';

  /// gcc is not fond of init lists for references
  _memberInitExpression(txt) => '($txt)';

  // end <class MemberCtorParm>

  String _init;
}

/// Create MemberCtorParm without new, for more declarative construction
MemberCtorParm memberCtorParm(final String name) => new MemberCtorParm(name);

/// Specificication for a member constructor. A member constructor is a constructor
/// with the intent of initializing one or more members of a class.
///
/// Assumig a class has members *int x* and *int y*
/// *memberCtor(["x", "y"])*
///
/// would generate the corresponding:
///
///     Class(int x, int y) : x_{x}, y_{y} {}
///
/// If custom logic is additionally required, set the *hasCustom* flag to include a
/// custom block. In that case the class might look like:
///
///     Class(int x, int y) : x_{x}, y_{y} {
///       // custom <Class>
///       // end <Class>
///     }
class MemberCtor extends ClassMethod {
  /// List of members that are passed as arguments for initialization
  List<MemberCtorParm> get memberParms => _memberParms;

  /// List of additional decls ["Type Argname", ...]
  List<String> decls;

  /// If set automatically includes all members as args
  bool hasAllMembers = false;

  /// If true makes the ctor explicit
  bool isExplicit = false;

  // custom <class MemberCtor>

  static _makeParm(parm) => (parm is String)
      ? memberCtorParm(parm)
      : (parm is MemberCtorParm) ? parm : (throw new Exception('''
MemberCtor ctor requires list of parms where each parm is a *String* naming the
member being initialized or a MemberCtorParm instance'''));

  MemberCtor(Iterable parms, [this.decls]) {
    memberParms = parms.map((parm) => _makeParm(parm)).toList();
    if (decls == null) decls = [];
  }

  set memberParms(memberParms) => _memberParms = new List.from(memberParms);
  String get _templateDecl => _template == null ? '' : br(_template.decl);

  /// The [MemberCtor] definition as it appears in the class
  String get definition {
    if (hasAllMembers) {
      assert(memberParms.isEmpty);
      memberParms =
          parent.members.map((m) => _makeParm(m.name)..member = m).toList();
    } else {
      memberParms.forEach((MemberCtorParm mp) => mp.member = parent.members
          .firstWhere((m) => mp.name == m.name,
              orElse: () =>
                  throw 'Could not find matching member for $className::${mp.name}'));
    }

    final bogusMemberParms = memberParms.where((mp) => mp.member.hasIfdef);
    if (bogusMemberParms.isNotEmpty) {
      throw '''
No *ifdef* qualified members in memberCtor
  {${bogusMemberParms.map((m) => m.member.id).join(", ")}}
''';
    }

    List<String> argDecls = decls == null ? [] : new List<String>.from(decls);
    List<String> initializers = [];

    parent.bases
        .where((b) => b.init != null)
        .forEach((b) => initializers.add(b.init));

    memberParms.forEach((MemberCtorParm parm) {
      argDecls.add(parm.decl);
      initializers.add(parm.memberInit);
    });

    final explicitTag = isExplicit ? 'explicit ' : '';
    final memberInitializerList = initializers.isEmpty
        ? ''
        : " : ${indentBlock(initializers.join(',\n'))}";

    return functionContents(
        '''
${explicitTag}${_templateDecl}${className}(
${indentBlock(argDecls.join(',\n'))})$memberInitializerList''',
        tag != null
            ? '${classBlockTag}($tag)'
            : '${classBlockTag}(${argDecls.join(':')})');
  }

  /// Set a [label] for the *protect block*.
  ///
  /// This will set the [tag] of the *protect block* in a way that incorporates
  /// the [label]. It also includes the *className* to prevent *protection
  /// block* trampling.
  set customLabel(String label) => tag = label;

  // end <class MemberCtor>

  List<MemberCtorParm> _memberParms = [];
}

/// Provides *operator==()*
class OpEqual extends ClassMethod {
  // custom <class OpEqual>

  String get definition => '''bool operator==(${className} const& rhs) const {
  return this == &rhs ||
    (${members.map((m) => '${m.vname} == rhs.${m.vname}').join(' &&\n    ')});
}

bool operator!=($className const& rhs) const {
  return !(*this == rhs);
}''';

  // end <class OpEqual>

}

/// Provides *operator<()*
class OpLess extends ClassMethod {
  // custom <class OpLess>

  String get definition {
    List pairs = [];
    pairs.addAll(members.map((m) => [m.vname, 'rhs.${m.vname}']));
    return '''
bool operator<($className const& rhs) const {
  return ${pairs.map((p) => '${p[0]} != ${p[1]}? ${p[0]} < ${p[1]} : (').join('\n    ')}
    false${pairs.map((_) => ')').join()};
}
''';
  }

  // end <class OpLess>

}

/// Provides *operator<<()*
class OpOut extends ClassMethod {
  /// If true uses tls indentation tracking to indent nested
  /// components when streaming
  bool usesNestedIndent = false;

  // custom <class OpOut>

  get _nl => r"\n";

  _outputMember(name, value) => usesNestedIndent
      ? 'out << \'$_nl\' << indent << "  $name:" << $value;'
      : 'out << "$_nl  $name:" << $value;';

  _outputText(text) => usesNestedIndent
      ? 'out << \'$_nl\' << indent << "$text";'
      : 'out << "$_nl$text";';

  _outputOpener(text) =>
      usesNestedIndent ? 'out << indent << "$text";' : 'out << "$text";';

  _streamMemberPtr(Member m) => brCompact([
        usesNestedIndent
            ? 'out  << \'$_nl\' << indent << "  ${m.name}:";'
            : 'out << "$_nl  ${m.name}:";',
        '''
if(item.${m.vname}) {
  out << *item.${m.vname};
} else {
  out << "(null)";
}'''
      ]);

  _streamMember(Member m) {
    if (m.hasCustomStreamable) {
      final codeBlock = m.customStreamable;
      if (codeBlock.tag != null) {
        codeBlock.tag = '${parent.className}::${m.name}';
      }
      return codeBlock;
    } else {
      return m.isStreamablePtr
          ? _streamMemberPtr(m)
          : m.isStreamable
              ? _outputMember(m.name,
                  m.hasCustomGetter ? 'item.${m.name}()' : 'item.${m.vname}')
              : '';
    }
  }

  get _usesStreamersNamespace => parent.usesStreamers
      ? '''
using ebisu::utils::streamers::operator<<;
'''
      : '';
  get _indentSupport => br([
        _usesStreamersNamespace,
        usesNestedIndent
            ? '''
ebisu::utils::Block_indenter indenter;
char const* indent(indenter.current_indentation_text());
'''
            : ''
      ]);

  String _streamBase(Base b) =>
      'out << "\\n  " << static_cast<${b.className}>(item);';
  get _streamBases =>
      parent.bases.where((b) => b.isStreamable).map((b) => _streamBase(b));

  String get definition => brCompact([
        '''
friend inline
std::ostream& operator<<(std::ostream &out,
                         $className const& item) {
${indentBlock(chomp(brCompact([
          _indentSupport,
          _outputOpener('$className(" << &item << ") {'),
          _streamBases,
          brCompact(members.map((m) => _streamMember(m))),
          _outputText('}\\n'),
        ])))}
''',
        blockText,
        '''
  return out;
}'''
      ]);

  // end <class OpOut>

}

/// A C++ class.
///
/// Classes optionally have these items:
///
/// * A [template]
/// * A collection of [bases]
/// * A collection of [members]
/// * A collection of class local [forwardDecls]
/// * A collection of class local [usings]
/// * A collection of class local [enums]
/// * A collection of class local [forward_ptrs] which are like [usings] but standardized for pointer type
/// * A collection of *optionally included* standard methods.
///   In general these methods are not included unless requested. There
///   are two approaches to *requesting* their presence:
///
///   1 - just mention their name (i.e. invoke the getter for the member on the
///   class which autoinitializes the member) and the default function will be
///   included. This is a *funky* use of function side-effects, but the effect is
///   fewer calls required to declaratively describe your class.
///
///   2 - when more configuration of the method is required, call the *with...()*
///   function to get scoped access to the function object.
///
///   Example - Case 1:
///
///       print(clangFormat((class_('x')).definition));
///       print(clangFormat((class_('x')..copyCtor).definition));
///       print(clangFormat((class_('x')..copyCtor.usesDefault = true).definition));
///
///   Prints:
///
///         class X {};
///
///         class X {
///          public:
///           X(X const& other) {}
///         };
///
///         class X {
///          public:
///           X(X const& other) = default;
///         };
///
///
///   Note that simply naming the copy constructor member of the class will inlude
///   its definition. Sometimes you might want to do more with a [ClassMethod]
///   definition declaratively in place which is why the *with...()* methods exist.
///
///   Example - Case 2:
///
///       print(clangFormat((
///                   class_('x')
///                   ..withCopyCtor((ctor) =>
///                       ctor..cppAccess = protected
///                       /// ... do more with ctor, like inject logging code
///                       ))
///               .definition));
///
///   Prints:
///
///         class X {
///          protected:
///           X(X const& other) {}
///         };
///
///   The functions are:
///
///   * Optionally included constructors including:
///
///     * [CopyCtor]
///     * [MoveCtor]
///     * [DefaultCtor]
///     * Zero or more member initializing ctors [MemberCtor]
///
///   * Assignment functions:
///
///     * [AssignCopy]
///     * [AssignMove]
///
///   * [Dtor]
///
///   * Standard Utility Methods
///
///     * [OpEqual]
///     * [OpLess]
///     * [OpOut] - Support for streaming fields
///
/// * A fixed collection of indexed [codeBlocks] that can be used for
///   providing *CustomBlocks* and/or for dynamically injecting code - see
///   [CodeBlock].
class Class extends CppEntity with Testable, AggregateBase {
  /// Is this definition a *struct*
  bool isStruct = false;

  /// The template by which the class is parameterized
  Template get template => _template;

  /// A template specialization associated with the class.  Use this when
  /// the class is a template specialization. If class is a partial template
  /// specialization, use both [template] and [templateSpecialization].
  TemplateSpecialization templateSpecialization;

  /// Forward declarations near top of file, before the class definition
  List<ForwardDecl> get forwardDecls => _forwardDecls;

  /// Forward declarations within class, ideal for forward declaring nested classes
  List<ForwardDecl> get classForwardDecls => _classForwardDecls;

  /// *constexpr*s associated with the class
  List<ConstExpr> get constExprs => _constExprs;

  /// List of usings that will be scoped to this class near the top of
  /// the class definition.
  List<Using> get usings => _usings;

  /// List of usings to occur after the class declaration. Sometimes it is
  /// useful to establish some type definitions directly following the class
  /// so they may be reused among any client of the class. For instance if
  /// class *Foo* will most commonly be used in vector, the using occuring
  /// just after the class definition will work:
  ///
  ///     using Foo = std::vector<Foo>;
  List<Using> get usingsPostDecl => _usingsPostDecl;

  /// Base classes this class derives form.
  List<Base> bases = [];

  /// A list of member constructors
  List<MemberCtor> get memberCtors => _memberCtors;
  List<PtrType> forwardPtrs = [];
  List<Enum> get enumsForward => _enumsForward;
  List<Enum> get enums => _enums;
  List<Member> get members => _members;
  List<FriendClassDecl> get friendClassDecls => _friendClassDecls;
  List<ClassCodeBlock> customBlocks = [];
  bool isSingleton = false;

  /// If true deletes copy ctor and assignment operator
  bool isNoncopyable = false;
  Map<ClassCodeBlock, CodeBlock> get codeBlocks => _codeBlocks;

  /// If true adds {using fcs::utils::streamers::operator<<} to streamer.
  /// Also, when set assumes streaming required and [isStreamable]
  /// is *set* as well. So not required to set both.
  bool get usesStreamers => _usesStreamers;

  /// Describes printer support required for class
  PrinterSupport printerSupport;

  /// If true adds final keyword to class
  bool isFinal = false;

  /// If true makes all members const provides single member ctor
  /// initializing all.
  ///
  /// There are a few options to achieve *immutable* support. The first is
  /// this type, where all fields are constant and therefore must be
  /// initialized. An alternative concept is immutable from perspective of
  /// user. This can be achieved with use of [addFullMemberCtor] and the
  /// developer ensuring the members are not modified. This provides a
  /// stronger guarantee of immutability.
  bool isImmutable = false;

  /// List of processors supporting flavors of serialization
  List<Serializer> serializers = [];
  List<InterfaceImplementation> get interfaceImplementations =>
      _interfaceImplementations;

  /// A [CppAccess] specifier - only pertinent if class is nested
  CppAccess cppAccess = public;

  /// Classes nested within this class
  List<Class> nestedClasses = [];

  /// If set, will include *#pragma pack(push, $packAlign)* before the class
  /// and *#pragma pack(pop)* after.
  int packAlign;

  // custom <class Class>

  Class(id) : super(id);

  /// Pass [this] to functor to ease inline/declarative work
  ///
  /// For example, to pass [Class] currently being defined to another
  /// function:
  ///
  ///    class_('foo')
  ///    ..members = [ ... ]
  ///    ..withClass((cls) => augmentClassWithStuff(cls))
  ///    ...
  withClass(func(Class c)) => func(this);

  get installation => super.installation;

  get requiresLogging =>
      concat(<Iterable<dynamic>>[_standardMethods, memberCtors])
          .any((m) => m is Loggable && m.isLogged);

  get includes => requiresLogging
      ? super
          .includes
          .mergeIncludes(installation.logProvider.includeRequirements)
      : super.includes;

  /// Updates the class with default printer support
  giveDefaultPrinterSupport() {
    this.printerSupport = new PrinterSupport(className, true, false);
    includes.add('ebisu/utils/streamers/printer.hpp');
  }

  Iterable<Entity> get children => concat([
        enumsForward,
        enums,
        members,
        usings,
        usingsPostDecl,
        [template],
        testScenarios,
        nestedClasses,
        interfaceImplementations
      ]).where((child) => child != null);

  set memberCtors(memberCtors) => _memberCtors = new List.from(memberCtors);
  set enumsForward(enumsForward) => _enumsForward = new List.from(enumsForward);
  set enums(enums) => _enums = new List.from(enums);
  set members(members) => _members = new List.from(members);
  set friendClassDecls(friendClassDecls) =>
      _friendClassDecls = new List.from(friendClassDecls);

  /// If set, the [OpOut] streamer will use nested indenting
  set usesNestedIndent(value) => opOut.usesNestedIndent = value;

  /// Set the using statements that appear in the *public* section
  set usings(Iterable items) => _usings = items.map((u) => using(u)).toList();

  /// Set the using statements that appear after the class definition
  set usingsPostDecl(Iterable items) =>
      _usingsPostDecl = items.map((u) => using(u)).toList();

  set interfaceImplementations(Iterable impls) =>
      _interfaceImplementations = impls
          .map((i) => i is InterfaceImplementation
              ? i
              : i is Interface
                  ? new InterfaceImplementation(i)
                  : throw '''
[interfaceImplementations] set requires Iterable of [Interface]
or [Interfaceimplementations]. If an [Interface] is provided an
default [Interfaceimplementation] is used''')
          .toList();

  String get classStyle => isStruct ? 'struct' : 'class';

  set isStreamable(bool s) => s ? opOut : (_opOut = null);

  get isStreamable => _opOut != null;

  set usesStreamers(bool s) {
    /// Note: usesStreamers *implies* isStreamable, so ensure opOut initialized
    if (s) opOut;
    _usesStreamers = s;
  }

  set forwardDecls(forwardDecls) => _forwardDecls = new List.from(forwardDecls);
  set classForwardDecls(classForwardDecls) =>
      _classForwardDecls = new List.from(classForwardDecls);
  set constExprs(constExprs) => _constExprs = new List.from(constExprs);

  /// Auto-initializing accessor for the [DefaultCtor]
  DefaultCtor get defaultCtor =>
      _defaultCtor = _defaultCtor == null ? new DefaultCtor() : _defaultCtor;
  withDefaultCtor(void f(DefaultCtor defaultCtor)) => f(defaultCtor);
  bool get hasDefaultCtor => _defaultCtor != null;

  /// Auto-initializing accessor for the [CopyCtor]
  CopyCtor get copyCtor =>
      _copyCtor = _copyCtor == null ? new CopyCtor() : _copyCtor;
  withCopyCtor(void f(CopyCtor copyCtor)) => f(copyCtor);
  bool get hasCopyCtor => _copyCtor != null;

  /// Auto-initializing accessor for the [MoveCtor]
  MoveCtor get moveCtor =>
      _moveCtor = _moveCtor == null ? new MoveCtor() : _moveCtor;
  withMoveCtor(void f(MoveCtor moveCtor)) => f(moveCtor);
  bool get hasMoveCtor => _moveCtor != null;

  /// Auto-initializing accessor for the [AssignCopy]
  AssignCopy get assignCopy =>
      _assignCopy = _assignCopy == null ? new AssignCopy() : _assignCopy;
  withAssignCopy(void f(AssignCopy assignCopy)) => f(assignCopy);
  bool get hasAssignCopy => _assignCopy != null;

  /// Auto-initializing accessor for the [AssignMove]
  AssignMove get assignMove =>
      _assignMove = _assignMove == null ? new AssignMove() : _assignMove;
  withAssignMove(void f(AssignMove assignMove)) => f(assignMove);
  bool get hasAssignMove => _assignMove != null;

  /// Auto-initializing accessor for the [Dtor]
  Dtor get dtor => _dtor = _dtor == null ? new Dtor() : _dtor;
  withDtor(void f(Dtor dtor)) => f(dtor);
  bool get hasDtor => _dtor != null;

  /// Auto-initializing accessor for the [OpEqual]
  OpEqual get opEqual => _opEqual = _opEqual == null ? new OpEqual() : _opEqual;
  withOpEqual(void f(OpEqual opEqual)) => f(opEqual);
  bool get hasOpEqual => _opEqual != null;

  /// Auto-initializing accessor for the [OpLess]
  OpLess get opLess => _opLess = _opLess == null ? new OpLess() : _opLess;
  withOpLess(void f(OpLess opLess)) => f(opLess);
  bool get hasOpLess => _opLess != null;

  /// Auto-initializing accessor for the [OpOut]
  OpOut get opOut => _opOut = _opOut == null ? new OpOut() : _opOut;
  withOpOut(void f(OpOut opOut)) => f(opOut);
  bool get hasOpOut => _opOut != null;

  set defaultCtor(DefaultCtor defaultCtor) => _defaultCtor = defaultCtor;
  set copyCtor(CopyCtor copyCtor) => _copyCtor = copyCtor;
  set moveCtor(MoveCtor moveCtor) => _moveCtor = moveCtor;
  set assignCopy(AssignCopy assignCopy) => _assignCopy = assignCopy;
  set assignMove(AssignMove assignMove) => _assignMove = assignMove;
  set dtor(Dtor dtor) => _dtor = dtor;
  set opEqual(OpEqual opEqual) => _opEqual = opEqual;
  set opLess(OpLess opLess) => _opLess = opLess;
  set opOut(OpOut opOut) => _opOut = opOut;

  Iterable<Base> get basesPublic => bases.where((b) => b.cppAccess == public);
  Iterable<Base> get basesProtected =>
      bases.where((b) => b.cppAccess == protected);
  Iterable<Base> get basesPrivate => bases.where((b) => b.cppAccess == private);

  void withCustomBlock(ClassCodeBlock cb, f(CodeBlock codeBlock)) =>
      f(getCodeBlock(cb));

  set template(Object t) => _template = _makeTemplate(id, t);

  usesType(String type) => members.any((m) => m.type == type);
  get typesReferenced => members.map((m) => m.type);

  /// Get the specified [ClassCodeBlock] and if not present creates a
  /// fresh one.
  ///
  /// [CodeBlock] allows for injection of code at a location indicated
  /// by the [ClassCodeBlock] argument. For example:
  ///
  ///    class_('c')
  ///    ..getCodeBlock(clsPublic).snippets.add('// foo')
  ///    ..definition
  ///
  /// generates something like:
  ///
  ///    class C
  ///    {
  ///    public:
  ///      // foo
  ///    };
  ///
  CodeBlock getCodeBlock(ClassCodeBlock cb) {
    var result = _codeBlocks[cb];
    return (result == null) ? (_codeBlocks[cb] = codeBlock(null)) : result;
  }

  /// Adds a member constructor that provides for initialization of
  /// all members
  ///
  /// Used when class [isImmutable] is set
  addFullMemberCtor() => (memberCtors
        ..add(memberCtor(members
            .where((m) => !m.isStatic && !m.hasIfdef)
            .map((m) => m.name)
            .toList())))
      .last;

  /// Returns a string representation of the class definition
  String get definition {
    if (_definition == null) {
      if (isImmutable) {
        members.where((m) => !m.isStatic).forEach((Member m) {
          if (_defaultCtor == null) {
            m.hasNoInit = true;
          }
          m.isConst = !m.isMutable;
          m.access = ro;
        });
        if (memberCtors.isEmpty) {
          addFullMemberCtor();
        }
      }

      if (isSingleton) {
        defaultCtor.cppAccess = private;
        copyCtor.hasDelete = true;
        assignCopy.hasDelete = true;
        assignMove.hasDelete = true;
        moveCtor.hasDelete = true;
      }

      if (isNoncopyable) {
        copyCtor.hasDelete = true;
        assignCopy.hasDelete = true;
      }

      enums.forEach((e) => e.isNested = true);
      _standardMethods.forEach((m) {
        if (m != null) m._parent = this;
      });
      memberCtors.forEach((m) {
        if (m != null) m._parent = this;
      });
      customBlocks.forEach((ClassCodeBlock cb) {
        /// NB: tag does not use namer, so in future namer can be changed and
        /// protect blocks may be unaffected
        final blockTag = id.capSnake;
        getCodeBlock(cb).tag = '${evCap(cb)} $blockTag';
      });

      if (printerSupport != null) {
        new PrinterSupportProvider(this, printerSupport);
      }

      _definition = br(_parts);
    }
    return _definition;
  }

  /// Members defined in the [public] section
  Iterable<Member> get publicMembers =>
      members.where((m) => m.cppAccess == public);

  /// Members defined in the [protected] section
  Iterable<Member> get protectedMembers =>
      members.where((m) => m.cppAccess == protected);

  /// Members defined in the [private] section
  Iterable<Member> get privateMembers =>
      members.where((m) => m.cppAccess == private);

  onOwnershipEstablished() {
    interfaceImplementations
        .where((i) => i.isVirtual)
        .forEach((i) => bases.add(base(i.name)));
    _logger
        .info('Class ($id) finalized supporting: ${interfaceImplementations}');
  }

  /// Find the member named by [memberId]
  ///
  /// [memberId] may be a String or an Id identifying the member
  Member getMember(memberId) {
    memberId = makeId(memberId);
    return members.firstWhere((member) => memberId == member.id);
  }

  List<String> get _baseDecls => []
    ..addAll(basesPublic.map((b) => b.decl))
    ..addAll(basesProtected.map((b) => b.decl))
    ..addAll(basesPrivate.map((b) => b.decl));

  String get _baseDecl {
    final decls = _baseDecls;
    return decls.length > 0 ? ' :\n' + indentBlock(_baseDecls.join(',\n')) : '';
  }

  get _ctorMethods => [_defaultCtor, _copyCtor, _moveCtor];

  get _allCtors =>
      []..addAll(_ctorMethods.where((m) => m != null))..addAll(memberCtors);

  get _opMethods =>
      [_assignCopy, _assignMove, _dtor, _opEqual, _opLess, _opOut];

  get _standardMethods => []..addAll(_ctorMethods)..addAll(_opMethods);

  get _pragmaPackPush =>
      packAlign != null ? '#pragma pack(push, $packAlign)' : '';
  get _pragmaPackPop => packAlign != null ? '#pragma pack(pop)' : '';

  _memberJoinFormat(mems) =>
      brCompact(mems.map((m) => m._wrapIfDef(m.hasComment ? '\n$m' : '$m')));

  get _parts => [
        _forwardPtrs,
        forwardDecls,
        enumsForward.map((e) => e.toString()),
        _codeBlockText(clsPreDecl),
        briefComment,
        brCompact([
          detailedComment,
          _pragmaPackPush,
          _templateDecl,
          _classOpener,
          _codeBlockText(clsOpen),
        ]),
        _wrapInAccess(
            isStruct ? null : public,
            indentBlock(br([
              brCompact([
                brCompact(friendClassDecls.map((fcd) => fcd.toString())),
                _codeBlockText(clsPublicBegin),
                classForwardDecls,
                constExprs..forEach((ce) => ce.isClassScoped = true),
                usings,
              ]),
              brCompact([_enumDecls, _enumStreamers]),
              br(nestedClasses
                  .where((c) => c.cppAccess == public)
                  .map((c) => c.definition)),
              br(members
                  .where((m) => m.customBlock.hasContent)
                  .map((m) => m.customBlock.toString())),
              br(publicMembers.where((m) => m.isPublicStaticConst)),
              br(_allCtors
                  .where((m) => m.cppAccess == public)
                  .map((m) => m.definition)),
              br(_opMethods
                  .where((m) => m != null && m.cppAccess == public)
                  .map((m) => m.definition)),
              br(interfaceImplementations
                  .where((i) => i.cppAccess == public)
                  .map((i) => i.methodImpls)),
              br(_singleton),
              _codeBlockText(clsPublic),
              _memberJoinFormat(
                  publicMembers.where((m) => !m.isPublicStaticConst)),
              br(members.map((m) => m._wrapIfDef(br([m.getter, m.setter])))),
              serializers.map((s) => s.serialize(this)),
              _codeBlockText(clsPublicEnd),
            ]))),
        _wrapInAccess(
            protected,
            indentBlock(combine([
              _codeBlockText(clsProtectedBegin),
              _codeBlockText(clsProtected),
              br(nestedClasses
                  .where((c) => c.cppAccess == protected)
                  .map((c) => c.definition)),
              br(_allCtors
                  .where((m) => m.cppAccess == protected)
                  .map((m) => m.definition)),
              br(_opMethods
                  .where((m) => m != null && m.cppAccess == protected)
                  .map((m) => m.definition)),
              br(interfaceImplementations
                  .where((i) => i.cppAccess == protected)
                  .map((i) => i.methodImpls)),
              _memberJoinFormat(protectedMembers),
              _codeBlockText(clsProtectedEnd),
            ]))),
        _wrapInAccess(
            private,
            indentBlock(combine([
              _codeBlockText(clsPrivateBegin),
              _codeBlockText(clsPrivate),
              br(nestedClasses
                  .where((c) => c.cppAccess == private)
                  .map((c) => c.definition)),
              br(_allCtors
                  .where((m) => m.cppAccess == private)
                  .map((m) => m.definition)),
              br(_opMethods
                  .where((m) => m != null && m.cppAccess == private)
                  .map((m) => m.definition)),
              br(interfaceImplementations
                  .where((i) => i.cppAccess == private)
                  .map((i) => i.methodImpls)),
              _memberJoinFormat(privateMembers),
              _codeBlockText(clsPrivateEnd)
            ]))),
        br([_codeBlockText(clsClose), _classCloser, _pragmaPackPop]),
        br(usingsPostDecl),
        _codeBlockText(clsPostDecl),
      ];

  get _singleton => isSingleton
      ? '''
static $className & instance() {
  static $className instance_s;
  return instance_s;
}'''
      : null;

  get _templateDecl => _template != null ? _template.decl : null;
  get _enumDecls => enums.map((e) => e.decl);
  get _enumStreamers => enums.map((e) => e._streamSupport);
  _access(CppAccess access) => access == null
      ? ''
      : '''
${ev(access)}:
''';

  _wrapInAccess(CppAccess access, String txt) {
    return (txt != null && txt.length > 0)
        ? '''
${_access(access)}${txt}'''
        : null;
  }

  _codeBlockText(ClassCodeBlock cb) {
    final codeBlock = _codeBlocks[cb];
    return codeBlock != null ? codeBlock.toString() : null;
  }

  /// Class names are capitalized *snake case*
  String get className => namer.nameClass(id);

  get _finalDecl => isFinal ? ' final' : '';

  get _classOpener => '''
$classStyle $className$_baseDecl$_finalDecl
{''';
  get _classCloser => '};';

  get _forwardPtrs {
    if (forwardPtrs.length > 0) {
      final name = className;
      List<String> parts = ['class $name;'];
      for (var ptr in forwardPtrs) {
        parts.add('using ${name}_${ptrSuffix(ptr)} = ${ptrType(ptr, name)};');
      }
      return parts.join('\n');
    }
    return null;
  }

  // end <class Class>

  /// The contents of the class definition. *Inaccessible* and established
  /// as a member so custom *definition* getter can be called multiple times
  /// on the same class and results lazy-inited here
  String _definition;
  Template _template;
  List<ForwardDecl> _forwardDecls = [];
  List<ForwardDecl> _classForwardDecls = [];
  List<ConstExpr> _constExprs = [];
  List<Using> _usings = [];
  List<Using> _usingsPostDecl = [];

  /// The default constructor
  DefaultCtor _defaultCtor;

  /// The copy constructor
  CopyCtor _copyCtor;

  /// The move constructor
  MoveCtor _moveCtor;

  /// The assignment operator
  AssignCopy _assignCopy;

  /// The assignment move operator
  AssignMove _assignMove;

  /// The destructor
  Dtor _dtor;
  List<MemberCtor> _memberCtors = [];
  OpEqual _opEqual;
  OpLess _opLess;
  OpOut _opOut;
  List<Enum> _enumsForward = [];
  List<Enum> _enums = [];
  List<Member> _members = [];
  List<FriendClassDecl> _friendClassDecls = [];
  Map<ClassCodeBlock, CodeBlock> _codeBlocks = {};
  bool _usesStreamers = false;
  List<InterfaceImplementation> _interfaceImplementations = [];

  /// The [Method]s that are implemented by this [Class]. A [Class]
  /// implements the union of methods in its
  /// [interfaceimplementations]. Each [Method] is identified by its
  /// qualified id *string* which is:
  ///
  ///    interface.method_name.signature
  ///
  /// Lookup is done by pattern match.
  Map<String, Method> _methods = {};
}

// custom <part class>

/// Convenience fucnction for creating a [Class]
///
/// All classes must be named with an [Id]. This method accepts an [Id] or
/// creates one. Creation of [Id] requires a string in *snake case*
Class class_(id) => new Class(id);

/// Create a template from (1) a single string (2) [Iterable] of arguments for
/// construction
Template _makeTemplate(id, Object t) => t is Iterable
    ? new Template(id, t)
    : t is String ? new Template(id, [t]) : t as Template;

/// Convenience returning empty [DefaultCtor]
DefaultCtor defaultCtor() => new DefaultCtor();

/// Convenience returning empty [CopyCtor]
CopyCtor copyCtor() => new CopyCtor();

/// Convenience returning empty [MoveCtor]
MoveCtor moveCtor() => new MoveCtor();

/// Convenience returning empty [AssignCopy]
AssignCopy assignCopy() => new AssignCopy();

/// Convenience returning empty [AssignMove]
AssignMove assignMove() => new AssignMove();

/// Convenience returning empty [Dtor]
Dtor dtor() => new Dtor();

/// Convenience returning empty [OpEqual]
OpEqual opEqual() => new OpEqual();

/// Convenience returning empty [OpLess]
OpLess opLess() => new OpLess();

/// Convenience returning empty [OpOut]
OpOut opOut() => new OpOut();

/// Create a MemberCtor sans new, for more declarative construction
MemberCtor memberCtor([Iterable memberParms, List<String> decls]) =>
    new MemberCtor(
        memberParms == null ? [] : memberParms, decls == null ? [] : decls);

/// Standard mutex using statements
get standardMutexUsings => [using('lock', 'LOCK'), using('guard', 'GUARD')];

/// Standard mutex template additions
get standardMutexTemplateParms =>
    ['typename LOCK = std::mutex', 'typename GUARD = std::lock_guard< LOCK >'];

// end <part class>
