import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";
import "package:quiver/iterables.dart";

String _topDir;

final _logger = new Logger('ebisu_cpp');

void main() {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.toFilePath());

  Logger.root.level = Level.OFF;

  final purpose = '''
A library that supports code generation of C++ code and
supporting infrastructure. The focus is both code (e.g. classes,
enums, functions, ...)  and overall structure (cpp files, hpp
files, build scripts, test files, etc.)
''';

  _topDir = path.dirname(path.dirname(here));
  useDartFormatter = true;
  System ebisu = system('ebisu_cpp')
    ..includesHop = true
    ..license = 'boost'
    ..pubSpec.homepage = 'https://github.com/patefacio/ebisu_cpp'
    ..pubSpec.version = '0.3.7'
    ..pubSpec.doc = purpose
    ..rootPath = _topDir
    ..doc = purpose
    ..testLibraries = [
      library('test_cpp_enum'),
      library('test_cpp_member'),
      library('test_cpp_class'),
      library('test_cpp_default_methods'),
      library('test_cpp_forward_decl'),
      library('test_cpp_file'),
      library('test_cpp_interface'),
      library('test_cpp_opout'),
      library('test_cpp_method'),
      library('test_cpp_utils'),
      library('test_cpp_namer'),
      library('test_cpp_generic'),
      library('test_cpp_test_provider'),
      library('test_cpp_exception'),
      library('test_cpp_versioning'),
      library('test_cpp_switch'),
      library('test_cpp_benchmark'),
      library('test_cpp_template'),
      library('test_hdf5_support'),
      library('test_enumerated_dispatcher'),
    ]
    ..libraries = [
      library('ebisu_cpp')
        ..doc = cppLibraryDoc
        ..includesLogger = true
        ..imports = [
          'package:id/id.dart',
          'package:ebisu/ebisu.dart',
          'package:quiver/iterables.dart',
          'package:petitparser/petitparser.dart',
          "'package:path/path.dart' as path",
          'io',
          'collection',
          "'dart:math' hide max",
        ]
        ..parts = [
          part('generic')
            ..classes = [
              class_('traits')
                ..members = [
                  member('usings')
                    ..type = 'Map<String, Using>'
                    ..classInit = {},
                  member('const_exprs')
                    ..type = 'List<ConstExpr>'
                    ..classInit = [],
                ],
              class_('traits_requirements')
                ..doc =
                    'Collection of requirements for a [Traits] entry in a [TraitsFamily]'
                ..members = [
                  member('usings')
                    ..type = 'List<Id>'
                    ..access = RO,
                  member('const_exprs')
                    ..type = 'List<Id>'
                    ..access = RO,
                ],
              class_('traits_family')
                ..extend = 'CppEntity'
                ..members = [
                  member('traits_requirements')..type = 'TraitsRequirements',
                  member('traits')..type = 'List<Traits>',
                ],
            ],
          part('log_provider')
            ..classes = [
              class_('log_provider')
                ..doc = '''
Establishes an abstract interface to provide customizable c++ log messages

Not wanting to commit to a single logging solution, this class allows
client code to make certain items [Loggable] and not tie the generated
code to a particular logging solution. A default [LogProvider] that makes
use of *spdlog* is provided.
'''
                ..isAbstract = true
                ..members = [
                  member('include_requirements')..type = 'Includes',
                  member('namer')
                    ..type = 'Namer'
                    ..ctors = [''],
                ],
              class_('spdlog_provider')
                ..doc = 'Provides support for logging via spdlog'
                ..extend = 'LogProvider',
              class_('cpp_logger')
                ..doc = 'Represents a single C++ logger'
                ..extend = 'CppEntity',
              class_('loggable')
                ..doc = '''
Mixin to indicate an item is loggable.

Examples might be member accessors, member constructors, etc
'''
                ..members = [
                  member('is_logged')
                    ..doc = 'If true the [Loggable] item is logged'
                    ..classInit = false,
                ],
            ],
          part('cpp_entity')
            ..classes = [
              class_('cpp_entity')
                ..mixins = ['Entity']
                ..isAbstract = true
                ..doc = cppEntityDoc
                ..members = [
                  member('id')
                    ..doc = 'Id for the [CppEntity]'
                    ..type = 'Id',
                  member('namer')
                    ..doc = '''
CppEntity specific [Namer].

Prefer to use the [Installation] namer which is provided via [namer]
getter. It assumes the [CppEntity] is progeny of an [Installation],
which is not always the case. Use in cases where not - e.g. creating
content without being tied to an installation - this can be used.
'''
                    ..access = IA
                    ..type = 'Namer',
                  member('includes')
                    ..doc = 'List of includes required by this entity'
                    ..type = 'Includes'
                    ..access = RO
                    ..classInit = 'new Includes()',
                ],
            ],
          part('using')
            ..classes = [
              class_('using')
                ..doc = 'Object corresponding to a using statement'
                ..extend = 'CppEntity'
                ..members = [
                  member('rhs')
                    ..doc = '''
The right hand side of using (ie the type decl being named)'''
                    ..access = RO,
                  member('template')
                    ..doc = 'Template associated with the using (C++11)'
                    ..type = 'Template'
                    ..access = RO,
                ],
            ],
          part('pointer')
            ..doc = 'Deals with pointers and references'
            ..enums = [
              enum_('ref_type')
                ..doc = 'Reference type'
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('ref'))
                    ..doc = 'Indicates a reference to type: *T &*',
                  enumValue(id('cref'))
                    ..doc = 'Indicates a const reference to type: *T const&*',
                  enumValue(id('vref'))
                    ..doc =
                        'Indicates a volatile reference to type: *T volatile&*',
                  enumValue(id('cvref'))
                    ..doc =
                        'Indicates a const volatile reference to type: *T const volatile&*',
                  enumValue(id('value'))..doc = 'Indicates not a reference'
                ],
              enum_('ptr_type')
                ..doc = 'Standard pointer type declaration'
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('ptr'))
                    ..doc = 'Indicates a *naked* or *dumb* pointer - T*',
                  enumValue(id('cptr'))
                    ..doc = 'Indicates a *naked* or *dumb* pointer - T const *',
                  enumValue(id('sptr'))
                    ..doc = 'Indicates *std::shared_ptr< T >*',
                  enumValue(id('uptr'))
                    ..doc = 'Indicates *std::unique_ptr< T >*',
                  enumValue(id('scptr'))
                    ..doc = 'Indicates *std::shared_ptr< const T >*',
                  enumValue(id('ucptr'))
                    ..doc = 'Indicates *std::unique_ptr< const T >*',
                ],
            ],
          part('access')
            ..doc = 'Focuses on stylized *access* and standard C++ access'
            ..enums = [
              enum_('access')
                ..doc = accessDoc
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('ia'))
                    ..doc =
                        '**Inaccessible**. Designates a member that is *private* by default and no accessors',
                  enumValue(id('ro'))
                    ..doc =
                        '**Read-Only**. Designates a member tht is *private* by default and a read accessor',
                  enumValue(id('rw'))
                    ..doc =
                        '**Read-Write**. Designates a member tht is *private* by default and both read and write accessors',
                  enumValue(id('wo'))
                    ..doc = '''
**Write-Only**. Designates a member tht is *private* by default and
write accessor only.  Useful if you want the standard write accessor
but a custom reader.''',
                ],
              enum_('cpp_access')
                ..doc = '''
Cpp access designations:

  * public
  * private
  * protected

This designation is used in multiple contexts such as:

  * Overriding the protection of a member
  * On *Base* instances to indicate the access associated with inheritance
  * On class methods (ctor, dtor, ...) to designate access
'''
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('public'))..doc = 'C++ public designation',
                  enumValue(id('protected'))..doc = 'C++ protected designation',
                  enumValue(id('private'))..doc = 'C++ private designation',
                ],
            ],
          part('utils')
            ..classes = [
              class_('const_expr')
                ..doc = """
Simple variable constexprs.

      print(new ConstExpr('secret', 42));
      print(new ConstExpr(new Id('voo_doo'), 'foo'));
      print(new ConstExpr('pi', 3.14));

prints:

    constexpr int Secret { 42 };
    constexpr char const* Voo_doo { "foo" };
    constexpr double Pi { 3.14 };
"""
                ..extend = 'CppEntity'
                ..members = [
                  member('type')..doc = 'The c++ type of the constexpr',
                  member('value')
                    ..doc = 'The initialization for the constexpr'
                    ..type = 'Object'
                    ..access = IA,
                  member('namespace')
                    ..doc = 'Any namespace to wrap the constexpr in'
                    ..type = 'Namespace',
                  member('is_class_scoped')
                    ..doc = 'If class scoped the expr should be static'
                    ..classInit = false,
                  member('is_hex')
                    ..doc = '''
If true and literal is numeric it is assigned as hex.
The idea is to make C++ more readable when large constants are used.
'''
                    ..classInit = false,
                ],
              class_('forward_decl')
                ..doc = 'A forward class declaration'
                ..hasCtorSansNew = true
                ..members = [
                  member('doc')..doc = 'Forward declaration documentation',
                  member('type')
                    ..doc = 'The c++ type being forward declared'
                    ..ctors = [''],
                  member('namespace')
                    ..doc =
                        'The namespace to which the class being forward declared belongs'
                    ..type = 'Namespace'
                    ..ctorsOpt = [''],
                  member('template')
                    ..doc =
                        'A template associated with the forward declared class'
                    ..type = 'Template'
                    ..ctorsOpt = [''],
                ],
              class_('code_generator')
                ..doc = 'Establishes an interface for generating code'
                ..isAbstract = true,
              class_('friend_class_decl')
                ..doc = 'Friend class declaration'
                ..isImmutable = true
                ..hasCtorSansNew = true
                ..members = [
                  member('decl')
                    ..doc =
                        'Declaration text without the *friend* and *class* keywords'
                ],
              class_('namespace')
                ..doc =
                    'Represents a c++ namespace which is essentially a list of names'
                ..members = [
                  member('names')
                    ..doc = 'The individual names in the namespace'
                    ..type = 'List<String>'
                    ..classInit = [],
                ],
              class_('using_namespace')
                ..doc = 'A using namespace statement'
                ..members = [
                  member('namespace')
                    ..doc = '''
May be constructed with a [Namespace] instance or string representing
the namespace as appears in code:

    ..usingNamespaces = [
      usingNamespace('std'),
      usingNamespace(namespace(['x','y'])),
      usingNamespace('foo::bar::goo', 'fbg'),
    ]
'''
                    ..type = 'Namespace',
                  member('alias')..doc = 'Optional alias for the namespace',
                ],
              class_('includes')
                ..doc = 'Collection of header includes'
                ..members = [
                  member('included')
                    ..doc = 'Set of strings representing the includes'
                    ..access = RO
                    ..type = 'Set<String>'
                ],
              class_('namer')
                ..doc = 'Provides support for consistent naming of C++ entities'
                ..isAbstract = true,
              class_('ebisu_cpp_namer')
                ..implement = ['Namer']
                ..doc = '''
Default namer establishing reasonable conventions, that are fairly
*snake* case heavy like the STL.
''',
              class_('google_namer')
                ..implement = ['Namer']
                ..doc = 'Namer based on google coding conventions',
              class_('base')
                ..doc = baseDoc
                ..hasCtorSansNew = true
                ..members = [
                  member('class_name')
                    ..doc = 'The name of the class being derived from'
                    ..ctors = [''],
                  member('access')
                    ..doc = 'Is base class public, protected, or private'
                    ..type = 'CppAccess'
                    ..classInit = 'public',
                  member('init')
                    ..doc =
                        'How to initiailize the base class in ctor initializer',
                  member('is_virtual')
                    ..doc = 'If true inheritance is virtual'
                    ..classInit = false,
                  member('is_streamable')
                    ..doc =
                        'If true and streamers are being provided, base is streamed first'
                    ..classInit = false,
                ]
            ],
          part('file')
            ..classes = [
              class_('cpp_file')
                ..doc = '''
Establishes an interface and common elements for c++ file, such as
*Header* and *Impl*.'''
                ..isAbstract = true
                ..extend = 'CppEntity'
                ..mixins = ['Testable']
                ..members = [
                  member('namespace')
                    ..doc = 'Namespace associated with this file'
                    ..type = 'Namespace',
                  member('custom_blocks')
                    ..doc = '''
List of blocks requiring custom code and therefore inserted into the
file with *Protect Blocks*. Note it is a list of *FileCodeBlock*
enumeration values. *CodeBlocks* can be used to inject code into
the location designated by their value. Additionally *CodeBlocks*
have support for a single custom *Protect Block*'''
                    ..type = 'List<FileCodeBlock>'
                    ..classInit = [],
                  member('code_blocks')
                    ..doc = '''
Mapping of the *FileCodeBlock* to the corresponding *CodeBlock*.'''
                    ..type = 'Map<FileCodeBlock, CodeBlock>'
                    ..access = IA
                    ..classInit = {},
                  member('classes')
                    ..doc =
                        'List of classes whose definitions are included in this file'
                    ..type = 'List<Class>'
                    ..classInit = [],
                  member('const_exprs')
                    ..doc =
                        'List of c++ *constexprs* that will appear near the top of the file'
                    ..type = 'List<ConstExpr>'
                    ..classInit = [],
                  member('forward_decls')
                    ..doc =
                        'List of forward declarations that will appear near the top of the file'
                    ..type = 'List<ForwardDecl>'
                    ..classInit = [],
                  member('usings')
                    ..doc =
                        'List of using statements that will appear near the top of the file'
                    ..type = 'List<Using>'
                    ..access = RO
                    ..classInit = [],
                  member('enums')
                    ..doc =
                        'List of enumerations that will appear near the top of the file'
                    ..type = 'List<Enum>'
                    ..classInit = [],
                  member('interfaces')
                    ..doc = '''
List of interfaces for this header. Interfaces result in either:

* abstract base class with pure virtual methods
* static polymorphic base class with inline forwarding methods
'''
                    ..type = 'List<Interface>'
                    ..classInit = [],
                  member('basename')..access = RO,
                  member('file_path')..access = RO,
                  member('standardized_inclusions')
                    ..doc = '''
A list of [StandardizedHeader] indexed bool values indicating desire
to include/exclude given header.
'''
                    ..type = 'Map<StandardizedHeader, bool>'
                    ..access = IA
                    ..classInit = {},
                  member('include_stack_trace')
                    ..doc = '''
If true includes comment about code being generated as well as a stack
trace to help find the dart code that generated the source.
'''
                    ..access = WO
                    ..type = 'bool',
                ],
            ],
          part('template')
            ..doc = '''
Classes to facilitate generating C++ template code
'''
            ..enums = [
              enum_('template_parm_type')
                ..values = [
                  enumValue('type')
                    ..doc = 'Indicates the template parameter names a type',
                  enumValue('non_type')
                    ..doc =
                        '''Indicates the template parameter indicates a non-type
(e.g. *MAX_SIZE = 10* - a constant literal)''',
                ],
            ]
            ..classes = [
              class_('template_parm')
                ..isAbstract = true
                ..extend = 'CppEntity',
              class_('raw_template_parm')
                ..doc = 'Unparsed text template parm'
                ..extend = 'TemplateParm'
                ..members = [
                  member('type_id'),
                  member('text')..doc = 'Text for the template parm'
                ],
              class_('type_template_parm')
                ..extend = 'TemplateParm'
                ..members = [member('default_type'),],
              class_('non_type_template_parm')
                ..extend = 'TemplateParm'
                ..members = [
                  member('type')..doc = 'Type of the parm',
                  member('default_value'),
                ],
              class_('template_grammar')..extend = 'GrammarParser',
              class_('template_grammar_definition')
                ..extend = 'GrammarDefinition',
              class_('template_parser')..extend = 'GrammarParser',
              class_('template_parser_definition')
                ..extend = 'TemplateGrammarDefinition',
              class_('template')
                ..extend = 'CppEntity'
                ..doc = '''
Represents a template declaration comprized of a list of [decls]
'''
                ..members = [member('parms')..type = 'List<TemplateParm>',],

              class_('template_specialization')
              ..doc = 'Specifies a set of specialization template parameters'
              ..members = [
                member('parms')..type = 'List<String>',
              ]
            ],
          part('enum')
            ..classes = [
              class_('enum_value')
                ..extend = 'CppEntity'
                ..doc =
                    'Name value pairs for entries in a enum - when default values will not cut it'
                ..members = [
                  member('value')
                    ..type = 'dynamic'
                    ..access = RO,
                  member('name')..access = RO,
                ],
              class_('enum')
                ..doc = enumDoc
                ..extend = 'CppEntity'
                ..members = [
                  member('values')
                    ..doc = '''
Value entries of the enum.

Support for assignment from string, or id implies default values.

'''
                    ..type = 'List<EnumValue>'
                    ..access = RO,
                  member('ids')
                    ..doc = 'Ids for the values of the enum'
                    ..type = 'List<Id>'
                    ..access = IA,
                  member('value_names')
                    ..doc = 'Names for values as they appear'
                    ..type = 'List<String>'
                    ..access = IA,
                  member('is_class')
                    ..doc =
                        'If true the enum is a class enum as opposed to "plain" enum'
                    ..classInit = false,
                  member('enum_base')
                    ..doc = 'Base of enum - if set must be an integral type',
                  member('has_from_c_str')
                    ..doc = 'If true adds from_c_str method'
                    ..classInit = false,
                  member('has_to_c_str')
                    ..doc = 'If true adds to_c_str method'
                    ..classInit = false,
                  member('is_streamable')
                    ..doc = 'If true adds streaming support'
                    ..classInit = false,
                  member('is_mask')
                    ..doc = '''
If true the values are powers of two for bit masking.

When specifying values for a mask specify the *bit* associated with
the value.

    final sample_mask = enum_('mask_green_bit_specified')
      ..isClass = true
      ..values = ['red', enumValue('green', 5), 'blue']
      ..isMask = true;

And *print(sample_mask)* gives:

    enum class Mask_with_green_bit_specified {
      Red_e = 1 << 0,
      Green_e = 1 << 5,
      Blue_e = 1 << 2
    };
'''
                    ..classInit = false,
                  member('has_bitmask_functions')
                    ..doc = '''
If set provides test, set and clear methods.
'''
                    ..classInit = false,
                  member('is_nested')
                    ..doc =
                        'If true is nested in class and requires *friend* stream support'
                    ..classInit = false,
                  member('is_displayed_hex')
                    ..doc = '''
If the map has values assigned by user, this can be used to display
them in the enum as hex'''
                    ..classInit = false,
                ],
            ],
          part('member')
            ..classes = [
              class_('member')
                ..doc = memberDoc
                ..extend = 'CppEntity'
                ..members = [
                  member('type')..doc = 'Type of member',
                  member('init')
                    ..doc = memberInitDoc
                    ..access = RO,
                  member('ctor_init')
                    ..doc = '''
Rare usage - member b depends on member a (e.g. b is just a string rep of a
which is int), a is passed in for construction but b can be initialized directly
from a. If ctorInit is set on a member, any memberCtor will include this text to
initialize it''',
                  member('access')
                    ..doc = 'Idiomatic access of member'
                    ..type = 'Access'
                    ..access = WO,
                  member('cpp_access')
                    ..doc = 'C++ style access of member'
                    ..type = 'CppAccess'
                    ..access = WO,
                  member('ref_type')
                    ..doc = 'Ref type of member'
                    ..type = 'RefType'
                    ..classInit = 'value',
                  member('is_by_ref')
                    ..doc = 'Pass member around by reference'
                    ..type = 'bool'
                    ..access = WO,
                  member('is_static')
                    ..doc = 'Is the member static'
                    ..classInit = false,
                  member('is_mutable')
                    ..doc = 'Is the member mutable'
                    ..classInit = false,
                  member('is_const')
                    ..doc = 'Is the member const'
                    ..classInit = false
                    ..access = WO,
                  member('is_const_expr')
                    ..doc = 'Is the member a constexprt'
                    ..classInit = false,
                  member('has_no_init')
                    ..doc =
                        'If set will not initialize variable - use sparingly'
                    ..classInit = false,
                  member('is_serialized_as_int')
                    ..doc =
                        'Indicates this member is an enum and if serialized should be serialized as int'
                    ..classInit = false,
                  member('is_cereal_transient')
                    ..doc =
                        'Indicates this member should not be serialized via cereal'
                    ..classInit = false,
                  member('getter_return_modifier')
                    ..doc = getterReturnModifierDoc
                    ..type = 'GetterReturnModifier',
                  member('custom_block')
                    ..doc = '''
A single customBlock that will be injected in the public section
of the owning class. For example, if generating code that needs
special getters/setters (e.g. atypical coding pattern) then the
member could be set with *access = ro* and custom accessors may
be provided.
'''
                    ..type = 'CodeBlock'
                    ..classInit = 'new CodeBlock(null)',
                  member('getter_creator')
                    ..doc = '''
Will create the getter. To provide custom getter implement
GetterCreator and assign
'''
                    ..type = 'GetterCreator',
                  member('setter_creator')
                    ..doc = '''
Will create the setter. To provide custom setter implement
SetterCreator and assign'''
                    ..type = 'SetterCreator',
                  member('is_streamable')
                    ..doc = '''
Indicates member should be streamed if class is streamable.
One of the few flags defaulted to *true*, this flag provides
an opportunity to *not* stream specific members'''
                    ..classInit = true,
                  member('custom_streamable')
                    ..doc = '''
If not-null a custom streamable block. Use this to either hand code or
generate a streamable entry in the containing [Class].
'''
                    ..type = 'CodeBlock'
                    ..access = RO,
                  member('ifdef_qualifier')
                    ..doc = '''
If non null member and accessors will qualified in #if defined block
'''
                ],
              class_('getter_creator')
                ..doc =
                    'Responsible for creating the getter (i.e. reader) for member'
                ..isAbstract = true
                ..members = [
                  member('member')
                    ..doc = 'Member this creator will create getter for'
                    ..type = 'Member'
                    ..ctors = ['']
                ],
              class_('standard_getter_creator')..extend = 'GetterCreator',
              class_('setter_creator')
                ..doc =
                    'Responsible for creating the setter (i.e. writer) for member'
                ..isAbstract = true
                ..members = [
                  member('member')
                    ..doc = 'Member this creator will create setter for'
                    ..type = 'Member'
                    ..ctors = ['']
                ],
              class_('standard_setter_creator')..extend = 'SetterCreator',
            ],
          part('control_flow')
            ..classes = [
              class_('switch')
                ..ctorCustoms = ['']
                ..members = [
                  member('switch_value')
                    ..doc = 'Text repesenting the value to be switched on'
                    ..ctors = [''],
                  member('cases')
                    ..type = 'List<int>'
                    ..classInit = []
                    ..ctors = [''],
                  member('on_case')
                    ..doc = 'Function for providing a block for *case*'
                    ..type = 'CaseFunctor'
                    ..ctors = [''],
                  member('on_default')
                    ..doc = '''
Block of text for the default case.

Break will be provided. If default case is a one or more statements
client must provide semicolons.
'''
                    ..ctorsOpt = [''],
                  member('is_char')
                    ..doc = 'If cases should be interpreted as char'
                    ..type = 'bool'
                    ..ctorsOpt = [''],
                ],
            ],
          part('class')
            ..enums = [
              enum_('class_code_block')
                ..doc = classCodeBlockDoc
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('cls_open'))
                    ..doc =
                        'The custom block appearing just after class is opened',
                  enumValue(id('cls_public_begin'))
                    ..doc =
                        'The custom block appearing at start *public* section',
                  enumValue(id('cls_public'))
                    ..doc =
                        'The custom block appearing in the standard *public* section',
                  enumValue(id('cls_public_end'))
                    ..doc =
                        'The custom block appearing at end *public* section',
                  enumValue(id('cls_protected_begin'))
                    ..doc =
                        'The custom block appearing at start *protected* section',
                  enumValue(id('cls_protected'))
                    ..doc =
                        'The custom block appearing in the standard *protected* section',
                  enumValue(id('cls_protected_end'))
                    ..doc =
                        'The custom block appearing at end *protected* section',
                  enumValue(id('cls_private_begin'))
                    ..doc =
                        'The custom block appearing at start *private* section',
                  enumValue(id('cls_private'))
                    ..doc =
                        'The custom block appearing in the standard *private* section',
                  enumValue(id('cls_private_end'))
                    ..doc =
                        'The custom block appearing at end *private* section',
                  enumValue(id('cls_close'))
                    ..doc =
                        'The custom block appearing just before class is closed',
                  enumValue(id('cls_pre_decl'))
                    ..doc =
                        'The custom block appearing just before the class definition',
                  enumValue(id('cls_post_decl'))
                    ..doc =
                        'The custom block appearing just after the class definition',
                ],
            ]
            ..classes = [
              class_('class_method')
                ..doc = '''
Establishes an interface for generated class methods like
consructors, destructors, overloaded operators, etc.
'''
                ..isAbstract = true
                ..mixins = ['Loggable', 'CustomCodeBlock']
                ..members = [
                  member('parent')
                    ..type = 'Class'
                    ..access = RO,
                  member('is_logged')
                    ..doc = 'If true add logging'
                    ..classInit = false,
                  member('template')
                    ..type = 'Template'
                    ..access = RO,
                  member('cpp_access')
                    ..doc = 'C++ style access of method'
                    ..type = 'CppAccess'
                    ..classInit = 'public',
                  member('top_inject')
                    ..doc = '''
Code snippet to inject at beginning of method. The intent is for the
methods to have standard generated implementations, but to also
support programatic injection of implmementation into the
methods. This supports injection near the top of the method.'''
                    ..classInit = '',
                  member('bottom_inject')
                    ..doc = '''
Supports injecting code near the bottom of the method. *See*
*topInject*'''
                    ..classInit = '',
                  member('includes_protect_block')
                    ..doc = r'''
If set will include protection block for hand-coding in method.

Normally an a class mixing in [CustomCodeBlock] would provide a setter
[includesProtectBlock] that would set the [tag] field of the [CodeBlock] mixed
in by the [CustomCodeBlock] to some unique name. For example, [Class] has an
[includesProtectBlock] that sets the [tag] to 'class $name'.

In the case of [ClassMethod] the owning [Class] is not usually established early
on so there is no easy way to name the protect block when the [ClassMethod] is
constructed. This member is used to track the request to include a protection
block and tagging is deferred until needed.
'''
                    ..classInit = false,
                  member('doc')..doc = 'Method documentation',
                  member('is_no_except')
                    ..doc = 'If true the method is noexcept(true)'
                    ..classInit = false,
                ],
              class_('default_method')
                ..doc = '''
Unifies the [ClassMethod]s that can be specified as *default*,
like [DefaultCtor], [CopyCtor], etc.

Also provides for *delete*d methods.
'''
                ..isAbstract = true
                ..extend = 'ClassMethod'
                ..members = [
                  member('uses_default')..classInit = false,
                  member('has_delete')..classInit = false,
                ],
              class_('default_ctor')
                ..doc = 'Default ctor, autoinitialized on read'
                ..extend = 'DefaultMethod',
              class_('copy_ctor')
                ..doc = 'Copy ctor, autoinitialized on read'
                ..extend = 'DefaultMethod',
              class_('move_ctor')
                ..doc = 'Move ctor, autoinitialized on read'
                ..extend = 'DefaultMethod',
              class_('assign_copy')..extend = 'DefaultMethod',
              class_('assign_move')..extend = 'DefaultMethod',
              class_('dtor')
                ..doc = 'Provides a destructor'
                ..extend = 'DefaultMethod'
                ..members = [member('is_abstract')..classInit = false],
              class_('member_ctor_parm')
                ..doc = memberCtorParmDoc
                ..hasCtorSansNew = true
                ..members = [
                  member('name')
                    ..doc =
                        'Name of member initialized by argument to member ctor'
                    ..isFinal = true
                    ..ctors = [''],
                  member('member')
                    ..doc = 'cpp member to be initialized'
                    ..type = 'Member',
                  member('parm_decl')
                    ..doc = '''
*Override* for arguemnt declaration. This is rarely needed. Suppose
you want to initialize member *Y y* from an input argument *X x* that
requires a special function *f* to do the conversion:

    Class(X x) : y_ {f(x)}

Which would be achieved by:

    memberCtor([
      memberCtorParm("y")
      ..parmDecl = "X x"
      ..init = "f(x)"
    ])

''',
                  member('init')
                    ..doc = memberCtorInitDoc
                    ..access = WO,
                  member('default_value')
                    ..doc = '''
If set provides a default value for the parm in the ctor. For example:

    memberCtorParm('x')..defaultValue = '42'

where the type of member *x* is *int* might yield:

    Cls(int x = 42) : x_{x}

''',
                ],
              class_('member_ctor')
                ..doc = '''
Specificication for a member constructor. A member constructor is a constructor
with the intent of initializing one or more members of a class.

Assumig a class has members *int x* and *int y*
*memberCtor(["x", "y"])*

would generate the corresponding:

    Class(int x, int y) : x_{x}, y_{y} {}

If custom logic is additionally required, set the *hasCustom* flag to include a
custom block. In that case the class might look like:

    Class(int x, int y) : x_{x}, y_{y} {
      // custom <Class>
      // end <Class>
    }
'''
                ..extend = 'ClassMethod'
                ..members = [
                  member('member_parms')
                    ..doc =
                        'List of members that are passed as arguments for initialization'
                    ..type = 'List<MemberCtorParm>'
                    ..classInit = [],
                  member('decls')
                    ..doc = 'List of additional decls ["Type Argname", ...]'
                    ..type = 'List<String>',
                  member('has_all_members')
                    ..doc = 'If set automatically includes all members as args'
                    ..classInit = false,
                  member('is_explicit')
                    ..doc = 'If true makes the ctor explicit'
                    ..classInit = false,
                ],
              class_('op_equal')
                ..doc = 'Provides *operator==()*'
                ..extend = 'ClassMethod',
              class_('op_less')
                ..doc = 'Provides *operator<()*'
                ..extend = 'ClassMethod',
              class_('op_out')
                ..doc = 'Provides *operator<<()*'
                ..extend = 'ClassMethod'
                ..members = [
                  member('uses_nested_indent')
                    ..doc = '''
If true uses tls indentation tracking to indent nested
components when streaming'''
                    ..classInit = false
                ],
              class_('class')
                ..doc = classDoc
                ..extend = 'CppEntity'
                ..mixins = ['Testable']
                ..members = [
                  member('definition')
                    ..doc = '''
The contents of the class definition. *Inaccessible* and established
as a member so custom *definition* getter can be called multiple times
on the same class and results lazy-inited here'''
                    ..access = IA,
                  member('is_struct')
                    ..doc = 'Is this definition a *struct*'
                    ..classInit = false,
                  member('template')
                    ..doc = 'The template by which the class is parameterized'
                    ..type = 'Template'
                    ..access = RO,
                  member('template_specialization')
                  ..doc = '''
A template specialization associated with the class.  Use this when
the class is a template specialization. If class is a partial template
specialization, use both [template] and [templateSpecialization].
'''
                  ..type = 'TemplateSpecialization',
                  member('forward_decls')
                    ..doc =
                        'Forward declarations near top of file, before the class definition'
                    ..type = 'List<ForwardDecl>'
                    ..classInit = [],
                  member('class_forward_decls')
                    ..doc =
                        'Forward declarations within class, ideal for forward declaring nested classes'
                    ..type = 'List<ForwardDecl>'
                    ..classInit = [],
                  member('const_exprs')
                    ..doc = '*constexpr*s associated with the class'
                    ..type = 'List<ConstExpr>'
                    ..classInit = [],
                  member('usings')
                    ..doc = '''
List of usings that will be scoped to this class near the top of
the class definition.'''
                    ..type = 'List<Using>'
                    ..access = RO
                    ..classInit = [],
                  member('usings_post_decl')
                    ..doc = '''
List of usings to occur after the class declaration. Sometimes it is
useful to establish some type definitions directly following the class
so they may be reused among any client of the class. For instance if
class *Foo* will most commonly be used in vector, the using occuring
just after the class definition will work:

    using Foo = std::vector<Foo>;

'''
                    ..type = 'List<Using>'
                    ..classInit = []
                    ..access = RO,
                  member('bases')
                    ..doc = '''
Base classes this class derives form.
'''
                    ..type = 'List<Base>'
                    ..classInit = [],
                  member('default_ctor')
                    ..doc = 'The default constructor'
                    ..type = 'DefaultCtor'
                    ..access = IA,
                  member('copy_ctor')
                    ..doc = 'The copy constructor'
                    ..type = 'CopyCtor'
                    ..access = IA,
                  member('move_ctor')
                    ..doc = 'The move constructor'
                    ..type = 'MoveCtor'
                    ..access = IA,
                  member('assign_copy')
                    ..doc = 'The assignment operator'
                    ..type = 'AssignCopy'
                    ..access = IA,
                  member('assign_move')
                    ..doc = 'The assignment move operator'
                    ..type = 'AssignMove'
                    ..access = IA,
                  member('dtor')
                    ..doc = 'The destructor'
                    ..type = 'Dtor'
                    ..access = IA,
                  member('member_ctors')
                    ..doc = 'A list of member constructors'
                    ..type = 'List<MemberCtor>'
                    ..classInit = [],
                  member('op_equal')
                    ..type = 'OpEqual'
                    ..access = IA,
                  member('op_less')
                    ..type = 'OpLess'
                    ..access = IA,
                  member('op_out')
                    ..type = 'OpOut'
                    ..access = IA,
                  member('forward_ptrs')
                    ..type = 'List<PtrType>'
                    ..classInit = [],
                  member('enums_forward')
                    ..type = 'List<Enum>'
                    ..classInit = [],
                  member('enums')
                    ..type = 'List<Enum>'
                    ..classInit = [],
                  member('members')
                    ..type = 'List<Member>'
                    ..classInit = [],
                  member('friend_class_decls')
                    ..type = 'List<FriendClassDecl>'
                    ..classInit = [],
                  member('custom_blocks')
                    ..type = 'List<ClassCodeBlock>'
                    ..classInit = [],
                  member('is_singleton')..classInit = false,
                  member('is_noncopyable')
                    ..doc = 'If true deletes copy ctor and assignment operator'
                    ..classInit = false,
                  member('code_blocks')
                    ..access = RO
                    ..type = 'Map<ClassCodeBlock, CodeBlock>'
                    ..classInit = {},
                  member('uses_streamers')
                    ..doc = '''
If true adds {using fcs::utils::streamers::operator<<} to streamer.
Also, when set assumes streaming required and [isStreamable]
is *set* as well. So not required to set both.
'''
                    ..access = RO
                    ..classInit = false,
                  member('is_final')
                    ..doc = 'If true adds final keyword to class'
                    ..classInit = false,
                  member('is_immutable')
                    ..doc = '''
If true makes all members const provides single member ctor
initializing all.

There are a few options to achieve *immutable* support. The first is
this type, where all fields are constant and therefore must be
initialized. An alternative concept is immutable from perspective of
user. This can be achieved with use of [addFullMemberCtor] and the
developer ensuring the members are not modified. This provides a
stronger guarantee of immutability.'''
                    ..classInit = false,
                  member('serializers')
                    ..doc =
                        'List of processors supporting flavors of serialization'
                    ..type = 'List<Serializer>'
                    ..classInit = [],
                  member('interface_implementations')
                    ..doc = ''
                    ..type = 'List<InterfaceImplementation>'
                    ..access = RO
                    ..classInit = [],
                  member('methods')
                    ..doc = '''
The [Method]s that are implemented by this [Class]. A [Class]
implements the union of methods in its
[interfaceimplementations]. Each [Method] is identified by its
qualified id *string* which is:

   interface.method_name.signature

Lookup is done by pattern match.
'''
                    ..type = 'Map<String, Method>'
                    ..access = IA
                    ..classInit = {},
                  member('cpp_access')
                    ..doc =
                        'A [CppAccess] specifier - only pertinent if class is nested'
                    ..type = 'CppAccess'
                    ..classInit = 'public',
                  member('nested_classes')
                    ..doc = 'Classes nested within this class'
                    ..type = 'List<Class>'
                    ..classInit = [],
                  member('pack_align')
                    ..doc = r'''
If set, will include *#pragma pack(push, $packAlign)* before the class
and *#pragma pack(pop)* after.
'''
                    ..type = 'int',
                  member('default_member_access')
                    ..doc =
                        'If set and member has no [access] set, this is used'
                    ..type = 'Access',
                  member('default_cpp_access')
                    ..doc =
                        'If set and member has no [cppAccess] set, this is used'
                    ..type = 'CppAccess',
                ],
            ],
          part('method')
            ..classes = [
              class_('parm_decl')
                ..doc = r"""
A parameter declaration.

Method signatures consist of a List of [ParmDecl] and a return type.
[ParmDecl]s may be constructed from declaration text:

      var pd = new ParmDecl.fromDecl('std::vector< std::vector < double > > matrix');
      print('''
    id    => ${pd.id} (${pd.id.runtimeType})
    type  => ${pd.type}
    ''');

prints:

    id    => matrix (Id)
    type  => std::vector< std::vector < double > >

[ParmDecl]s may be constructed with Id, declaratively:

      var pd = new ParmDecl('matrix')
        ..type = 'std::vector< std::vector < double > >';

      print('''
    id    => ${pd.id} (${pd.id.runtimeType})
    type  => ${pd.type}
    ''');

prints:

    id    => matrix (Id)
    type  => std::vector< std::vector < double > >
"""
                ..extend = 'CppEntity'
                ..members = [member('type'),],
              class_('method_decl')
                ..doc = r"""
A method declaration, which consists of a List of [ParmDecl] (i.e. the
parameters) and a [returnType]

[MethodDecl]s may be constructed from declaration text:

      var md = new MethodDecl.fromDecl('Row_list_t find_row(std::string s)');
      print(md);

prints:

    Row_list_t find_row(std::string s) {
    // custom <find_row>
    // end <find_row>

    }

[MethodDecl]s may be constructed with [id] declaratively:

  var md = new MethodDecl('find_row')
    ..parmDecls = [ new ParmDecl.fromDecl('std::string s') ]
    ..returnType = 'Row_list_t';

prints:

Row_list_t find_row(std::string s) {
// custom <find_row>
// end <find_row>

}
"""
                ..extend = 'CppEntity'
                ..members = [
                  member('template')
                    ..doc = 'The template by which the method is parameterized'
                    ..type = 'Template',
                  member('parm_decls')
                    ..type = 'List<ParmDecl>'
                    ..classInit = [],
                  member('return_type'),
                  member('is_const')
                    ..doc = 'True if this [MethodDecl] is *const*'
                    ..classInit = false
                ],
              class_('method')
                ..doc = '''
A [Method] represents a single class method that will be *owned* by
the class implementing it. A [Method] method is *owned* by a single
class and therefore has an implementation defined in that class. The
[Method] *has a* signature which it refers to via
[MethodDecl]. [Method] will have its own [CodeBlock] for purpose of
allowing custom code and code insertion.

When defining a class, declaratively or otherwise, [Method]s are
created and owned by the [Class] based on the [implementedInterfaces]
specified. To access the [CodeBlock] of a [Method] in a [Class], use
the [getMethod] function.
'''
                ..members = [
                  member('method_decl')..type = 'MethodDecl',
                  member('code_block')..type = 'CodeBlock',
                  //// TODO: figure best way to support final methods
                  // member('is_final')
                  // ..doc = 'If true adds final keyword to method'
                  // ..classInit = false,
                ],
              class_('interface')
                ..doc = interfaceDoc
                ..extend = 'CppEntity'
                ..members = [
                  member('method_decls')
                    ..type = 'List<MethodDecl>'
                    ..access = RO
                    ..classInit = [],
                ],
              class_('interface_implementation')
                ..doc =
                    'An [interface] with a [CppAccess] to be implemented by a [Class]'
                ..extend = 'CppEntity'
                ..members = [
                  member('interface')..type = 'Interface',
                  member('cpp_access')
                    ..type = 'CppAccess'
                    ..classInit = 'public',
                  member('is_virtual')
                    ..doc = 'If true the interface is virtual'
                    ..classInit = false
                ],
            ],
          part('exception')
            ..doc = 'Support for creating standard based exception hierarchies'
            ..classes = [
              class_('exception_class')
                ..doc = '''
Creates a new *exception* class derived from std::exception.
'''
                ..extend = 'Class'
                ..members = [
                  member('base_exception')
                    ..doc = 'Base class for this exception class',
                  member('exception_includes')
                    ..doc = 'Additional includes required for exception class'
                    ..type = 'List<String>'
                    ..classInit = [],
                ]
            ],
          part('serializer')
            ..enums = [
              enum_('serialization_style')
                ..doc =
                    'Serialization using *cereal* supports these types of serialization'
                ..hasLibraryScopedValues = true
                ..values = [
                  id('json_serialization'),
                  id('xml_serialization'),
                  id('binary_serialization'),
                ]
            ]
            ..classes = [
              class_('serializer')
                ..doc = 'Establishes an interface for instance serialization'
                ..isAbstract = true,
              class_('dsv_serializer')
                ..doc =
                    'Provides support for serialization as *delimited separated values*'
                ..implement = ['Serializer']
                ..members = [member('delimiter')..classInit = ':',],
              class_('cereal')
                ..doc = 'Adds support for serialization using *cereal*'
                ..implement = ['Serializer']
                ..members = [
                  member('styles')
                    ..type = 'List<SerializationStyle>'
                    ..classInit = [],
                ],
            ],
          part('header')
            ..classes = [
              class_('header')
                ..doc = 'A single c++ header'
                ..extend = 'CppFile'
                ..members = [],
            ],
          part('impl')
            ..classes = [
              class_('impl')
                ..doc = 'A single implementation file (i.e. *cpp* file)'
                ..extend = 'CppFile'
                ..members = []
            ],
          part('test_provider')
            ..enums = [
              enum_('tc_code_block')
                ..doc = '''
The various supported code blocks associated with *TestClause*.
The *TestClauses* are modeled after the *Catch* library *BDD* approach.
'''
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('tc_open'))
                    ..doc =
                        'The custom block appearing at the start of the clause',
                  enumValue(id('tc_close'))
                    ..doc =
                        'The custom block appearing at the end of the clause',
                ],
            ]
            ..classes = [
              class_('test_clause')
                ..isAbstract = true
                ..extend = 'CppEntity'
                ..doc = '''
Models common elements of the *Given*, *When*, *Then* clauses.
Each *TestClause* has its own [clause] text associated with it
and [CodeBlock]s to augment/initialize/teardown.
'''
                ..members = [
                  member('pre_code_block')
                    ..type = 'CodeBlock'
                    ..classInit = 'new CodeBlock(null)',
                  member('start_code_block')
                    ..type = 'CodeBlock'
                    ..classInit = 'new CodeBlock(null)',
                  member('end_code_block')
                    ..type = 'CodeBlock'
                    ..classInit = 'new CodeBlock(null)',
                  member('post_code_block')
                    ..type = 'CodeBlock'
                    ..classInit = 'new CodeBlock(null)',
                ],
              class_('then')
                ..extend = 'TestClause'
                ..members = [member('is_and')..classInit = false],
              class_('when')
                ..extend = 'TestClause'
                ..members = [member('thens')..type = 'List<Then>'],
              class_('given')
                ..extend = 'TestClause'
                ..members = [
                  member('whens')..type = 'List<When>',
                  member('thens')..type = 'List<Then>',
                ],
              class_('test_scenario')
                ..extend = 'TestClause'
                ..members = [member('givens')..type = 'List<Given>',],
              class_('testable')
                ..isAbstract = true
                ..members = [
                  member('test_scenarios')
                    ..type = 'List<TestScenario>'
                    ..classInit = [],
                  member('test')
                    ..doc = 'The single test for this [Testable]'
                    ..type = 'Test'
                    ..access = WO,
                ],
              class_('test_provider')
                ..isAbstract = true
                ..members = [],
              class_('catch_test_provider')
                ..extend = 'TestProvider'
                ..members = [],
            ],
          part('lib')
            ..enums = [
              enum_('standardized_header')
                ..doc = standardizedHeaderDoc
                ..values = [
                  enumValue(id('lib_common_header')),
                  enumValue(id('lib_logging_header')),
                  enumValue(id('lib_initialization_header')),
                  enumValue(id('lib_all_header')),
                ]
                ..hasLibraryScopedValues = true,
              enum_('file_code_block')
                ..doc = fileCodeBlockDoc
                ..hasLibraryScopedValues = true
                ..values = [
                  enumValue(id('fcb_pre_includes'))
                    ..doc = '''
Custom block any code just before includes begin
Useful for putting definitions just prior to includes, e.g.

    #define CATCH_CONFIG_MAIN
    #include "catch.hpp"
''',
                  enumValue(id('fcb_custom_includes'))
                    ..doc =
                        'Custom block for any additional includes appearing just after generated includes',
                  enumValue(id('fcb_pre_namespace'))
                    ..doc =
                        'Custom block appearing just before the namespace declaration in the code',
                  enumValue(id('fcb_begin_namespace'))
                    ..doc =
                        'Custom block appearing at the begining of and inside the namespace',
                  enumValue(id('fcb_end_namespace'))
                    ..doc =
                        'Custom block appearing at the end of and inside the namespace',
                  enumValue(id('fcb_post_namespace'))
                    ..doc =
                        'Custom block appearing just after the namespace declaration in the code',
                ]
            ]
            ..classes = [
              class_('lib_initializer')
                ..doc = '''
Wrap (un)initialization of a Lib in static methods of a class
'''
                ..members = [
                  member('init_custom_block')
                    ..doc = 'CodeBlock for customizing intialization of [Lib]'
                    ..type = 'CodeBlock',
                  member('uninit_custom_block')
                    ..doc = 'CodeBlock for customizing unintialization of [Lib]'
                    ..type = 'CodeBlock',
                ],
              class_('lib')
                ..doc = 'A c++ library'
                ..extend = 'CppEntity'
                ..mixins = ['Testable']
                ..implement = ['CodeGenerator']
                ..members = [
                  member('version')
                    ..doc = 'Semantic Version for this [Lib]'
                    ..type = 'SemanticVersion'
                    ..access = RO
                    ..classInit = 'new SemanticVersion(0,0,0)',
                  member('namespace')
                    ..doc = 'Names for [Lib]'
                    ..type = 'Namespace'
                    ..classInit = 'new Namespace()',
                  member('headers')
                    ..doc = 'List of [Header] objects in this [Lib]'
                    ..type = 'List<Header>'
                    ..classInit = []
                    ..access = RO,
                  member('impls')
                    ..doc = 'List of [Impl] objects in this [Impl]'
                    ..type = 'List<Impl>'
                    ..classInit = [],
                  member('requires_logging')
                    ..type = 'bool'
                    ..access = WO,
                  member('lib_initializer')
                    ..type = 'LibInitializer'
                    ..access = WO,
                  member('common_header')
                    ..doc = '''
A header for placing types and definitions to be shared among all
other headers in the [Lib]. If this were used for windows, this would
be a good place for the API decl definitions.
'''
                    ..type = 'Header'
                    ..access = IA,
                  member('logging_header')
                    ..doc =
                        'A header for initializing a single logger for the [Lib] if required'
                    ..type = 'Header'
                    ..access = IA,
                  member('initialization_header')
                    ..doc = '''
For [Lib]s that need certain *initialization*/*uninitialization*
functions to be run this will provide a mechanism.
'''
                    ..type = 'Header'
                    ..access = IA,
                  member('all_header')
                    ..doc = '''
A single header including all other headers - intended as a
convenience mechanism for clients not so worried about compile times.
'''
                    ..type = 'Header'
                    ..access = IA,
                ],
            ],
          part('versioning')
            ..doc = 'Support for *Semantic Versioning*'
            ..classes = [
              class_('semantic_version')
                ..doc = 'Provides data required to track a Semantic Version'
                ..isImmutable = true
                ..members = [
                  member('major')..classInit = 0,
                  member('minor')..classInit = 0,
                  member('patch')..classInit = 0,
                ]
            ],
          part('app')
            ..enums = [
              enum_('arg_type')
                ..doc = '''
Set of argument types supported by command line option processing.
'''
                ..requiresClass = true
                ..values = [
                  enumValue(id('int'))
                    ..doc = 'The command line arg is an integer',
                  enumValue(id('double'))
                    ..doc = 'The command line arg is a double',
                  enumValue(id('string'))
                    ..doc = 'The command line arg is a string',
                  enumValue(id('flag'))
                    ..doc = 'The command line arg is a flag - i.e. a boolean',
                ]
            ]
            ..classes = [
              class_('app_arg')
                ..doc = appArgDoc
                ..extend = 'CppEntity'
                ..members = [
                  member('type')
                    ..type = 'ArgType'
                    ..classInit = 'ArgType.STRING',
                  member('short_name'),
                  member('is_multiple')..classInit = false,
                  member('is_required')..classInit = false,
                  member('default_value')
                    ..type = 'Object'
                    ..access = RO,
                ],
              class_('app')
                ..doc = appDoc
                ..extend = 'Impl'
                ..implement = ['CodeGenerator']
                ..members = [
                  member('args')
                    ..doc =
                        'Command line arguments specific to this application'
                    ..type = 'List<AppArg>'
                    ..classInit = [],
                  member('headers')
                    ..doc = '''
Additional headers that are associated with the application itself, as
opposed to belonging to a reusable library.'''
                    ..type = 'List<Header>'
                    ..classInit = [],
                  member('impls')
                    ..doc = '''
Additional implementation files associated with the
application itself, as opposed to belonging to a reusable
library.'''
                    ..type = 'List<Impl>'
                    ..classInit = [],
                  member('required_libs')
                    ..doc = '''
Libraries required to build this executable. *Warning* potentially
deprecated in the future. Originally when generating boost jam files
it was convenient to associate the required libraries directly in the
code generation scripts. With cmake it was simpler to just incorporate
protect blocks where the required libs could be easily added.
'''
                    ..type = 'List<String>'
                    ..classInit = [],
                  member('main_code_block')
                    ..doc = '''
An App is an Impl and therefore contains accesors to FileCodeBlock
sections (e.g. fcbBeginNamespace, fcbPostNamespace, ...). The heart of
an application impl file is the main, so this [CodeBlock] supports
injecting code in main
'''
                    ..type = 'CodeBlock'
                    ..classInit = "new CodeBlock('main')",
                  member('has_log_level')
                    ..doc = '''
If true adds --log-level to the set of options for the app. This app
argument will default the app to having no logging, but allow user
control.
'''
                    ..classInit = false,
                  member('has_signal_handler')
                    ..doc =
                        'If true support for handling signals included in app'
                    ..classInit = false,
                  member('has_quit_loop')
                    ..doc = '''
If true adds quit loop at end of main.

The quit loop loops as:

    do {
      std::cout << "Enter 'q' or 'Q' to quit" << std::endl;
      if(c == 'q' || c == 'Q') {
        break;
      }
    } while(std::cin >> c);
'''
                    ..classInit = false,
                ],
              class_('app_builder')
                ..doc = '''
Base class establishing interface for generating build scripts for
libraries, apps, and tests'''
                ..isAbstract = true
                ..implement = ['CodeGenerator']
                ..members = [member('app')..type = 'App'],
            ],
          part('cmake_support')
            ..classes = [
              class_('cmake_installation_builder')
                ..doc =
                    'Responsible for generating a suitable CMakeLists.txt file'
                ..extend = 'InstallationBuilder',
            ],
          part('script')
            ..classes = [
              class_('script')
                ..extend = 'CppEntity'
                ..implement = ['CodeGenerator']
                ..members = [],
            ],
          part('benchmark')
            ..enums = []
            ..classes = [
              class_('benchmark_app')
                ..extend = 'Impl'
                ..implement = ['CodeGenerator']
                ..members = [
                  member('headers')
                    ..doc = '''
Additional headers that are associated with the benchmark application
itself, as opposed to belonging to a reusable library.'''
                    ..type = 'List<Header>'
                    ..classInit = [],
                  member('impls')
                    ..doc = '''
Additional implementation files associated with the benchmark
application itself, as opposed to belonging to a reusable library.'''
                    ..type = 'List<Impl>'
                    ..classInit = [],
                ],
              class_('benchmark')
                ..doc = '''
A single benchmark fixture with one or more functions to time.

Benchmark support is provided via
(benchmark)[https://github.com/google/benchmark].  Each benchmark
results in a single [benchmarkLib] with a single [benchmarkHeader]
with a single [benchmarkClass] that derives from
::benchmark::Fixture. Each of these are generated *bare-bones* and
ready for custom code. Of course, the [Header], [Lib] and [App]
meta objects are available for code injection.

The generated class has the *SetUp* and
*TearDown* functions with protect blocks.

Each benchmark also has an [App] associated with it
(i.e. [benchmarkApp]). This is where the benchmark timing loops
and the *BENCHMARK_MAIN()* provided by the
(benchmark)[https://github.com/google/benchmark] exist.

For a [Benchmark] you may specify 0 or more [functions] that
correspond to named timing loops (i.e. pieces of code that you want to
benchmark). If you specify no functions a single function with the
name of the [Benchmark] will be used.

So, given an [Installation], this code:

    installation
    ..benchmarks.add(benchmark('simple'))

Will result in the creation of:

 - .../benchmarks/bench/simple/benchmark_simple.hpp: The place to do
   setup and teardown of your benchmark fixture.

        class Benchmark_simple : public ::benchmark::Fixture {
         public:
          // custom <ClsPublic Benchmark_simple>
          // end <ClsPublic Benchmark_simple>

          void SetUp() {
            // custom <benchmark_simple setup>
            // end <benchmark_simple setup>
          }

          void TearDown() {
            // custom <benchmark_simple teardown>
            // end <benchmark_simple teardown>
          }
        };


 - .../benchmarks/app/simple/simple.cpp: The app containing
   *BENCHMARK_MAIN()* and the *simple* function being timed:

        BENCHMARK_F(Benchmark_simple, Simple)(benchmark::State& st) {
          // custom <simple benchmark pre while>
          // end <simple benchmark pre while>

          while (st.KeepRunning()) {
            // custom <simple benchmark while>
            // end <simple benchmark while>
          }
          // custom <simple benchmark post while>
          // end <simple benchmark post while>
        }

        BENCHMARK_MAIN()

That *BENCHMARK_F* declaration creates a derivative of the fixture
with the specified method *Simple*. When the [benchmarkApp] is run the
*Simple* function will be benchmarked.
'''
                ..extend = 'CppEntity'
                ..members = [
                  member('namespace')
                    ..doc = 'Names for C++ entities'
                    ..type = 'Namespace'
                    ..access = IA,
                  member('benchmark_header')
                    ..doc = 'The primary header for this benchmark'
                    ..type = 'Header'
                    ..access = RO,
                  member('benchmark_class')
                    ..doc = 'The primary class for this benchmark'
                    ..type = 'Class'
                    ..access = RO,
                  member('benchmark_lib')
                    ..doc = 'Library for the benchmark'
                    ..type = 'Lib'
                    ..access = RO,
                  member('benchmark_app')
                    ..doc = 'The application associated with this benchmark'
                    ..type = 'BenchmarkApp'
                    ..access = RO,
                  member('functions')
                    ..doc = '''
The list of functions.

If not set by client will result in list of one function [ id ].
'''
                    ..type = 'List<Id>'
                    ..classInit = []
                    ..access = RO,
                ],
              class_('benchmark_group')
                ..doc = '''
Collection of one or benchmarks generated into one executable.
'''
                ..extend = 'CppEntity'
                ..members = [
                  member('benchmarks')
                    ..doc = 'Collection of benchmarks'
                    ..type = 'List<Benchmark>'
                    ..classInit = []
                    ..access = RO,
                  member('benchmark_app')
                    ..doc =
                        'The application containing hooks into benchmark suite'
                    ..type = 'BenchmarkApp'
                    ..access = RO,
                ],
            ],
          part('emacs_support')
            ..doc =
                'Support for generating emacs functions for accessing generated code'
            ..classes = [
              class_('installation_walker')
                ..doc =
                    'Walks installation and creates single emacs file with utility functions'
                ..implement = ['CodeGenerator']
                ..isImmutable = true
                ..members = [member('installation')..type = 'Installation']
            ],
          part('test')
            ..classes = [
              class_('test')
                ..extend = 'Impl'
                ..implement = ['CodeGenerator']
                ..members = [
                  member('testable')..type = 'Testable',
                  member('headers')
                    ..type = 'List<Header>'
                    ..classInit = [],
                  member('impls')
                    ..type = 'List<Impl>'
                    ..classInit = [],
                  member('test_implementations')
                    ..type = 'Map<String, String>'
                    ..classInit = {}
                    ..access = RO,
                  member('required_libs')
                    ..type = 'List<String>'
                    ..classInit = [],
                ],
            ],
          part('installation')
            ..classes = [
              class_('installation_builder')
                ..isAbstract = true
                ..implement = ['CodeGenerator']
                ..doc = '''
Creates builder for an installation (ie ties together all build artifacts)
'''
                ..members = [member('installation')..type = 'Installation'],
              class_('installation')
                ..doc = installationDoc
                ..extend = 'CppEntity'
                ..implement = ['CodeGenerator']
                ..members = [
                  member('root_file_path')
                    ..doc = 'Fully qualified file path to installation'
                    ..access = RO,
                  member('paths')
                    ..type = 'Map<String, String>'
                    ..classInit = {}
                    ..access = RO,
                  member('cpp_loggers')
                    ..type = 'List<CppLogger>'
                    ..classInit = [],
                  member('libs')
                    ..doc = 'Libs in this [Installation].'
                    ..type = 'List<Lib>'
                    ..classInit = [],
                  member('apps')
                    ..doc = 'Apps in this [Installation].'
                    ..type = 'List<App>'
                    ..classInit = [],
                  member('benchmark_apps')
                    ..doc = '''
Benchmark Apps in this [Installation].

Benchmark apps are just [App] instances with some generated benchmark code
(i.e. using [benchmark](https://github.com/google/benchmark)) kept separate from
[apps], but tied into the build scripts.
'''
                    ..type = 'List<App>'
                    ..access = IA
                    ..classInit = [],
                  member('scripts')
                    ..type = 'List<Script>'
                    ..classInit = [],
                  member('test_provider')
                    ..doc = 'Provider for generating tests'
                    ..type = 'TestProvider'
                    ..classInit = 'new CatchTestProvider()',
                  member('log_provider')
                    ..doc = 'Provider for generating tests'
                    ..type = 'LogProvider'
                    ..classInit = 'new SpdlogProvider(new EbisuCppNamer())',
                  member('installation_builder')
                    ..doc = 'The builder for this installation'
                    ..type = 'InstallationBuilder',
                  member('namer')
                    ..doc = '''
Namer to be used when generating names during generation. There is a
default namer, [EbisuCppNamer] that is used if one is not provide. To
create your own naming conventions, provide an implementation of
[Namer] and set an assign that namer to a top-level [Entity], such as
the [Installation]. The assigned namer will be propogated to all
genration utilities.
'''
                    ..access = IA
                    ..type = 'Namer'
                    ..classInit = 'defaultNamer',
                  member('doxy_config')
                    ..type = 'DoxyConfig'
                    ..classInit = 'new DoxyConfig()',
                  member('logs_api_initializations')
                    ..doc = '''
If true logs initialization of libraries - useful for tracking
down order of initialization issues.
'''
                    ..classInit = false,
                  member('benchmarks')
                    ..doc =
                        'All *stand-alone* modeled benchmarks in the installation'
                    ..type = 'List<Benchmark>'
                    ..classInit = [],
                  member('benchmark_groups')
                    ..doc = 'All [BenchmarkGroup]s in this [Installation]'
                    ..type = 'List<BenchmarkGroup>'
                    ..classInit = [],
                  member('include_stack_trace')
                    ..doc = '''
If true includes comments about code being generated as well as a
stack trace to help find the dart code that generated the source.
'''
                    ..classInit = false,
                ],
              class_('path_locator')
                ..members = [
                  member('env_var')
                    ..doc =
                        'Environment variable specifying location of path, if set this path is used'
                    ..isFinal = true,
                  member('default_path')
                    ..doc = 'Default path for the item in question'
                    ..isFinal = true,
                  member('path')..access = RO,
                ],
            ],
          part('cpp_standard')
            ..doc = '''
Provides for minimal identification of C++ standard items.
For example - the set of standard system headers is made available.
''',
          part('decorator')
            ..doc = '''
Establishes capability for decorating an [Installation] prior to generation.
'''
            ..classes = [
              class_('installation_decorator')
                ..isAbstract = true
                ..doc = '''
Establishes an interface to allow decoration of classes and updates
(primarily additions) to an [Installation].
''',
            ],
          part('doxy')
            ..classes = [
              class_('doxy_config')
                ..members = [
                  member('project_name')..classInit = '',
                  member('project_brief')..classInit = '',
                  member('output_directory')..classInit = '',
                  member('input')..classInit = '',
                  member('exclude')..classInit = '',
                  member('example_path')..classInit = '',
                  member('image_path')..classInit = '',
                  member('html_stylesheet')..classInit = '',
                  member('chm_file')..classInit = '',
                  member('include_path')..classInit = '',
                ]
            ],
        ],
      library('cookbook')
        ..includesLogger = true
        ..imports = [
          'package:id/id.dart',
          'package:ebisu/ebisu.dart',
          'package:ebisu_cpp/ebisu_cpp.dart',
        ]
        ..parts = [
          part('dispatchers')
            ..enums = [
              enum_('dispatch_cpp_type')
                ..hasLibraryScopedValues = true
                ..values = [
                  'dct_std_string',
                  'dct_cptr',
                  'dct_string_literal',
                  'dct_integer',
                  'dct_byte_array',
                ],
            ]
            ..classes = [
              class_('enumerated_dispatcher')
                ..doc = '''
Provides support for generating functions to dispach on a set of one or more
elements.

Covers things like switch, if-else-if, jump tables in a predefined way. A common
task is: given input data categorized by some type enumeration, dispatch a
function to handle associated data.

For example, you might have an XML Element that is one of a predefined set of
known element types. The XML Element has a *tag* which you can use to
discriminate on. Suppose the elements of interest are:

  - <typeDeclaration>

  - <struct>

  - <member>

  - <function>

Often you will need code that effectively does a switch on a *tag* associated
with the data and passes that data to its proper handler.
'''
                ..isAbstract = true
                ..members = [
                  member('enumeration')
                    ..doc = '''
Set of valid values *all of same type* to index on.

For example, to discriminate on a set of named tags:

  - <typeDeclaration>

  - <struct>

  - <member>

  - <function>

use:

    ..enumeration = ['typeDeclaration', 'struct', 'member', 'function']
'''
                    ..type = 'List<dynamic>'
                    ..classInit = []
                    ..access = RO,
                  member('enumerator')
                    ..doc = '''
C++ expression suitable for a switch or variable assignment,
representing the enumerated value''',
                  member('dispatcher')
                    ..doc = '''
Functor allowing client to dictate the dispatch on the
enumerant. *Note* client must supply trailing semicolon if needed.
'''
                    ..type = 'Dispatcher',
                  member('type')
                    ..doc = '''
Type associated with the enumerated values. That type may be *string*
or some form of int.
''',
                  member('enumerator_type')
                    ..doc = 'Type of the enumerator entries'
                    ..type = 'DispatchCppType',
                  member('discriminator_type')
                    ..doc = 'Type of the discriminator'
                    ..type = 'DispatchCppType',
                  member('error_dispatcher')
                    ..doc = '''
Functor allowing client to dictate the dispatch of an unidentified
enumerator. *Note* client must supply trailing semicolon if needed.
'''
                    ..type = 'ErrorDispatcher',
                  member('uses_enumerator_directly')
                    ..doc = r'''
For [dctStdString] type enumerations.

If true does not declare separate *descriminator_* local variable, but
rather uses the enumerator value directly. Since the enumerator might
be some function call (e.g. String  const& get_value()), the defulat behavior
is to assign to local:

    std::string const& discriminator_ { $enumerator };

Setting this to true bypasses that and uses $enumerator directly.
'''
                    ..classInit = false,
                ],
              class_('switch_dispatcher')
                ..doc = 'Dispatcher implemented with *switch* statement'
                ..extend = 'EnumeratedDispatcher',
              class_('if_else_if_dispatcher')
                ..doc = 'Dipatcher implemented with *if-else-if* statements'
                ..extend = 'EnumeratedDispatcher'
                ..members = [
                  member('compare_expression')..type = 'CompareExpression'
                ],
              class_('char_node')
                ..doc = '''
A node in a tree-structure.

The tree-structure represents a set of strings where a traversal of
the tree can visit all characters in all strings. Any node that has
[isLeaf] set indicates the path from root to said node is a complete
string from the set.

For example:

    final strings = [
      '125',
      '32',
      '1258',
    ];

    final tree = new CharNode.from(null, 'root', strings, false);
    print(tree);

Prints:

    root in null
    isLeaf:false
      1 in 1
      isLeaf:false
        2 in 12
        isLeaf:false
          5 in 125
          isLeaf:true
            8 in 1258
            isLeaf:true
      3 in 3
      isLeaf:false
        2 in 32
        isLeaf:true

The tree shrunk by calling flatten:

    tree.flatten();
    print(tree);

    root in null
    isLeaf:false
      12 in 12
      isLeaf:false
        5 in 125
        isLeaf:true
          8 in 1258
          isLeaf:true
      32 in 32
      isLeaf:true
'''
                ..members = [
                  member('char'),
                  member('is_leaf')..type = 'bool',
                  member('parent')..type = 'CharNode',
                  member('children')
                    ..type = 'List<CharNode>'
                    ..classInit = [],
                ],
              class_('char_binary_dispatcher')
                ..doc = '''
Dipatcher implemented with *if-else-if* statements visiting character by
character - *only* valid for strings as discriminators.
'''
                ..extend = 'EnumeratedDispatcher'
                ..members = [
                  member('has_no_length_checks')
                    ..doc = '''
Bypasses normal length checks.

Applicable when caller all enumerants of same length and caller
ensures dispatch is as large as that length'''
                    ..classInit = false
                ],
              class_('strlen_binary_dispatcher')
                ..doc = '''
Dipatcher that first partitions the discriminator by length then implemented
with *if-else-if* statements visiting character by character - *only* valid for
strings as discriminators.
'''
                ..extend = 'EnumeratedDispatcher'
                ..members = [
                  member('length_map')
                    ..doc =
                        'Map the length of the enumerant to the set of enumerants of same length'
                    ..access = RO
                    ..classInit = {}
                ],
            ]
        ],

      library('hdf5_support')
        ..imports = [
          'package:ebisu_cpp/ebisu_cpp.dart',
          'package:ebisu/ebisu.dart',
          'package:id/id.dart',
        ]
        ..doc =
            'Provide C++ classes support for reading/writing to hdf5 packet table'
        ..enums = [_enumH5t]
        ..variables = [
          variable('h5t_to_cpp_type')
            ..type = 'Map'
            ..init = _enumH5tMap
        ]
        ..parts = [
          part('packet_table')
            ..classes = [
              class_('class_not_found_exception')
                ..doc = '''
Indicates a class could not be found in the [Installation] for adding
hdf5 packet table support
'''
                ..implement = ['Exception']
                ..members = [
                  member('message')
                    ..isFinal = true
                    ..access = RO
                    ..doc = 'Exception details',
                ],
              class_('log_group')
                ..hasCtorSansNew = true
                ..members = [
                  member('class_name')
                    ..doc =
                        'Name of class, *snake case*, to add a packet table log group'
                    ..ctors = ['']
                    ..isFinal = true,
                  member('member_names')
                    ..doc = '''
Name of members of class, *snake case*, to include in the packet table
log group. An empty list will include all members in the table.
'''
                    ..type = 'List<String>'
                    ..ctorInit = 'const []'
                    ..ctorsOpt = ['']
                    ..isFinal = true,
                ],
              class_('packet_member_type')
                ..members = [member('base_type')..type = 'H5tType',],
              class_('packet_member_string')
                ..extend = 'PacketMemberType'
                ..members = [member('size')..type = 'int'],
              class_('packet_table_decorator')
                ..isImmutable = true
                ..hasCtorSansNew = true
                ..implement = ['InstallationDecorator',]
                ..members = [member('log_groups')..type = 'List<LogGroup>']
            ]
        ],
    ];

  ebisu.scripts = [
    script('bootstrap_ebisu_cpp')
      ..imports = [
        'package:id/id.dart',
        'package:path/path.dart',
        "'package:ebisu/ebisu.dart' as ebisu",
        'package:ebisu/ebisu_dart_meta.dart',
      ]
      ..doc = 'Creates an ebisu_cpp setup'
      ..classes = [
        class_('project')
          ..hasJsonToString = true
          ..members = [
            member('id')..type = 'Id',
            member('root_path'),
            member('codegen_path'),
            member('script_name'),
            member('ebisu_file_path'),
            member('cpp_file_path'),
          ]
      ]
      ..args = [
        scriptArg('project_path')
          ..doc = 'Path to top level of desired ebisu project'
          ..abbr = 'p',
        scriptArg('add_app')
          ..doc = 'Add library to project'
          ..abbr = 'a',
        scriptArg('add_lib')
          ..doc = 'Add library to project'
          ..abbr = 'l',
        scriptArg('add_script')
          ..doc = 'Add script to project'
          ..abbr = 's',
      ]
  ];

  ebisu.generate();

  _logger.warning('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
}

