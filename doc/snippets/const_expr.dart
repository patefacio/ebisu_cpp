import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {
  print(new ConstExpr('secret', 42)..doc = 'its magic');
  print(new ConstExpr(new Id('voo_doo'), 'foo'));
  print(new ConstExpr('pi', 3.14));
}