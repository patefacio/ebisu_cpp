import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  final myLib = lib('my_awesome_lib')
    ..headers = [
      header('my_header')
      ..classes = [
        class_('my_class')
        ..members = [
          member('my_member')
        ]
      ]
    ];

  print(myLib);
}
