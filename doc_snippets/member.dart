import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {

  print(clangFormat(
          (member('message_length')
              ..type = 'int32_t'
              ..access = ro
              ..getterReturnModifier =
                ((member, oldValue) => 'endian_convert($oldValue)'))
          .getter));

}