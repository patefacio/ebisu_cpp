import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  var pd = new ParmDecl('matrix')..type = 'std::vector< std::vector < double > >';
  print('''
id    => ${pd.id} (${pd.id.runtimeType})
type  => ${pd.type}
''');
}