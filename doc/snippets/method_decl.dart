import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  var md = new MethodDecl('find_row')
    ..parmDecls = [ new ParmDecl.fromDecl('std::string s') ]
    ..returnType = 'Row_list_t';
  print(md);
}