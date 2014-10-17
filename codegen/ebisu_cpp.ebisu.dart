import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import "package:logging/logging.dart";

String _topDir;

void main() {

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = path.absolute(Platform.script.path);
  _topDir = path.dirname(path.dirname(here));
  System ebisu = system('ebisu_cpp')
    ..includeHop = true
    ..pubSpec.version = '0.0.1'
    ..pubSpec.doc = 'A library that supports code generation of cpp and others'
    ..pubSpec.addDependency(new PubDependency('ebisu'))
    ..pubSpec.addDependency(new PubDependency('path'))
    ..pubSpec.addDevDependency(new PubDependency('unittest'))
    ..rootPath = _topDir
    ..doc = 'A library that supports code generation of cpp and others'
    ..testLibraries = [
      library('test_cpp_enum'),
      library('test_cpp_member'),
      library('test_cpp_class'),
      library('test_cpp_utils'),
      library('test_cpp_schema'),
    ]
    ..libraries = [
      library('db_schema')
      ..imports = [
        'dart:io',
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        "'package:path/path.dart' as path",
        'package:ini/ini.dart',
        'package:sqljocky/sqljocky.dart',
        'package:ebisu_cpp/cpp.dart',
        'dart:async',
      ]
      ..doc = 'Reads schema and stores tables/column field types'
      ..parts = [
        part('meta')
        ..classes = [
          class_('schema')
          ..members = [
            member('name')..ctors = [''],
            member('tables')..type = 'List<Table>'..classInit = []..ctors = [''],
          ],
          class_('query'),
          class_('table')
          ..members = [
            member('name'),
            member('columns')..type = 'List<Column>'..classInit = [],
          ],
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
          class_('column')
          ..members = [
            member('name'),
            member('type')..type = 'DataType',
            member('is_null')..classInit = false,
            member('is_primary_key')..classInit = false,
            member('is_auto_increment')..classInit = false,
            member('default_value'),
            member('extra')
          ]
        ],
        part('mysql')
        ..classes = [

        ],
        part('odbc_ini')
        ..classes = [
          class_('odbc_ini')
          ..defaultMemberAccess = RO
          ..members = [
            member('entries')..type = 'Map<String, OdbcIniEntry>'..classInit = {}
          ],
          class_('odbc_ini_entry')
          ..defaultMemberAccess = RO
          ..members = [
            member('user')..ctors = [''],
            member('password')..ctors = [''],
            member('database')..ctors = [''],
          ]
        ],
        part('generator')
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
          class_('schema_code_generator')
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..doc = '''
Given a schema generates code to support accessing tables and configured
queries. Makes use of the otl c++ library.
'''
          ..members = [
            member('schema')..type = 'Schema',
            member('queries')..type = 'List<Query>'..classInit = [],
            member('table_filter')..type = 'TableFilter'..classInit = '(Table t) => true',
          ],
          class_('table_gateway_generator')
          ..members = [
            member('schema')..type = 'Schema',
            member('table')..type = 'Table',
            member('table_id')..type = 'Id',
            member('table_name'),
          ]
        ],
      ],
      library('cpp')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        'package:quiver/iterables.dart',
        "'package:path/path.dart' as path",
      ]
      ..enums = [
        enum_('access')
        ..doc = 'Access for member variable - ia - inaccessible, ro - read/only, rw read/write'
        ..values = [
          id('ia'), id('ro'), id('rw'), id('wo'),
        ],
        enum_('cpp_access')
        ..doc = 'Cpp access'
        ..isSnakeString = true
        ..values = [
          id('public'), id('private'), id('protected'),
        ],
        enum_('ref_type')
        ..doc = 'Reference type'
        ..values = [
          id('ref'), id('cref'), id('vref'), id('cvref'), id('value'),
        ],
        enum_('ptr_type')
        ..doc = 'Standard pointer type declaration'
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
          class_('code_generator')..isAbstract = true,
          class_('namespace')
          ..members = [
            member('names')..type = 'List<String>'..classInit = [],
          ],
          class_('headers')
          ..doc = 'Collection of headers to be included'
          ..members = [
            member('headers')
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
          ..isAbstract = true
          ..extend = 'Entity'
          ..members = [
            member('namespace')..type = 'Namespace',
            member('custom_blocks')..type = 'List<FileCodeBlock>'..classInit = [],
            member('code_blocks')
            ..type = 'Map<FileCodeBlock, CodeBlock>'..access = IA..classInit = {},
            member('headers')..type = 'Headers'..access = RO..classInit = 'new Headers()',
          ],
        ],
        part('enum')
        ..classes = [
          class_('enum')
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
          ..extend = 'Entity'
          ..members = [
            member('type')..doc = 'Type of member',
            member('init')..doc = 'Initialization of member (if type is null and Dart type is key in { int:int, double:double }, cpp type is set to value type)'..access = RO,
            member('access')
            ..doc = 'Idiomatic access of member'..type = 'Access'..classInit = 'ia',
            member('cpp_access')
            ..doc = 'C++ style access of member'..type = 'CppAccess'..access = WO,
            member('ref_type')
            ..doc = 'Ref type of member'..type = 'RefType'..classInit = 'value',
            member('by_ref')
            ..doc = 'Pass member around by reference'..classInit = false,
            member('static')..doc = 'Is the member static'
            ..classInit = false,
            member('mutable')..doc = 'Is the member mutable'
            ..classInit = false,
            member('is_const')..doc = 'Is the member const'
            ..classInit = false,
            member('no_init')
            ..doc = 'If set will not initialize variable - use sparingly'
            ..classInit = false,
          ],
        ],
        part('class')
        ..enums = [
          enum_('class_code_block')
          ..values = [
            id('cls_public'),
            id('cls_protected'),
            id('cls_private'),
            id('cls_pre_decl'),
            id('cls_post_decl'),
          ]
        ]
        ..classes = [
          class_('class_method')
          ..isAbstract = true
          ..members = [
            member('parent')..type = 'Class'..access = RO,
            member('log')..doc = 'If true add logging'..classInit = false,
            member('template')..type = 'Template'..access = RO,
          ],
          class_('default_method')
          ..isAbstract = true
          ..extend = 'ClassMethod'
          ..members = [
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false,
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
          class_('dtor')..extend = 'DefaultMethod',
          class_('member_ctor')
          ..extend = 'ClassMethod'
          ..ctorSansNew = true
          ..members = [
            member('member_args')
            ..doc = 'List of members that are passed as arguments for initialization'
            ..type = 'List<String>'
            ..ctors = ['']
            ..classInit = [],
            member('opt_init')
            ..doc = 'Map member name to text for initialization'
            ..type = 'Map<String, String>'..classInit = {}
            ..ctorsOpt = [''],
            member('decls')
            ..doc = 'List of additional decls ["Type Argname", ...]'
            ..type = 'List<String>'..classInit = []
            ..ctorsOpt = [''],
            member('has_custom')
            ..doc = 'Has custom code, so needs protect block'..classInit = false,
          ],
          class_('op_equal')..extend = 'ClassMethod',
          class_('op_less')..extend = 'ClassMethod',
          class_('op_out')..extend = 'ClassMethod',
          class_('class')
          ..extend = 'Entity'
          ..members = [
            member('definition')..access = IA,
            member('struct')..doc = 'Is this definition a *struct*'
            ..classInit = false,
            member('template')..type = 'Template'..access = RO,
            member('usings')..type = 'List<String>'..classInit = [],
            member('bases')..type = 'List<Base>'..classInit = [],
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
          ],
        ],
        part('lib')
        ..enums = [
          enum_('file_code_block')
          ..values = [
            id('fcb_pre_namespace'),
            id('fcb_post_namespace'),
            id('fcb_begin_namespace'),
            id('fcb_end_namespace'),
          ]
        ]
        ..classes = [
          class_('lib')
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('headers')..type = 'List<Header>'..classInit = [],
          ],
          class_('header')
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
            member('classes')..type = 'List<Class>'..classInit = [],
          ],
          class_('impl')
          ..extend = 'CppFile'
          ..members = [
            member('file_path')..access = RO,
            member('classes')..type = 'List<Class>'..classInit = [],
          ]
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
          class_('app')
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
            member('classes')..type = 'List<Class>'..classInit = [],
          ],
          class_('app_builder')
          ..isAbstract = true
          ..implement = [ 'CodeGenerator' ]
          ..doc = 'Creates builder for an application'
          ..members = [
            member('app')..type = 'App'..ctors = ['']
          ],
          class_('jam_app_builder')
          ..extend = 'AppBuilder',
          class_('script')
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
          ],
          class_('test')
          ..extend = 'Entity'
          ..mixins = [ 'InstallationCodeGenerator' ]
          ..members = [
          ],
          class_('installation')
          ..implement = [ 'CodeGenerator' ]
          ..members = [
            member('id')..type = 'Id'..ctors = [''],
            member('root')..doc = 'Fully qualified path to installation'..access = RO,
            member('paths')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('apps')..type = 'List<App>'..classInit = [],
            member('scripts')..type = 'List<Script>'..classInit = [],
            member('schema_code_generators')..type = 'List<InstallationCodeGenerator>'..classInit = [],
            member('libs')..type = 'List<Lib>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
          ]
        ],
      ]
    ];

  ebisu.generate();
}