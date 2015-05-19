import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

main() {
  print(clangFormat((class_('x')).definition));
  print(clangFormat((class_('x')..copyCtor).definition));
  print(clangFormat((class_('x')..copyCtor.usesDefault = true).definition));

  print(clangFormat((
              class_('x')
              ..withCopyCtor((ctor) =>
                  ctor..cppAccess = protected
                  /// ...
                  ))
          .definition));
}