import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

class E extends Entity {
  E(id) : super(id);
}
main() {
  var e = new E('foo_bar');
  print(e.id);
}