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
      ]
      ..parts = [
        part('utils')
        ..classes = [
          class_('namespace')
          ..members = [
            member('names')..type = 'List<String>',
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
          ]
        ],
        part('file')
        ..classes = [
          class_('cpp_file'),
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
            member('is_streamable')
            ..doc = 'If true adds streaming support'..classInit = false,
            member('is_mask')
            ..doc = 'If true the values are powers of two for bit masking'..classInit = false,
          ],
        ],
        part('member')
        ..classes = [
          class_('member')
          ..extend = 'Entity'
          ..members = [
            member('type')..doc = 'Type of member',
            member('init')..doc = 'Initialization of member',
            member('access')..doc = 'Access of member'..type = 'Access'..classInit = 'ro',
            member('ref_type')..doc = 'Ref type of member'..type = 'RefType'..classInit = 'value',
            member('static')..doc = 'Is the member static'
            ..classInit = false,
            member('mutable')..doc = 'Is the member mutable'
            ..classInit = false,
          ],
        ],
        part('class')
        ..enums = [
          enum_('code_blocks')
          ..values = [
            id('cb_public'),
            id('cb_protected'),
            id('cb_private'),
            id('cb_pre_decl'),
            id('cb_post_decl'),
          ]
        ]
        ..classes = [
          class_('class')
          ..extend = 'Entity'
          ..members = [
            member('definition')..access = IA,
            member('struct')..doc = 'Is this definition a *struct*'
            ..classInit = false,
            member('bases_public')..type = 'List<String>'..classInit = [],
            member('bases_private')..type = 'List<String>'..classInit = [],
            member('bases_protected')..type = 'List<String>'..classInit = [],
            member('forward_ptrs')..type = 'List<PtrType>'..classInit = [],
            member('enums_forward')..type = 'List<Enum>'..classInit = [],
            member('enums')..type = 'List<Enum>'..classInit = [],
            member('members')..type = 'List<Member>'..classInit = [],
            member('methods')..type = 'List<Method>'..classInit = [],
            member('headers')..type = 'Headers'..access = RO,
            member('impl_headers')..type = 'Headers'..access = RO,
            member('custom_blocks')..type = 'List<CodeBlocks>'..classInit = [],
            member('code_blocks')
            ..access = RO
            ..type = 'Map<CodeBlocks, CodeBlock>'..classInit = {},
          ],
        ],
        part('lib')
        ..classes = [
          class_('lib')
          ..extend = 'Entity'
          ..members = [
            member('classes')..type = 'List<Class>'..classInit = [],
          ]
        ]
      ]
    ];

  ebisu.generate();
}