import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

main() {

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
}