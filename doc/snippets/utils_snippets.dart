import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {
  print(usingSptr('an_id', 'SomeType'));
  print(usingUptr('an_id', 'SomeType'));
  print(usingScptr('an_id', 'SomeType'));
  print(usingUcptr('an_id', 'SomeType'));
}