////////////////////////////////////////////////////////////////////////////////
// Large doc comment for the cpp library
final cppLibraryDoc = '''
Library to facilate generation of c++ code.

The intent is to get as declarative as possible with the specification of C++
entities to make code generation as simple and fun as possible. The primary
focus of these utilities is in generating the *structure* of c++ code. This is
achieved by modeling the C++ language at a relatively high level and selectively
choosing what parts of the language lend themselves to the approach.

For sample code that uses this library to generate its structure see:
[fcs project](https://github.com/patefacio/fcs)

For a small taste, the following is the current description of a small C++
library called *raii* which provides a few utilities for handling the *resource
acquisition is initialization* idiom.

    import 'package:ebisu_cpp/cpp.dart';
    import '../../lib/installation.dart';

    final raii = lib('raii')
      ..namespace = namespace([ 'fcs', 'raii' ])
      ..headers = [
        header('change_tracker')
        ..includes = [ 'boost/call_traits.hpp' ]
        ..classes = [
          class_('change_tracker')
          ..descr = \'\'\'
    Tracks current/previous values of the given type of data. For some
    algorithms it is useful to be able to examine/perform logic on
    current value and compare or evalutate how it has changed since
    previous value.\'\'\'
          ..template = [ 'typename T' ]
          ..customBlocks = [clsPublic]
          ..members = [
            member('current')..type = 'T'..access = ro,
            member('previous')..type = 'T'..access = ro,
          ],
          ...
        ],
        header('api_initializer')
        ..test.customBlocks = [ fcbPreNamespace ]
        ..test.includes.addAll(['vector', 'fcs/utils/streamers/containers.hpp', ])
        ..includes = [ 'list', 'map', 'memory' ]
        ..usings = [
          'Void_func_t = void (*)(void)',
        ]
        ..classes = [
          class_('functor_scope_exit')
          ..template = [ 'typename FUNCTOR = Void_func_t' ]
          ..usings = [ 'Functor_t = FUNCTOR' ]
          ..customBlocks = [ clsPublic ]
          ..memberCtors = [ memberCtor(['functor']) ]
          ..members = [
            member('functor')..type = 'Functor_t'..hasNoInit = true..access = ro,
          ],
          ...
          class_('api_initializer')
          ..usings = [
            'Api_initializer_registry_t = Api_initializer_registry< INIT_FUNC, UNINIT_FUNC >'
          ]
          ..template = [
            'typename INIT_FUNC = Void_func_t',
            'typename UNINIT_FUNC = Void_func_t',
          ]
          ..customBlocks = [ clsPublic ]
        ]
      ];

    addItems() => installation.addLib(raii);

    main() {
      addItems();
      installation.generate();
    }

When that script is run, the following is output:

    No change: \$TOP/fcs/cpp/fcs/raii/change_tracker.hpp
    No change: \$TOP/fcs/cpp/fcs/raii/api_initializer.hpp
    No change: \$TOP/fcs/cpp/tests/fcs/raii/test_change_tracker.cpp
    No change: \$TOP/fcs/cpp/tests/fcs/raii/test_api_initializer.cpp

So when the script is run the code is *regenerated* and any changed files will
be indicated as such. In this case, since the code was previously generated, it
indicates there were no updates.
''';

