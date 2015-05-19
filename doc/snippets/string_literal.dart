import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {
  print("std::string x = ${cppStringLit('''
This is a test
Of the emergency
''')};");
}