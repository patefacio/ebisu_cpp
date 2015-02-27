part of ebisu_cpp.hdf5_support;

/// Indicates a class could not be found in the [Installation] for adding
/// hdf5 packet table support
///
class ClassNotFoundException implements Exception {
  /// Exception details
  String get message => _message;
  // custom <class ClassNotFoundException>

  ClassNotFoundException(String className, Installation installation)
      : _message = '''
Class *$className* not found in installation *${installation.id}*''';

  String toString() => '''
ClassNotFoundException: $_message
''';

  // end <class ClassNotFoundException>
  final String _message;
}

class LogGroup {
  LogGroup(this.className, [this.memberNames = const []]);

  /// Name of class, *snake case*, to add a packet table log group
  final String className;
  /// Name of members of class, *snake case*, to include in the packet table
  /// log group. An empty list will include all members in the table.
  final List<String> memberNames;
  // custom <class LogGroup>
  // end <class LogGroup>
}

/// Create a LogGroup sans new, for more declarative construction
LogGroup logGroup(String className, [List<String> memberNames = const []]) =>
    new LogGroup(className, memberNames);

class PacketTableDecorator implements InstallationDecorator {
  const PacketTableDecorator(this.logGroups);

  final List<LogGroup> logGroups;
  // custom <class PacketTableDecorator>

  void decorate(Installation installation) {
    logGroups.forEach((LogGroup logGroup) {
      final className = logGroup.className;
      final targetClass = installation.progeny.firstWhere(
          (Entity entity) => entity is Class && entity.id.snake == className,
          orElse: () =>
              throw new ClassNotFoundException(className, installation));
      assert(targetClass is Class);

      targetClass
        .getCodeBlock(clsPublic)
        .snippets
        .addAll([ '/// hdf5 goodness added here' ]);
    });
  }

  // end <class PacketTableDecorator>
}

/// Create a PacketTableDecorator sans new, for more declarative construction
PacketTableDecorator packetTableDecorator([List<LogGroup> logGroups]) =>
    new PacketTableDecorator(logGroups);
// custom <part packet_table>
// end <part packet_table>