final appArgDoc = '''
Metadata associated with an argument to an application.  Requires and
geared to features supported by boost::program_options. The supporting
code for arguments is spread over a few places in the main file of an
[App]. Examples of declarations follow:

      print(br([
        appArg('filename')
        ..shortName = 'f',

        appArg('in_file')
        ..shortName = 'f'
        ..defaultValue = 'input.txt',

        appArg('pi')
        ..shortName = 'p'
        ..isRequired = true
        ..defaultValue = 3.14,

        appArg('source_file')
        ..shortName = 's'
        ..isMultiple = true
      ]));

Prints:

    AppArg(filename)
      argType: String
      cppType: std::string
      flagDecl: "filename,f"
      isRequired: false
      isMultiple: false
      defaultValue: null

    AppArg(in_file)
      argType: String
      cppType: std::string
      flagDecl: "in-file,f"
      isRequired: false
      isMultiple: false
      defaultValue: input.txt

    AppArg(pi)
      argType: Double
      cppType: double
      flagDecl: "pi,p"
      isRequired: true
      isMultiple: false
      defaultValue: 3.14

    AppArg(source_file)
      argType: String
      cppType: std::vector< std::string >
      flagDecl: "source-file,s"
      isRequired: false
      isMultiple: true
      defaultValue: null


For an [App], if no [Arg] in [args] is named *help* or has [shortName]
of *h* then the following *help* argument is provided. The help text
will include the doc string of the [App].

      args.insert(0, new AppArg(new Id('help'))
        ..shortName = 'h'
        ..defaultValue = false
        ..descr = 'Display help information');


Example: Here are the [AppArg]s of an simple application:

    arg('timestamp')
    ..shortName = 't'
    ..descr = 'Some form of timestamp'
    ..isMultiple = true
    ..type = ArgType.STRING,
    arg('date')
    ..shortName = 'd'
    ..descr = 'Some form of date'
    ..isMultiple = true
    ..type = ArgType.STRING,

When run, the help looks something like:

    App for converting between various forms of date/time

    AllowedOptions:
      -h [ --help ]          Display help information
      -t [ --timestamp ] arg Some form of timestamp
      -d [ --date ] arg      Some form of date
''';

