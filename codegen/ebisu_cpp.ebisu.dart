import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;

void main() {

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.path);
  _topDir = path.dirname(path.dirname(here));
  useDartFormatter = true;
  System ebisu = system('ebisu_cpp')
    ..includeHop = true
    ..pubSpec.version = '0.0.1'
    ..pubSpec.doc = 'A library that supports code generation of cpp and others'
    ..pubSpec.addDependency(new PubDependency('path'))
    ..pubSpec.addDevDependency(new PubDependency('unittest'))
    ..rootPath = _topDir
    ..doc = 'A library that supports code generation of cpp and others'
    ..testLibraries = [
      library('test_cpp_enum'),
      library('test_cpp_member'),
      library('test_cpp_class'),
      library('test_cpp_utils'),
    ]
    ..libraries = [
      library('db_schema')
      ..imports = [
        'dart:io',
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        "'package:path/path.dart' as path",
        'package:ini/ini.dart',
        '"package:sqljocky/sqljocky.dart" hide Query',
        'package:ebisu_cpp/cpp.dart',
        'package:magus/schema.dart',
        'dart:async',
      ]
      ..doc = 'Reads schema and stores tables/column field types'
      ..parts = [
        part('meta')
        ..classes = [
          class_('data_type')
          ..ctorConst = ['']
          ..opEquals = true
          ..members = [
            member('db_type')..isFinal = true..ctors = [''],
            member('cpp_type')..isFinal = true..ctors = [''],
          ],
          class_('fixed_varchar')
          ..extend = 'DataType'
          ..members = [
            member('size')..type = 'int'
          ],
        ],
        part('test_support')
        ..classes = [
          class_('gateway')
          ..immutable = true
          ..members = [
            member('table_details')..type = 'TableDetails',
          ],
          class_('gateway_test_generator')
          ..doc = 'Class to generate test code to exercise the table gateway'
          ..ctorCustoms = ['']
          ..members = [
            member('test')..type = 'Test'..ctors = [''],
            member('table_details')..type = 'TableDetails'..ctors = [''],
            member('namespace')..type = 'Namespace'..ctors = [''],
            member('gateways')
            ..doc = 'Table details for transitive closure by foreign keys'
            ..type = 'List<Gateway>'
            ..classInit = [],
          ],
        ],
        part('generator')
        ..classes = [
          class_('schema_code_generator')
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..isAbstract = true
          ..members = [
            member('schema')..type = 'Schema',
            member('id')..type = 'Id'..access = RO,
            member('queries')..type = 'List<Query>'..classInit = [],
            member('table_filter')..type = 'TableFilter'..classInit = '(Table t) => true',
          ],
          class_('table_details')
          ..immutable = true
          ..members = [
            member('schema')..type = 'Schema',
            member('table')..type = 'Table',
            member('table_id')..type = 'Id',
            member('table_name'),
            member('class_name'),
            member('key_class_id')..type = 'Id',
            member('value_class_id')..type = 'Id',
          ],
          class_('table_gateway_generator')
          ..isAbstract = true
          ..members = [
            member('installation')..type = 'Installation',
            member('schema_code_generator')..type = 'SchemaCodeGenerator',
            member('table_details')..type = 'TableDetails'..access = IA,
            member('key_class')..type = 'Class',
            member('value_class')..type = 'Class',
            member('header')..type = 'Header'..access = IA,
          ]
        ],
        part('otl_generator')
        ..enums = [
          enum_('bind_data_type')
          ..libraryScopedValues = true
          ..values = [
            id('bdt_int'),
            id('bdt_short'),
            id('bdt_double'),
            id('bdt_bigint'),
            id('bdt_sized_char'),
            id('bdt_unsized_char'),
            id('bdt_varchar_long'),
            id('bdt_timestamp'),
          ]
        ]
        ..classes = [
          class_('otl_bind_variable')
          ..members = [
            member('name'),
            member('data_type')..type = 'BindDataType',
            member('size')..classInit = 0,
          ],
          class_('otl_schema_code_generator')
          ..extend = 'SchemaCodeGenerator'
          ..doc = '''
Given a schema generates code to support accessing tables and configured
queries. Makes use of the otl c++ library.
'''
          ..members = [
            member('connection_class_id')..type = 'Id'..access = RO,
            member('connection_class_name')..access = RO,
          ],
          class_('otl_table_gateway_generator')
          ..extend = 'TableGatewayGenerator'
        ],
        part('poco_generator')
        ..classes = [
          class_('poco_schema_code_generator')
          ..extend = 'SchemaCodeGenerator'
          ..doc = '''
Given a schema generates code to support accessing tables and configured
queries. Makes use of the poco c++ library.
'''
          ..members = [
            member('session_class_id')..type = 'Id'..access = RO,
            member('session_class_name')..access = RO,
          ],
          class_('poco_table_gateway_generator')
          ..extend = 'TableGatewayGenerator'
        ]
      ],
      library('cpp')
      ..doc = '''
Library to facility generation of c++ code.

The intent is to get as declarative as possible with the specification
of C++ entities to make code generation as simple and fun as possible.

'''
      ..includeLogger = true
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        'package:quiver/iterables.dart',
        "'package:path/path.dart' as path",
        'dart:io',
      ]
      ..enums = [
        enum_('access')
        ..doc = 'Access for member variable - ia - inaccessible, ro - read/only, rw read/write'
        ..libraryScopedValues = true
        ..values = [
          id('ia'), id('ro'), id('rw'), id('wo'),
        ],
        enum_('cpp_access')
        ..doc = 'Cpp access'
        ..libraryScopedValues = true
        ..values = [
          id('public'), id('private'), id('protected'),
        ],
        enum_('ref_type')
        ..doc = 'Reference type'
        ..libraryScopedValues = true
        ..values = [
          id('ref'), id('cref'), id('vref'), id('cvref'), id('value'),
        ],
        enum_('ptr_type')
        ..doc = 'Standard pointer type declaration'
        ..libraryScopedValues = true
        ..values = [
          id('sptr'), id('uptr'), id('scptr'), id('ucptr'),
        ],
      ]
      ..classes = [
        class_('entity')
        ..members = [
          member('id')
          ..doc = 'Id for the entity'
          ..type = 'Id'..ctors = [''],
          member('brief')
          ..doc = 'Brief description for the entity',
          member('descr')
          ..doc = 'Description of entity',
        ],
        class_('template')
        ..members = [
          member('decls')..type = 'List<String>',
        ],
      ]
      ..parts = [
        part('utils')
        ..classes = [
          class_('const_expr')
          ..extend = 'Entity'
          ..doc = 'Simple variable constexprs'
          ..members = [
            member('type'),
            member('value')..access = RO,
            member('namespace')..type = 'Namespace',
          ],
          class_('forward_decl')
          ..doc = 'A forward declaration'
          ..ctorSansNew = true
          ..members = [
            member('type')..ctors = [''],
            member('namespace')..type = 'Namespace'..ctorsOpt = [''],
          ],
          class_('code_generator')
          ..doc = 'Establishes an interface for generating code'
          ..isAbstract = true,
          class_('namespace')
          ..doc = 'Represents a c++ namespace which is essentially a list of names'
          ..members = [
            member('names')..type = 'List<String>'..classInit = [],
          ],
          class_('includes')
          ..doc = 'Collection of header includes'
          ..members = [
            member('included')
            ..access = RO
            ..type = 'Set<String>'
          ],
          class_('code_block')
          ..doc = 'Wraps an optional protection block with optional code injection'
          ..ctorSansNew = true
          ..members = [
            member('tag')
            ..doc = 'Tag for protect block. If present includes protect block'
            ..ctors = [''],
            member('snippets')..type = 'List<String>'..classInit = [],
            member('has_snippets_first')..classInit = false,
          ],
          class_('base')
          ..doc = 'Base class'
          ..ctorSansNew = true
          ..members = [
            member('class_name')..ctors = [''],
            member('access')
            ..doc = 'Is base class public, protected, or private'
            ..type = 'CppAccess'..classInit = 'public',
            member('init')
            ..doc = 'How to initiailize the base class in ctor initializer',
            member('virtual')
            ..doc = 'If true inheritance is virtual'
            ..classInit = false,
            member('streamable')
            ..doc = 'If true and streamers are being provided, base is streamed first'
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
          ..extend = 'Entity'
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
            ..type = 'List<FileCodeBlock>'..classInit = [],
            member('code_blocks')
            ..doc = '''
Mapping of the *FileCodeBlock* to the corresponding *CodeBlock*.'''
            ..type = 'Map<FileCodeBlock, CodeBlock>'..access = IA..classInit = {},
            member('classes')
            ..doc = 'List of classes whose definitions are included in this file'
            ..type = 'List<Class>'..classInit = [],
            member('includes')
            ..doc = 'List of includes required by this c++ file'
            ..type = 'Includes'..access = RO..classInit = 'new Includes()',
            member('const_exprs')
            ..doc = 'List of c++ *constexprs* that will appear near the top of the file'
            ..type = 'List<ConstExpr>'..classInit = [],
            member('forward_decls')
            ..doc = 'List of forward declarations that will appear near the top of the file'
            ..type = 'List<ForwardDecl>'..classInit = [],
            member('usings')
            ..doc = 'List of using statements that will appear near the top of the file'
            ..type = 'List<String>'..classInit = [],
            member('enums')
            ..doc = 'List of enumerations that will appear near the top of the file'
            ..type = 'List<Enum>'..classInit = [],
          ],
        ],
        part('enum')
        ..classes = [
          class_('enum')
          ..doc = 'A c++ enumeration'
          ..extend = 'Entity'
          ..members = [
            member('values')
            ..doc = 'Strings for the values of the enum'
            ..type = 'List<String>'
            ..access = RO,
            member('ids')
            ..doc = 'Ids for the values of the enum'
            ..type = 'List<Id>'
            ..access = IA,
            member('value_names')
            ..doc = 'Names for values as they appear'
            ..type = 'List<String>'
            ..access = IA,
            member('value_map')
            ..doc = 'String value, numeric value pairs'
            ..type = 'Map<String, int>'
            ..access = RO,
            member('is_class')
            ..doc = 'If true the enum is a class enum as opposed to "plain" enum'..classInit = false,
            member('has_from_c_str')
            ..doc = 'If true adds from_c_str method'..classInit = false,
            member('has_to_c_str')
            ..doc = 'If true adds to_c_str method'..classInit = false,
            member('streamable')
            ..doc = 'If true adds streaming support'..classInit = false,
            member('is_mask')
            ..doc = 'If true the values are powers of two for bit masking'..classInit = false,
            member('is_nested')
            ..doc = 'If true is nested in class and requires *friend* stream support'..classInit = false,
          ],
        ],
        part('member')
        ..classes = [
          class_('member')
          ..doc = 'A member or field included in a class'
          ..extend = 'Entity'
          ..members = [
            member('type')..doc = 'Type of member',
            member('init')
            ..doc = 'Initialization of member (if type is null and Dart type is key in { int:int, double:double }, cpp type is set to value type)'..access = RO,
            member('ctor_init')
            ..doc = '''
Rare usage - member b depends on member a (e.g. b is just a string rep of a
which is int), a is passed in for construction but b can be initialized directly
from a. If ctorInit is set on a member, any memberCtor will include this text to
initialize it''',
            member('access')
            ..doc = 'Idiomatic access of member'..type = 'Access'..classInit = 'ia',
            member('cpp_access')
            ..doc = 'C++ style access of member'..type = 'CppAccess'..access = WO,
            member('ref_type')
            ..doc = 'Ref type of member'..type = 'RefType'..classInit = 'value',
            member('by_ref')
            ..doc = 'Pass member around by reference'..type = 'bool'..access = WO,
            member('static')..doc = 'Is the member static'
            ..classInit = false,
            member('mutable')..doc = 'Is the member mutable'
            ..classInit = false,
            member('is_const')..doc = 'Is the member const'
            ..classInit = false
            ..access = WO,
            member('is_const_expr')..doc = 'Is the member a constexprt'
            ..classInit = false,
            member('no_init')
            ..doc = 'If set will not initialize variable - use sparingly'
            ..classInit = false,
            member('serialize_int')
            ..doc = 'Indicates this member is an enum and if serialized should be serialized as int'
            ..classInit = false,
            member('cereal_transient')
            ..doc = 'Indicates this member should not be serialized via cereal'
            ..classInit = false,
          ],
        ],
        part('class')
        ..enums = [
          enum_('class_code_block')
          ..libraryScopedValues = true
          ..values = [
            id('cls_public'),
            id('cls_protected'),
            id('cls_private'),
            id('cls_pre_decl'),
            id('cls_post_decl'),
          ],
        ]
        ..classes = [
          class_('class_method')
          ..isAbstract = true
          ..members = [
            member('parent')..type = 'Class'..access = RO,
            member('log')..doc = 'If true add logging'..classInit = false,
            member('template')..type = 'Template'..access = RO,
            member('cpp_access')
            ..doc = 'C++ style access of method'
            ..type = 'CppAccess'
            ..classInit = 'public',
          ],
          class_('default_method')
          ..isAbstract = true
          ..extend = 'ClassMethod'
          ..members = [
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false,
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
            member('use_default')..classInit = false,
            member('delete')..classInit = false,
          ],
          class_('default_ctor')
          ..doc = 'Default ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('copy_ctor')
          ..doc = 'Copy ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('move_ctor')
          ..doc = 'Move ctor, autoinitialized on read'..extend = 'DefaultMethod',
          class_('assign_copy')..extend = 'DefaultMethod',
          class_('assign_move')..extend = 'DefaultMethod',
          class_('dtor')
          ..doc = 'Provides a destructor'
          ..extend = 'DefaultMethod'
          ..members = [
            member('abstract')..classInit = false
          ],
          class_('member_ctor_parm')
          ..doc = '''
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

'''


          ..ctorSansNew = true
          ..members = [
            member('name')
            ..doc = 'Name of member initialized by argument to member ctor'
            ..isFinal = true
            ..ctors = [''],
            member('member')
            ..doc = 'cpp member to be initialized'
            ..type = 'Member',
            member('parm_decl')..doc = '''
*Override* for arguemnt declaration. This is rarely needed. Suppose
you want to initialize member *Y y* from an input argument *X x* that
requires a special function *f* to do the conversion:

    Class(X x) : y_(f(x)) {}

The usage would be:

memberCtor([ memberCtorParm("y")..parmDecl = "X x" ])

''',
            member('init')..doc = '''
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

The usage would be:

    memberCtor([
      memberCtorParm("previous_mode")
      ..parmDecl = "mode_t new_mode"
      ..init = "umask(new_mode)"
    ])

'''
            ..access = WO,
            member('default_value'),
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
            ..doc = 'List of members that are passed as arguments for initialization'
            ..type = 'List<MemberCtorParm>'
            ..classInit = [],
            member('decls')
            ..doc = 'List of additional decls ["Type Argname", ...]'
            ..type = 'List<String>',
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false..access = WO,
            member('custom_label')
            ..doc = 'Label for custom protect block if desired'..access = WO,
            member('all_members')
            ..doc = 'If set automatically includes all members as args'
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
          ..extend = 'ClassMethod',
          class_('class')
          ..extend = 'Entity'
          ..members = [
            member('definition')
            ..doc = '''
The contents of the class definition. *Inaccessible* and established
as a member so custom *definition* getter can be called multiple times
on the same class and results lazy-inited here'''
            ..access = IA,
            member('struct')
            ..doc = 'Is this definition a *struct*'
            ..classInit = false,
            member('template')
            ..doc = 'The template by which the class is parameterized'
            ..type = 'Template'..access = RO,
            member('usings')
            ..doc = '''
List of usings that will be scoped to this class near the top of
the class definition.'''
            ..type = 'List<String>'..classInit = [],
            member('usings_post_decl')
            ..doc = '''
List of usings to occur after the class declaration. Sometimes it is
useful to establish some type definitions directly following the class
so they may be reused among any client of the class. For instance if
class *Foo* will most commonly be used in vector, the using occuring
just after the class definition will work:

    using Foo = std::vector<Foo>;

'''
            ..type = 'List<String>'..classInit = [],
            member('bases')
            ..doc = '''
Base classes this class derives form.

'''
            ..type = 'List<Base>'..classInit = [],
            member('default_ctor')..type = 'DefaultCtor'..access = IA,
            member('copy_ctor')..type = 'CopyCtor'..access = IA,
            member('move_ctor')..type = 'MoveCtor'..access = IA,
            member('assign_copy')..type = 'AssignCopy'..access = IA,
            member('assign_move')..type = 'AssignMove'..access = IA,
            member('dtor')..type = 'Dtor'..access = IA,
            member('member_ctors')..type = 'List<MemberCtor>'..classInit = [],
            member('op_equal')..type = 'OpEqual'..access = IA,
            member('op_less')..type = 'OpLess'..access = IA,
            member('op_out')..type = 'OpOut'..access = IA,
            member('forward_ptrs')..type = 'List<PtrType>'..classInit = [],
            member('enums_forward')..type = 'List<Enum>'..classInit = [],
            member('enums')..type = 'List<Enum>'..classInit = [],
            member('members')..type = 'List<Member>'..classInit = [],
            member('custom_blocks')..type = 'List<ClassCodeBlock>'..classInit = [],
            member('is_singleton')..classInit = false,
            member('code_blocks')
            ..access = RO
            ..type = 'Map<ClassCodeBlock, CodeBlock>'..classInit = {},
            member('streamable')
            ..doc = 'If true adds streaming support'..classInit = false,
            member('uses_streamers')
            ..doc = 'If true adds {using fcs::utils::streamers::operator<<} to streamer'
            ..classInit = false,
            member('include_test')
            ..doc = 'If true adds test function to tests of the header it belongs to'
            ..classInit = false,
            member('immutable')
            ..doc = 'If true makes members const provides single ctor'
            ..classInit = false,
            member('serializers')
            ..doc = 'List of processors supporting flavors of serialization'
            ..type = 'List<Serializer>'
            ..classInit = [],
          ],
        ],
        part('serializer')
        ..enums = [
          enum_('serialization_style')
          ..doc = 'Serialization using *cereal* supports these types of serialization'
          ..libraryScopedValues = true
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
          ..doc = 'Provides support for serialization as *delimited separated values*'
          ..implement = [ 'Serializer' ]
          ..members = [
            member('delimiter')..classInit = ':',
          ],
          class_('cereal')
          ..doc = 'Adds support for serialization using *cereal*'
          ..implement = [ 'Serializer' ]
          ..members = [
            member('styles')..type = 'List<SerializationStyle>'..classInit = [],
          ],
        ],
        part('header')
        ..classes = [
          class_('header')
          ..doc = 'A single c++ header'
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
            member('include_test')..classInit = false,
            member('test')..type = 'Test'..access = IA,
            member('is_api_header')
            ..doc = '''
If true marks this header as special to the set of headers in its library in that:
(1) It will be automatically included by all other headers
(2) For windows systems it will be the place to provide the api decl support
(3) Will have code that initializes the api
'''
            ..classInit = false,
          ],
        ],
        part('impl')
        ..classes = [
          class_('impl')
          ..doc = 'A single implementation file (i.e. *cpp* file)'
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
          ]
        ],
        part('lib')
        ..enums = [
          enum_('file_code_block')
          ..doc = 'Set of pre-canned blocks where custom or generated code can be placed'
          ..libraryScopedValues = true
          ..values = [
            id('fcb_custom_includes'),
            id('fcb_pre_namespace'),
            id('fcb_post_namespace'),
            id('fcb_begin_namespace'),
            id('fcb_end_namespace'),
          ]
        ]
        ..classes = [
          class_('lib')
          ..doc = 'A c++ library'
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('headers')..type = 'List<Header>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
          ],
        ],
        part('app')
        ..enums = [
          enum_('arg_type')
          ..doc = 'Set of argument types supported by command line option processing'
          ..requiresClass = true
          ..values = [
            id('int'),
            id('double'),
            id('string'),
            id('flag'),
          ]
        ]
        ..classes = [
          class_('app_arg')
          ..doc = '''
Metadata associated with an argument to an application.  Requires and
geared to features supported by boost::program_options.
'''
          ..extend = 'Entity'
          ..members = [
            member('type')..type = 'ArgType'..classInit = 'ArgType.STRING',
            member('short_name'),
            member('is_multiple')..classInit = false,
            member('is_required')..classInit = false,
            member('default_value')..type = 'Object'..access = RO,
          ],
          class_('app')
          ..doc = 'A c++ application'
          ..extend = 'Impl'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
            member('args')
            ..doc = 'Command line arguments specific to this application'
            ..type = 'List<AppArg>'..classInit = [],
            member('namespace')
            ..doc = 'Namespace associated with application code'
            ..type = 'Namespace'..access = IA,
            member('headers')
            ..doc = '''
Additional headers that are associated with the application itself, as
opposed to belonging to a reusable library.'''
            ..type = 'List<Header>'..classInit = [],
            member('impls')
            ..doc = '''
Additional implementation files associated with the application
itself, as opposed to belonging to a reusable library.'''
            ..type = 'List<Impl>'..classInit = [],
            member('required_libs')
            ..doc = '''
Libraries required to build this executable. *Warning* potentially
deprecated in the future. Originally when generating boost jam files
it was convenient to associate the required libraries directly in the
code generation scripts. With cmake it was simpler to just incorporate
protect blocks where the required libs could be easily added.
'''
            ..type = 'List<String>'..classInit = [],
            member('builders')
            ..doc = 'List of builders to generate build scripts of a desired flavor (bjam,...)'
            ..type = 'List<AppBuilder>'..classInit = [],
          ],
          class_('app_builder')
          ..doc = '''
Base class establishing interface for generating build scripts for
libraries, apps, and tests'''
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('app')..type = 'App'
          ],
        ],
        part('cmake_support')
        ..classes = [
          class_('cmake_installation_builder')
          ..extend = 'InstallationBuilder',
        ],
        part('jam_support')
        ..classes = [
          class_('jam_installation_builder')
          ..doc = '''
Effectively just a placeholder, the presence of which in an installation
indicates bjam shoud be set up per app and tests in the installation.
'''
          ..extend = 'InstallationBuilder',
          class_('jam_app_builder')
          ..extend = 'AppBuilder',
          class_('jam_test_builder')
          ..extend = 'TestBuilder',
          class_('site_config')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
          class_('user_config')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
          class_('jam_constant')
          ..members = [
            member('constant'),
            member('value'),
          ],
          class_('jam_file_top')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
            member('include_paths')..type = 'List<String>'..classInit = [],
            member('constants')..type = 'List<JamConstant>'..classInit = [],
          ],
          class_('jam_root')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('installation')..type = 'Installation'..ctors = [''],
          ],
        ],
        part('script')
        ..classes = [
          class_('script')
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
          ],
        ],
        part('test')
        ..classes = [
          class_('test')
          ..extend = 'Impl'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
            member('file_path')..access = RO,
            member('header_under_test')..type = 'Header',
            member('headers')..type = 'List<Header>'..classInit = [],
            member('impls')..type = 'List<Impl>'..classInit = [],
            member('test_functions')..type = 'List<String>'..classInit = []..access = RO,
            member('test_implementations')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('required_libs')..type = 'List<String>'..classInit = [],
          ],
          class_('test_builder')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = 'Creates builder for test folder'
          ..members = [
            member('lib')..type = 'Lib'..ctors = [''],
            member('directory')..ctors = [''],
            member('tests')..type = 'List<Test>'..ctors = ['']
          ],
        ],
        part('installation')
        ..classes = [
          class_('installation_code_generator')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = 'A CodeGenerator tied to a c++ installation'
          ..members = [
            member('installation')..type = 'Installation',
          ],
          class_('installation_builder')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = '''
Creates builder for an installation (ie ties together all build artifacts)
'''
          ..members = [
            member('installation')..type = 'Installation'
          ],
          class_('installation')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('id')..type = 'Id'..ctors = [''],
            member('root')..doc = 'Fully qualified path to installation'..access = RO,
            member('paths')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('libs')..type = 'List<Lib>'..classInit = [],
            member('apps')..type = 'List<App>'..classInit = [],
            member('scripts')..type = 'List<Script>'..classInit = [],
            member('schema_code_generators')..type = 'List<InstallationCodeGenerator>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
            member('generated_libs')..type = 'List<Lib>'..classInit = []..access = RO,
            member('generated_apps')..type = 'List<App>'..classInit = []..access = RO,
            member('builders')
            ..doc = 'List of builders for the installation (bjam, cmake)'
            ..type = 'List<InstallationBuilder>'..classInit = [],
          ],
          class_('path_locator')
          ..members = [
            member('env_var')
            ..doc = 'Environment variable specifying location of path, if set this path is used'
            ..isFinal = true,
            member('default_path')
            ..doc = 'Default path for the item in question'
            ..isFinal = true,
            member('path')..access = RO,
          ],
        ],
      ]
    ];

  ebisu.generate();
}