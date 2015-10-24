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

class PacketMemberType {
  H5tType baseType;

  // custom <class PacketMemberType>

  PacketMemberType(this.baseType);

  get h5tType => baseType;
  get cppType => h5tToCppType[baseType];

  // end <class PacketMemberType>

}

class PacketMemberString extends PacketMemberType {
  int size;

  // custom <class PacketMemberString>
  // end <class PacketMemberString>

}

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

createH5DataSetSpecifier(Class targetClass,
        [PacketMemberType typeMapper(String) = cppTypeToHdf5Type,
        String className = 'h5_data_set_specifier']) =>
    class_(className)
      ..withClass((Class dss) {
        final className = targetClass.className;
        dss
          ..isSingleton = true
          ..defaultCtor.customCodeBlock.snippets.add(brCompact([
            'compound_data_type_id_ = H5Tcreate(H5T_COMPOUND, sizeof($className));',
            targetClass.members.map(
                (Member m) => 'H5Tinsert(compound_data_type_id_, "${m.name}", '
                    'HOFFSET($className, ${m.vname}), '
                    '${typeMapper(m.type).cppType});')
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
      });

associateH5DataSetSpecifier(Class targetClass, Class dss) =>
    targetClass..usings.add(using('h5_data_set_specifier', dss.className));

addH5DataSetSpecifier(Class targetClass,
        [PacketMemberType typeMapper(String) = cppTypeToHdf5Type]) =>
    targetClass
      ..includes.add('hdf5.h')
      ..nestedClasses
          .add(createH5DataSetSpecifier(targetClass, cppTypeToHdf5Type))
      ..getCodeBlock(clsPublic).snippets.addAll([
        '''
static H5_data_set_specifier const& data_set_specifier() {
  return H5_data_set_specifier::instance();
}
'''
      ]);

final _mappings = {
  'short': H5tType.h5tNativeShort,
  'int': H5tType.h5tNativeInt,
  'long': H5tType.h5tNativeLong,
  'long int': H5tType.h5tNativeLong,
  'long long': H5tType.h5tNativeLlong,
  'unsigned int': H5tType.h5tNativeUint,
  'unsigned long': H5tType.h5tNativeUlong,
  'unsigned long long': H5tType.h5tNativeUllong,
  'double': H5tType.h5tNativeDouble,
  'long double': H5tType.h5tNativeLdouble,
  'char': H5tType.h5tNativeChar,
  'signed char': H5tType.h5tNativeSchar,
  'unsigned char': H5tType.h5tNativeUchar,
  'std::int16_t': H5tType.h5tNativeInt16,
  'std::int32_t': H5tType.h5tNativeInt32,
  'std::int64_t': H5tType.h5tNativeInt64,
  'std::uint16_t': H5tType.h5tNativeUint16,
  'std::uint32_t': H5tType.h5tNativeUint32,
  'std::uint64_t': H5tType.h5tNativeUint64,
  'int16_t': H5tType.h5tNativeInt16,
  'int32_t': H5tType.h5tNativeInt32,
  'int64_t': H5tType.h5tNativeInt64,
  'uint16_t': H5tType.h5tNativeUint16,
  'uint32_t': H5tType.h5tNativeUint32,
  'uint64_t': H5tType.h5tNativeUint64,
};

PacketMemberType cppTypeToHdf5Type(String cppType) {
  H5tType baseType = _mappings[cppType];
  if (baseType == null) return null;
  return new PacketMemberType(baseType);
}

// end <part packet_table>