final appDoc = '''

A C++ application. Application related files are generated in location based on
[namespace] the namespace. For example, the following code:

    app('date_time_converter')
      ..namespace = namespace(['fcs'])
      ..args = [
        arg('timestamp')
        ..shortName = 't'
        ..descr = 'Some form of timestamp'
        ..isMultiple = true
        ..type = ArgType.STRING,
        arg('date')
        ..shortName = 'd'
        ..descr = 'Some form of date'
        ..isMultiple = true
        ..type = ArgType.STRING,
      ];

will generate a C++ file containing *main* at location:

    \$root/cpp/app/date_time_converter/date_time_converter.cpp

Since [App] extends [Impl] it supports local instances of
[constExprs] [usings], [enums], [forwardDecls], and [classes],
as well as [headers] and [impls] which may be part of the
application and not necessarily suited for a separate library.
''';

final fileCodeBlockDoc = '''
Set of pre-canned blocks where custom or generated code can be placed.
The various supported code blocks associated with a C++ file. The
name indicates where in the file it appears.

So, the following spec:

    final h = header('foo')
      ..includes = [ 'iostream' ]
      ..namespace = namespace(['foo'])
      ..customBlocks = [
        fcbCustomIncludes,
        fcbPreNamespace,
        fcbBeginNamespace,
        fcbEndNamespace,
        fcbPostNamespace,
      ];
    print(h.contents);

prints:

    #ifndef __FOO_FOO_HPP__
    #define __FOO_FOO_HPP__

    #include <iostream>

    // custom <FcbCustomIncludes foo>
    // end <FcbCustomIncludes foo>

    // custom <FcbPreNamespace foo>
    // end <FcbPreNamespace foo>

    namespace foo {
      // custom <FcbBeginNamespace foo>
      // end <FcbBeginNamespace foo>

      // custom <FcbEndNamespace foo>
      // end <FcbEndNamespace foo>

    } // namespace foo
    // custom <FcbPostNamespace foo>
    // end <FcbPostNamespace foo>

    #endif // __FOO_FOO_HPP__

''';

