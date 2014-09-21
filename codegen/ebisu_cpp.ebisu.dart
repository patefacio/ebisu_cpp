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
      library('test_cpp_class'),
      library('test_cpp_utils'),
    ]
    ..libraries = [
      library('cpp_utils')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
      ]
      ..classes = [
        class_('namespace')
        ..members = [
          member('names')..type = 'List<String>',
        ]
      ],
      library('cpp_file')
      ..classes = [
        class_('cpp_file'),
      ],
      library('cpp_enum')
      ..imports = [
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
      ]
      ..classes = [
        class_('cpp_enum')
        ..members = [
          member('id')
          ..doc = 'Id for the enumeration'
          ..type = 'Id'..ctors = [''],
          member('brief')
          ..doc = 'Brief description for the enum',
          member('values')
          ..doc = 'Strings for the values of the enum'
          ..type = 'List<String>',
          member('value_map')
          ..doc = 'String value, numeric value pairs'
          ..type = 'Map<String, int>',
          member('is_class')
          ..doc = 'If true the enum is a class enum as opposed to "plain" enum'
          ..classInit = false,
          member('supports_picklist')
          ..doc = '''If true adds methods to go from string (i.e. picklist representation)
back to enum'''
          ..classInit = false,
          member('is_mask')
          ..doc = 'If true the values are powers of two for bit masking'
          ..classInit = false,
        ],
      ],
      library('cpp_member')
      ..classes = [
        class_('cpp_member')
        ..members = [
          member('id')
          ..doc = 'Id for the member'
          ..type = 'Id'..ctors = [''],
          member('brief')
          ..doc = 'Brief description for the member',
        ]
      ],
      library('cpp_class')
      ..imports = [
        'package:ebisu_cpp/cpp_member.dart',
        'package:id/id.dart',
        'package:ebisu/ebisu.dart',
      ]
      ..classes = [
        class_('cpp_class')
        ..members = [
          member('id')
          ..doc = 'Id for the class'
          ..type = 'Id'..ctors = [''],
          member('brief')
          ..doc = 'Brief description for the class',
        ]
      ]
    ];

  ebisu.generate();
}