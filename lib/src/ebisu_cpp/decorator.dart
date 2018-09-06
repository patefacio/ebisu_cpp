/// Establishes capability for decorating an [Installation] prior to generation.
part of ebisu_cpp.ebisu_cpp;

/// Establishes an interface to allow decoration of classes and updates
/// (primarily additions) to an [Installation].
abstract class InstallationDecorator {
  // custom <class InstallationDecorator>

  void decorate(Installation installation);

  // end <class InstallationDecorator>

}

// custom <part decorator>
// end <part decorator>