final classDoc = '''
A C++ class.

Classes optionally have these items:

* A [template]
* A collection of [bases]
* A collection of [members]
* A collection of class local [forwardDecls]
* A collection of class local [usings]
* A collection of class local [enums]
* A collection of class local [forward_ptrs] which are like [usings] but standardized for pointer type
* A collection of *optionally included* standard methods.
  In general these methods are not included unless requested. There
  are two approaches to *requesting* their presence:

  1 - just mention their name (i.e. invoke the getter for the member on the
  class which autoinitializes the member) and the default function will be
  included. This is a *funky* use of function side-effects, but the effect is
  fewer calls required to declaratively describe your class.

  2 - when more configuration of the method is required, call the *with...()*
  function to get scoped access to the function object.

  Example - Case 1:

      print(clangFormat((class_('x')).definition));
      print(clangFormat((class_('x')..copyCtor).definition));
      print(clangFormat((class_('x')..copyCtor.usesDefault = true).definition));

  Prints:

        class X {};

        class X {
         public:
          X(X const& other) {}
        };

        class X {
         public:
          X(X const& other) = default;
        };


  Note that simply naming the copy constructor member of the class will inlude
  its definition. Sometimes you might want to do more with a [ClassMethod]
  definition declaratively in place which is why the *with...()* methods exist.

  Example - Case 2:

      print(clangFormat((
                  class_('x')
                  ..withCopyCtor((ctor) =>
                      ctor..cppAccess = protected
                      /// ... do more with ctor, like inject logging code
                      ))
              .definition));

  Prints:

        class X {
         protected:
          X(X const& other) {}
        };

  The functions are:

  * Optionally included constructors including:

    * [CopyCtor]
    * [MoveCtor]
    * [DefaultCtor]
    * Zero or more member initializing ctors [MemberCtor]

  * Assignment functions:

    * [AssignCopy]
    * [AssignMove]

  * [Dtor]

  * Standard Utility Methods

    * [OpEqual]
    * [OpLess]
    * [OpOut] - Support for streaming fields

* A fixed collection of indexed [codeBlocks] that can be used for
  providing *CustomBlocks* and/or for dynamically injecting code - see
  [CodeBlock].
''';

