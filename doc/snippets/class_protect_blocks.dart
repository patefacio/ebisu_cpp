import 'package:ebisu_cpp/ebisu_cpp.dart';

main() {
  final sample = class_('c')
      ..customBlocks = [
        clsClose,
        clsOpen,
        clsPostDecl,
        clsPreDecl,
        clsPrivate,
        clsPrivateBegin,
        clsPrivateEnd,
        clsProtected,
        clsProtectedBegin,
        clsProtectedEnd,
        clsPublic,
        clsPublicBegin,
        clsPublicEnd,
      ];

  print(clangFormat(sample.definition));
}