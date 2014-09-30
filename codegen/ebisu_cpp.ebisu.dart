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
    ]
    ..libraries = [
      library('cpp')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
        'package:quiver/iterables.dart',
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
        enum_('method')
        ..values = [
          id('equal'), id('less_than'),
          id('default_ctor'),
          id('copy_ctor'),
          id('move'),
          id('assign_copy'),
          id('assign_ctor'),
        ]
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
        ]
      ]
      ..parts = [
        part('utils')
        ..classes = [
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
            member('custom_blocks')..type = 'List<FileCodeBlock>'..classInit = [],
            member('code_blocks')
            ..type = 'Map<FileCodeBlock, CodeBlock>'..access = IA..classInit = {},
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
          class_('class')
          ..extend = 'Entity'
          ..members = [
            member('definition')..access = IA,
            member('struct')..doc = 'Is this definition a *struct*'
            ..classInit = false,
            member('template')..type = 'Template'..access = RO,
            member('bases')..type = 'List<Base>'..classInit = [],
            member('forward_ptrs')..type = 'List<PtrType>'..classInit = [],
            member('enums_forward')..type = 'List<Enum>'..classInit = [],
            member('enums')..type = 'List<Enum>'..classInit = [],
            member('members')..type = 'List<Member>'..classInit = [],
            member('methods')..type = 'List<Method>'..classInit = [],
            member('headers')..type = 'Headers'..access = RO,
            member('impl_headers')..type = 'Headers'..access = RO,
            member('custom_blocks')..type = 'List<ClassCodeBlock>'..classInit = [],
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
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('headers')..type = 'List<Header>'..classInit = [],
            member('installation')..type = 'Installation',
          ],
          class_('header')
          ..extend = 'CppFile'
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('file_path')..access = RO,
            member('classes')..type = 'List<Class>'..classInit = [],
          ],
          class_('impl')
          ..extend = 'CppFile'
          ..members = [
            member('namespace')..type = 'Namespace'..classInit = 'new Namespace()',
            member('file_path')..access = RO,
            member('classes')..type = 'List<Class>'..classInit = [],
          ]
        ],
        part('installation')
        ..classes = [
          class_('app')
          ..members = [
            member('installation')..type = 'Installation',
            member('classes')..type = 'List<Class>'..classInit = [],
          ],
          class_('script')
          ..members = [
            member('installation')..type = 'Installation',
          ],
          class_('test')
          ..members = [
            member('installation')..type = 'Installation',
          ],
          class_('installation')
          ..members = [
            member('id')..type = 'Id'..ctors = [''],
            member('root')..doc = 'Fully qualified path to installation'..access = RO,
            member('paths')..type = 'Map<String, String>'..classInit = {}..access = RO,
            member('apps')..type = 'List<App>'..classInit = [],
            member('scripts')..type = 'List<Script>'..classInit = [],
            member('libs')..type = 'List<Lib>'..classInit = [],
            member('tests')..type = 'List<Test>'..classInit = [],
          ]
        ],
      ]
    ];

  ebisu.generate();
}