final memberCtorInitDoc = '''
*Override* of initialization text. This is rarely needed since
initialization of members in a member ctor is straightforward:

This definition:

    memberCtor(['x', 'y'])

would produce the following constructor:

    class Point {
    public:
      Point(int x, int y) : x_{x}, y_{y} {}
    private:
      int x_;
      int y_;
    }

But sometimes you need more:

    class Umask_scoped_set {
    public:
      Umask_scoped_set(mode_t new_mode) : previous_mode_{umask(new_mode)}
    ...
    }

Which would be achieved by:

    memberCtor([
      memberCtorParm("previous_mode")
      ..parmDecl = "mode_t new_mode"
      ..init = "umask(new_mode)"
    ])

''';

final memberCtorParmDoc = '''
A *Member Constructor Parameter*. Defines a single parameter to be passed to a
MemberCtor in order to initialize a single member variable. MemberCtor will
convert strings automatically into instances of MemberCtorParm. For example:

    memberCtor(['x', 'y'])

would produce the following constructor:

    class Point {
    public:
      Point(int x, int y) : x_{x}, y_{y} {}
    private:
      int x_;
      int y_;
    }

But to modify the parameter definition or initializtaion you might rather
construct and modify the MemberCtorParm instead of taking the default:

        final cls = class_('point')
          ..members = [ member('x')..init = 0, member('y')..init = 0 ]
          ..memberCtors = [
            memberCtor( [
              memberCtorParm('x')
              ..defaultValue = '42',
              memberCtorParm('y')
              ..defaultValue = '42'] )
          ];

which produces:

    class Point
    {
    public:
      Point(
        int x = 42,
        int y = 42) :
        x_ { x },
        y_ { y } {
      }

    private:
      int x_ { 0 };
      int y_ { 0 };
    };

''';

