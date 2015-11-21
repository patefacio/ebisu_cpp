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

  PacketMemberString(this.size) : super(H5tType.h5tNativeChar);

  get cppType => h5tToCppType[H5tType.h5tNativeChar];

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

_defineCompoundStringType(packetMemberType, member, className) => '''
auto ${member.name}_type = H5Tcopy(H5T_C_S1);
H5Tset_size(${member.name}_type, ${packetMemberType.size});
H5Tset_strpad(${member.name}_type, H5T_STR_NULLPAD);
H5Tinsert(compound_data_type_id_, "${member.name}", HOFFSET($className, ${member.vname}), ${member.name}_type);
''';

_defineCompoundPredefinedType(packetMemberType, member, className) => '''
H5Tinsert(compound_data_type_id_, "${member.name}",
HOFFSET($className, ${member.vname}),
${packetMemberType.cppType});
''';

String _memberCompoundTypeEntries(Class targetClass, TypeMapper typeMapper) {
  String className = targetClass.className;
  return brCompact(targetClass.members.map((Member member) {
    final packetMemberType = typeMapper(member.type);
    print('Looking for ${member.type} -> $packetMemberType');
    return (packetMemberType is PacketMemberString)
        ? _defineCompoundStringType(packetMemberType, member, className)
        : _defineCompoundPredefinedType(packetMemberType, member, className);
  }));
}

createH5DataSetSpecifier(Class targetClass,
        [TypeMapper typeMapper = cppTypeToHdf5Type,
          String className]) {
  if(className == null) {
    className = '${targetClass.className}_h5_dss';
  }
  return class_(className)
      ..withClass((Class dss) {
        dss
          ..isSingleton = true
          ..defaultCtor.customCodeBlock.snippets.add(brCompact([
            'compound_data_type_id_ = H5Tcreate(H5T_COMPOUND, '
            'sizeof(${targetClass.className}));',
            _memberCompoundTypeEntries(targetClass, typeMapper)
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
}

associateH5DataSetSpecifier(Class targetClass, Class dss) =>
    targetClass..usings.add(using('h5_data_set_specifier', dss.className));

addH5DataSetSpecifier(Class targetClass,
        [TypeMapper typeMapper = cppTypeToHdf5Type]) =>
    targetClass
      ..includes.add('hdf5.h')
      ..nestedClasses.add(createH5DataSetSpecifier(targetClass, typeMapper))
      ..getCodeBlock(clsPublic).snippets.addAll([
        '''
static H5_data_set_specifier const& data_set_specifier() {
  return H5_data_set_specifier::instance();
}
'''
      ]);

/// Given the type of a member returns the corresponding PacketMemberType
typedef PacketMemberType TypeMapper(String);

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
  'int8_t': H5tType.h5tNativeSchar,
  'int16_t': H5tType.h5tNativeInt16,
  'int32_t': H5tType.h5tNativeInt32,
  'int64_t': H5tType.h5tNativeInt64,
  'uint8_t': H5tType.h5tNativeUchar,
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
