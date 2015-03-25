import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  var pd = new ParmDecl.fromDecl('std::vector< std::vector < double > > matrix');
  print('''
id    => ${pd.id} (${pd.id.runtimeType})
type  => ${pd.type}
''');
}