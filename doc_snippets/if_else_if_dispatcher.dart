import 'package:id/id.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/cookbook.dart';

main() {

  final strings = [
    '125',
    '32',
    '1258',
  ];

  final tree = new CharNode.from(null, 'root', strings, false);
  print(tree);
  tree.flatten();
  print(tree);
}