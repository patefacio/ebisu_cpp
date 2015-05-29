/// Support for generating emacs functions for accessing generated code
part of ebisu_cpp.ebisu_cpp;

/// Walks installation and creates single emacs file with utility functions
class InstallationWalker implements CodeGenerator {
  const InstallationWalker(this.installation);

  final Installation installation;

  // custom <class InstallationWalker>

  generate() {
    final outPath = path.join(installation.rootFilePath, 'doc',
        '${installation.id.emacs}.el');

    mergeWithFile(brCompact([
      installation.libs.map((l) => '''
(defun ${installation.id.emacs}:${l.id.emacs}() (interactive) )
'''),
    ]), outPath);
  }
  
  // end <class InstallationWalker>

}

// custom <part emacs_support>
// end <part emacs_support>
