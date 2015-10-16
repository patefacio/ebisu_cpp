part of ebisu_cpp.hdf5_support;

/// Indicates a class could not be found in the [Installation] for adding
/// hdf5 packet table support
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
          (CppEntity entity) => entity is Class && entity.id.snake == className,
          orElse: () =>
              throw new ClassNotFoundException(className, installation));
      assert(targetClass is Class);
      addH5DataSetSpecifier(targetClass);
    });
  }

  // end <class PacketTableDecorator>

}

/// Create a PacketTableDecorator sans new, for more declarative construction
PacketTableDecorator packetTableDecorator([List<LogGroup> logGroups]) =>
    new PacketTableDecorator(logGroups);

// custom <part packet_table>

addH5DataSetSpecifier(Class targetClass,
        [String typeMapper(String) = cppTypeToHdf5Type]) =>
    targetClass
      ..includes.add('hdf5.h')
      ..nestedClasses.add(class_('h5_data_set_specifier')
        ..withClass((Class dss) {
          final className = targetClass.className;
          dss
            ..isSingleton = true
            ..defaultCtor.customCodeBlock.snippets.add(brCompact([
              'compound_data_type_id_ = H5Tcreate(H5T_COMPOUND, sizeof($className));',
              targetClass.members.map((Member m) =>
                  'H5Tinsert(compound_data_type_id_, "${m.name}", '
                  'HOFFSET($className, ${m.vname}), '
                  '${typeMapper(m.type)});')
            ]))
            ..members = [
              member('data_set_name')
                ..init = '/${targetClass.id.snake}'
                ..type = 'char const*'
                ..cppAccess = public
                ..isStatic = true
                ..isConstExpr = true,
              member('compound_data_type_id')
                ..type = 'hid_t'
                ..access = ro,
            ];

          targetClass.friendClassDecls.add(friendClassDecl(dss.className));
        }))
      ..getCodeBlock(clsPublic).snippets.addAll([
        '''
static H5_data_set_specifier const& data_set_specifier() {
  return H5_data_set_specifier::instance();
}
'''
      ]);

final _intRe = new RegExp(r'(fast_|least_)?(u?)int(\d+)_t');

final _mappings = {
  'short': 'H5T_NATIVE_SHORT',
  'int': 'H5T_NATIVE_INT',
  'long': 'H5T_NATIVE_LONG',
  'long int': 'H5T_NATIVE_LONG',
  'long long': 'H5T_NATIVE_LLONG',
  'unsigned int': 'H5T_NATIVE_UINT32',
  'unsigned long': 'H5T_NATIVE_ULONG',
  'unsigned long long': 'H5T_NATIVE_ULLONG',
  'double': 'H5T_NATIVE_DOUBLE',
  'long double': 'H5T_NATIVE_LDOUBLE',
  'char': 'H5T_NATIVE_CHAR',
  'unsigned char': 'H5T_NATIVE_UCHAR',
  'signed char': 'H5T_NATIVE_SCHAR',
};

cppTypeToHdf5Type(String cppType) {
  var match = _intRe.firstMatch(cppType);
  if (match != null) {
    final bytes = match[3];
    final isSigned = match[2] == null || match[2] == '';
    final signChar = isSigned ? '' : 'U';
    if (bytes == '8') {
      return isSigned ? 'H5T_NATIVE_SCHAR' : 'H5T_NATIVE_UCHAR';
    } else {
      switch (bytes) {
        case '16':
          return 'H5T_NATIVE_${signChar}INT16';
        case '32':
          return 'H5T_NATIVE_${signChar}INT32';
        case '64':
          return 'H5T_NATIVE_${signChar}INT64';
      }
    }
  } else {
    final result = _mappings[cppType];
    if (result != null) return result;
    throw 'Could not map $cppType to suitable hdf5 type';
  }
}

// end <part packet_table>
