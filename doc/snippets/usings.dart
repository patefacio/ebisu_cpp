import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {
  print(using('vec', 'std::vector<T>')
      ..doc = 'it is a templatized using'
      ..template = 'typename T');
}