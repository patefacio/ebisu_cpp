part of ebisu_cpp.hdf5_support;

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
  List<LogGroup> logGroups;
  // custom <class PacketTableDecorator>

  void decorate(Installation installation) {

    logGroups.forEach((LogGroup logGroup) {
      final targetClasses = intallation.entitiesWhere((Entity entity) =>
          entity is Class && entity.id.snake == logGroup.className);

    });

  }

  // end <class PacketTableDecorator>
}
// custom <part packet_table>
// end <part packet_table>
