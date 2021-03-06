part of ebisu_cpp.ebisu_cpp;

/// Exposes common elements for named entities, including their [id] and
/// documentation. Additionally tracks parentage/ownership of entities.
///
/// This is abstract for purposes of ownership. Each [Entity] knows its
/// owning entity up until [Installation] which is the root entity. A call
/// to [generate] on [Installation] will [setOwnership] which subclasses
/// can trick down establishing ownership.
///
/// The purpose of linking all [Entity] instances in a virtual tree type
/// structure is so lookups can be done for entities.
///
/// [Entity] must be created with an argument representing an Id.  That
/// argument may be a string, in which case it is converted to an [Id].
/// That argument may be an [Id].
///
/// For many/most [Entity] subclasses there is often a corresponding
/// method that simply creates in instance of the subclass. For example,
///
///     class Lib extends Entity... {
///        Lib(Id id) : super(id);
///        ...
///     }
///
///     Lib lib(Object id) => new Lib(id is Id ? id : new Id(id));
///
/// This now allows this approach:
///
///       final myLib = lib('my_awesome_lib')
///         ..headers = [
///           header('my_header')
///           ..classes = [
///             class_('my_class')
///             ..members = [
///               member('my_member')
///             ]
///           ]
///         ];
///
///       print(myLib);
///
/// prints:
///
///     lib(myAwesomeLib)
///       headers:
///         header(myHeader)
///           classes:[My_class]
///
///       tests:
abstract class CppEntity extends Object with Entity {
  /// Id for the [CppEntity]
  Id id;

  /// List of includes required by this entity
  Includes get includes => _includes;

  // custom <class CppEntity>

  CppEntity(Object id)
      : this.id = id is String
            ? idFromString(id)
            : id is Id
                ? id
                : throw '''
CppEntities must be created with id of String or Id: ${id.runtimeType}=$id''';

  String get briefComment => brief != null ? '//! $brief' : null;

  String get detailedComment => descr != null ? blockComment(descr, ' ') : null;

  String get docComment => combine([briefComment, detailedComment]);

  get allIncludes => children.fold(new Includes()..mergeIncludes(includes),
      (prev, child) => prev.mergeIncludes((child as CppEntity).allIncludes));

  _typedOwningEntity(typePred) => typePred(this)
      ? this
      : owner == null
          ? owner
          : (owner as CppEntity)._typedOwningEntity(typePred);

  /// Walk up the entities to find owning [Lib]
  Lib get owningLib => _typedOwningEntity((t) => t is Lib);

  /// Walk up the entities to find owning [App]
  App get owningApp => _typedOwningEntity((t) => t is App);

  set namer(Namer namer) {
    if (owner != null) {
      throw new Exception('Namer should only be set on root entity');
    }
    _namer = namer;
  }

  /// Returns the [Namer] associated with the entity
  Namer get namer {
    if (_namer == null) {
      final myInstallation = installation;
      return myInstallation != null ? myInstallation.namer : defaultNamer;
    }
    return _namer;
  }

  /// Returns the installation, usually the root node, of this entity
  Installation get installation {
    if (owner == null) {
      if (this is! Installation) {
        _logger.info('${runtimeType}:$id has no associated installation');
        return null;
      }
      return this;
    } else {
      return (owner as CppEntity).installation;
    }
  }

  // end <class CppEntity>

  /// CppEntity specific [Namer].
  ///
  /// Prefer to use the [Installation] namer which is provided via [namer]
  /// getter. It assumes the [CppEntity] is progeny of an [Installation],
  /// which is not always the case. Use in cases where not - e.g. creating
  /// content without being tied to an installation - this can be used.
  Namer _namer;
  Includes _includes = new Includes();
}

// custom <part cpp_entity>
// end <part cpp_entity>