final classCodeBlockDoc = '''
The various supported code blocks associated with a C++ class. The
name indicates where in the class it appears. Within the class
definition the order is *public*, *protected* then
*private*. Additional locations for just before the class and just
after the class.

So, the following spec:

        (class_('c')
            ..customBlocks = [
              clsPreDecl,
              clsPublic,
              clsProtected,
              clsPrivate,
              clsPostDecl
            ])
        .definition


Gives the following content:

    // custom <ClsPreDecl C>
    // end <ClsPreDecl C>

    class C
    {
    public:
      // custom <ClsPublic C>
      // end <ClsPublic C>

    protected:
      // custom <ClsProtected C>
      // end <ClsProtected C>

    private:
      // custom <ClsPrivate C>
      // end <ClsPrivate C>

    };

    // custom <ClsPostDecl C>
    // end <ClsPostDecl C>
''';

final getterReturnModifierDoc = '''
A function that may be used to modify the value returned from a
getter.  If a modifier function of type [GetReturnModifier] is
provided it will be used to update what the accessor returns.

For example:

    print(clangFormat(
            (member('message_length')
                ..type = 'int32_t'
                ..access = ro
                ..getterReturnModifier =
                  ((member, oldValue) => 'endian_convert(\$oldValue)'))
            .getter));

prints:

    //! getter for message_length_ (access is Ro)
    int32_t message_length() const { return endian_convert(message_length_); }

Notes: No required *parens* when used inline with cascades. A trailing
semicolon is *not* required and the modifier accessor must return the
same type as the member.
''';

final memberInitDoc = """
Initialization of member.

If [type] of [Member] is null and [init] is set with a Dart type
which can reasonably map to a C++ type, then type is inferred.
Currently the mappings are:
    {
      int : int,
      double : double,
      string : std::string,
      bool : bool,
      List(...) : std::vector<...>,
    }

For example:

    member('name')..init = 'UNASSIGNED' => name is std::string
    member('x')..init = 0               => x is int
    member('pi')..init = 3.14           => pi is double

""";

