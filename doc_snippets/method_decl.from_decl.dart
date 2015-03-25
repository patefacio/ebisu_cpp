import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  var md = new MethodDecl.fromDecl('Row_list_t find_row(std::string s)');
  print(md);
}