final memberDoc = '''
A member or field included in a class.

## Basics

Members are typed (i.e. have [type]) and optionally initialized.

For example:

    member('widget')..type = 'Widget'..init = 'Widget()'

gives:

    Widget widget_ { Widget() };

For some C++ types (*double*, *int*, *std::string*, *bool*) the type
can be inferred if a suitable [init] is provided:

Examples:

    member('number')..init = 4
    member('pi')..init = 3.14
    member('default_tag')..init = 'empty'
    member('is_strong')..init = false

give respectively:

    int number_ { 4 };
    double pi_ { 3.14 };
    std::string default_tag_ { "empty" };
    bool is_strong_ { false };

## Encapsulation

Encapsulation can be achieved by setting [access] and/or
[cppAccess]. Setting [access] is the preferred approach since it
provides a consistent, sensible pattern for hiding and accessing
members (See [Access]).

*Read-Only* Example:

    (class_('c')
        ..members = [
          member('readable')..init = 'foo'..access = ro
        ])
    .definition

Gives:

    class C
    {
    public:
      //! getter for readable_ (access is Ro)
      std::string const& readable() const { return readable_; }
    private:
      std::string readable_ { "foo" };
    };


*Inaccessible* Example:

    (class_('c')
        ..members = [
          member('inaccessible')..init = 'foo'..access = ia
        ])
    .definition

Gives:

    class C
    {
    private:
      std::string inaccessible_ { "foo" };
    };

*Read-Write* Example:

    (class_('c')
      ..members = [
        member('read_write')..init = 'foo'..access = rw
      ])
    .definition

Gives:

    class C
    {
    public:
      //! getter for read_write_ (access is Rw)
      std::string const& read_write() const { return read_write_; }
      //! setter for read_write_ (access is Access.rw)
      void read_write(std::string & read_write) { read_write_ = read_write; }
    private:
      std::string read_write_ { "foo" };
    };


Note that read-write keeps the member *private* by default and allows
access through methods. However, complete control over C++ access of
members can be obtained with [cppAccess]. Here are two such examples:

No accessors, just C++ public:

    (class_('c')
      ..members = [
        member('full_control')..init = 'foo'..cppAccess = public
      ])
    .definition

Gives:

    class C
    {
    public:
      std::string full_control { "foo" };
    };

Finally, using both [access] and [cppAccess] for more control:

    (class_('c')
      ..members = [
        member('more_control')..init = 'foo'..access = ro..cppAccess = protected
      ])
    .definition


Gives:

    class C
    {
    public:
      //! getter for more_control_ (access is Ro)
      std::string const& more_control() const { return more_control_; }
    protected:
      std::string more_control_ { "foo" };
    };

''';

final enumDoc = """
A c++ enumeration.

There are two main styles of enumerations, *standard* and
*mask*.

Enumerations are often used to establish values to be used in
masks. The actual manipulation with masks is done in the *int* space,
but enums are convenient for setting up the mask values:

      print(enum_('gl_buffer')
          ..values = [ 'gl_color_buffer', 'gl_depth_buffer',
            'gl_accum_buffer', 'gl_stencil_buffer' ]
          ..isMask = true);

will print:

    enum Gl_buffer {
      Gl_color_buffer_e = 1 << 0,
      Gl_depth_buffer_e = 1 << 1,
      Gl_accum_buffer_e = 1 << 2,
      Gl_stencil_buffer_e = 1 << 3
    };

The *values* for enumeration entries can be ignored when their only
purpose is to draw distinction:

    print(enum_('region')..values = ['north', 'south', 'east', 'west']);

will print:

    enum Region {
      North_e,
      South_e,
      East_e,
      West_e
    };

Sometimes it is important not only to distinguish, but also to assign
values. For this purpose the values associated with the entries may be
provided as [EnumValue]s. This allow allows comments to be associated
with the values.

    print(enum_('thresholds')
          ..values = [
            enumValue('high', 100)..doc = 'Dangerously high',
            enumValue('medium', 50)..doc = 'About right height',
            enumValue('low', 10)..doc = 'Low height',
          ]);

gives:

    enum Thresholds {
      High_e = 100,
      Medium_e = 50,
      Low_e = 10
    };

Optionally the [isClass] field can be set to improve scoping by making
the enum a *class* enum.

    print(enum_('color_as_class')
          ..values = ['red', 'green', 'blue']
          ..isClass = true);

gives:

    enum class Color_as_class {
      Red_e,
      Green_e,
      Blue_e
    };

Optionally the [enumBase] can be used to specify the
base type. This is particularly useful where the enum
is a field in a *packed* structure.

    print(enum_('color_with_base')
          ..values = ['red', 'green', 'blue']
          ..enumBase = 'std::int8_t');

gives:

    enum Color_with_base : std::int8_t {
      Red_e,
      Green_e,
      Blue_e
    };

[isClass] may be combined with [enumBase].

The [isStreamable] flag will provide *to_c_str* and *operator<<* methods:

    print(enum_('color')
          ..values = ['red', 'green', 'blue']
          ..enumBase = 'std::int8_t'
          ..isStreamable = true
          );

gives:

    enum class Color : std::int8_t {
      Red_e,
      Green_e,
      Blue_e
    };
    inline char const* to_c_str(Color e) {
      switch(e) {
        case Color::Red_e: return "Red_e";
        case Color::Green_e: return "Green_e";
        case Color::Blue_e: return "Blue_e";
      }
    }
    inline std::ostream& operator<<(std::ostream &out, Color e) {
      return out << to_c_str(e);
    }

For the *standard* style enum you can use the [hasFromCStr] to include
a c-string to enum conversion method:

    inline void from_c_str(char const* str, Color &e) {
      using namespace std;
      if(0 == strcmp("Red_e", str)) { e = Color::Red_e; return; }
      if(0 == strcmp("Green_e", str)) { e = Color::Green_e; return; }
      if(0 == strcmp("Blue_e", str)) { e = Color::Blue_e; return; }
      string msg { "No Color matching:" };
      throw std::runtime_error(msg + str);
    }
""";

final baseDoc = '''
A base class of another class.

The style of inheritance is determined by [virtual] and [access]. Examples:

Default is *not* virtual and [public] inheritance:

    class_('derived')
    ..bases = [
      base('Base')
    ];

gives:

    class Derived : public Base {};

With overrides:

    class_('derived')
    ..bases = [
      base('Base')
      ..isVirtual = true
      ..access = protected
    ];

Gives:

    class Derived :
      protected virtual Base
    {
    };
''';

final accessDoc = '''
Access designation for a class member variable.

C++ supports *public*, *private* and *protected* designations. This designation
is at a higher abstraction in that selecting access determines both the c++
protection as well as the set of accessors that are generated. *Member*
instances have both *access* and *cppAccess* so full range is available, but
general cases should be covered by setting only the *access* variable of a
member.

* IA: *inaccessible* which provides no accessor with c++ access *private*.
  It is aliased to *ia*.

* RO: *read-only* which provides a read accessor with c++ access *private*.
  It is aliased to *ro*.

* RW: *read-write* which provides read and write accessor with c++ access *private*.
  It is aliased to *rw*.

* WO: *write-only* which provides write access and the c++ access is *private*.
  It is aliased to *wo*. It may sound counterintuitive, but a use case for this
  might be to accept the generated write accessor but hand code a read accessor
  requiring special logic.

Note: If the desire is to have a public member that is public and has no
accessors, set *cppAccess* to *public* andd set *access* to null.

# Examples

*cppAccess* null with *access* of *ro* gives:

    class C_1
    {
    public:
      //! getter for x_ (access is Ro)
      std::string const& x() const { return x_; }
    private:
      std::string x_ {};
    };

*cppAccess* CppAccess.protected with *access* of *ro* gives:

    class C_1
    {
    public:
      //! getter for x_ (access is Ro)
      std::string const& x() const { return x_; }
    protected:
      std::string x_ {};
    };
''';

final cppEntityDoc = """
Exposes common elements for named entities, including their [id] and
documentation. Additionally tracks parentage/ownership of entities.

This is abstract for purposes of ownership. Each [Entity] knows its
owning entity up until [Installation] which is the root entity. A call
to [generate] on [Installation] will [setOwnership] which subclasses
can trick down establishing ownership.

The purpose of linking all [Entity] instances in a virtual tree type
structure is so lookups can be done for entities.

[Entity] must be created with an argument representing an Id.  That
argument may be a string, in which case it is converted to an [Id].
That argument may be an [Id].

For many/most [Entity] subclasses there is often a corresponding
method that simply creates in instance of the subclass. For example,

    class Lib extends Entity... {
       Lib(Id id) : super(id);
       ...
    }

    Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));

This now allows this approach:

      final myLib = lib('my_awesome_lib')
        ..headers = [
          header('my_header')
          ..classes = [
            class_('my_class')
            ..members = [
              member('my_member')
            ]
          ]
        ];

      print(myLib);

prints:

    lib(myAwesomeLib)
      headers:
        header(myHeader)
          classes:[My_class]

      tests:
""";

final interfaceDoc = """
A collection of methods that as a group are either virtual or not.  A
*virtual* interface expresses a desire to have code generated that
will implement (i.e. derive from) the set of methods virtually. If the
interface is *not* virtual, it is an indication that the implementers
of the interface will provide implementations to be used via static
polymorphism.

      var md = new Interface('alarmist')
        ..doc = 'Methods that cause alarm'
        ..methodDecls = [
          'void shoutsFireInTheater(int volume)',
          'void wontStopWithTheGlobalWarming()',
          new MethodDecl.fromDecl('void growl()')..doc = 'Scare them'
        ];
      print(md);

prints:

    /**
     Methods that cause alarm
    */
    interface Alarmist
      void shouts_fire_in_theater(int volume) {
        // custom <shouts_fire_in_theater>
        // end <shouts_fire_in_theater>
      }
      void wont_stop_with_the_global_warming() {
        // custom <wont_stop_with_the_global_warming>
        // end <wont_stop_with_the_global_warming>
      }
      /**
       Scare them
      */
      void growl() {
        // custom <growl>
        // end <growl>
      }
    }
""";

final standardizedHeaderDoc = '''
Common headers unique to a [Lib] designed to provide consistency and
facilitate library usage.

- [libCommonHeader]: For a given [Lib], a place to put common types,
  declarations that need to be included by all other headers in the
  lib. If requested for a [Lib], all other headers in the [Lib] will
  inlude this. Therefore, it is important that this header *not*
  include other *non-common* headers in the [Lib]. The naming
  convention is: LIBNAME_common.hpp

- [libLoggingHeader]: For a given [Lib] a header to provide a logger
  instance. If requested for a [Lib], all other headers in the [Lib]
  will include this indirectly via *lib_common_header*. The naming
  convention is: LIBNAME_logging.hpp

- [ibInitializationHeader]: For a given [Lib] a header to provide
  library initialization and uninitialization routines. If requested
  for a [Lib], all other headers in the [Lib] will include this
  indirectly via *lib_common_header*. The naming convention is:
  LIBNAME_initialization.hpp

- [LibAllHeader]: For a given [Lib], this header will include all
  other headers. This is a convenience for clients writing non-library
  code. The naming convention is: LIBNAME_all.hpp

''';

final installationDoc = '''
The to level [CppEntity] representing the root of a C++ installation.

The composition of generatable [CppEntity] items starts here. This is
where the [root] (i.e. target root path) is defined, dictating
locations of the tree of C++. This is the object to configure *global*
type features like:

 - Provide a [Namer] to control the naming conventions

 - Provide a [TestProvider] to control how tests are provided

 - Provide a [LogProvider] to control what includes are required for
   the desired logging solution and how certain [Loggable] entities
   should log

 - Should support for logging api initialization be generated
''';

final _h5tTypeValues = [
  'H5T_NATIVE_CHAR',
  'H5T_NATIVE_SCHAR',
  'H5T_NATIVE_UCHAR',
  'H5T_NATIVE_SHORT',
  'H5T_NATIVE_USHORT',
  'H5T_NATIVE_INT',
  'H5T_NATIVE_UINT',
  'H5T_NATIVE_LONG',
  'H5T_NATIVE_ULONG',
  'H5T_NATIVE_LLONG',
  'H5T_NATIVE_ULLONG',
  'H5T_NATIVE_FLOAT',
  'H5T_NATIVE_DOUBLE',
  'H5T_NATIVE_INT16',
  'H5T_NATIVE_INT32',
  'H5T_NATIVE_INT64',
  'H5T_NATIVE_UINT16',
  'H5T_NATIVE_UINT32',
  'H5T_NATIVE_UINT64',
  'H5T_NATIVE_LDOUBLE',
  'H5T_NATIVE_B8',
  'H5T_NATIVE_B16',
  'H5T_NATIVE_B32',
  'H5T_NATIVE_B64',
  'H5T_NATIVE_OPAQUE',
  'H5T_NATIVE_HADDR',
  'H5T_NATIVE_HSIZE',
  'H5T_NATIVE_HSSIZE',
  'H5T_NATIVE_HERR',
  'H5T_NATIVE_HBOOL',
];

final _enumH5t = enum_('h5t_type')
  ..doc = 'Types defined in h5t api'
  ..values = _h5tTypeValues;

final _enumH5tMap = enumerate(_h5tTypeValues).fold(
    {},
    (prev, elm) => prev
      ..['H5tType.${_enumH5t.values[elm.index].camel}'] =
          doubleQuote(_h5tTypeValues[elm.index]));
