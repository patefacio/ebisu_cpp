library ebisu_cpp.test_hdf5_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/hdf5_support.dart';

// end <additional imports>

final _logger = new Logger('test_hdf5_support');

// custom <library test_hdf5_support>
// end <library test_hdf5_support>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  //Logger.root.level = Level.INFO;
  newInstallation() => installation('sample')
    ..libs = [
      lib('l')
        ..headers = [
          header('h')
            ..includes.add('foo.h')
            ..namespace = namespace([])
            ..classes = [
              class_('c')
                ..members = [
                  member('m_char')..type = 'char',
                  member('m_int8')..type = 'int8_t',
                  member('m_int16')..type = 'int16_t',
                  member('m_int32')..type = 'int32_t',
                  member('m_int64')..type = 'int64_t',
                  member('m_uint8')..type = 'uint8_t',
                  member('m_uint16')..type = 'uint16_t',
                  member('m_uint32')..type = 'uint32_t',
                  member('m_uint64')..type = 'uint64_t',
                  member('m_long_int')..type = 'long int',
                  member('m_long_double')..type = 'long double',
                  member('m_long_long')..type = 'long long',
                  member('m_unsigned_int')..type = 'unsigned int',
                  member('m_unsigned_long')..type = 'unsigned long',
                  member('m_unsigned_long_long')..type = 'unsigned long long',
                  member('m_char')..type = 'char',
                  member('m_unsigned_char')..type = 'unsigned char',
                  member('m_signed_char')..type = 'signed char',
                ]
            ]
        ]
    ];

  group('class augmentation', () {
    final installation = newInstallation();

    test('friends added', () {
      installation..decorateWith(packetTableDecorator([logGroup('c')]));
      _logger.info(installation.contents);
      final contents = installation.contents;
      [
        r'"m_char"(?:\n|.)*H5T_NATIVE_CHAR',
        r'"m_int8"(?:\n|.)*H5T_NATIVE_SCHAR',
        r'"m_int16"(?:\n|.)*H5T_NATIVE_INT16',
        r'"m_int32"(?:\n|.)*H5T_NATIVE_INT32',
        r'"m_int64"(?:\n|.)*H5T_NATIVE_INT64',
        r'"m_uint8"(?:\n|.)*H5T_NATIVE_UCHAR',
        r'"m_uint16"(?:\n|.)*H5T_NATIVE_UINT16',
        r'"m_uint32"(?:\n|.)*H5T_NATIVE_UINT32',
        r'"m_uint64"(?:\n|.)*H5T_NATIVE_UINT64',
        r'"m_long_int"(?:\n|.)*H5T_NATIVE_LONG',
        r'"m_long_double"(?:\n|.)*H5T_NATIVE_LDOUBLE',
        r'"m_long_long"(?:\n|.)*H5T_NATIVE_LLONG',
        r'"m_unsigned_int"(?:\n|.)*H5T_NATIVE_UINT',
        r'"m_unsigned_long"(?:\n|.)*H5T_NATIVE_ULONG',
        r'"m_unsigned_long_long"(?:\n|.)*H5T_NATIVE_ULLONG',
        r'"m_char"(?:\n|.)*H5T_NATIVE_CHAR',
        r'"m_unsigned_char"(?:\n|.)*H5T_NATIVE_UCHAR',
        r'"m_signed_char"(?:\n|.)*H5T_NATIVE_SCHAR',
      ].forEach((var t) {
        expect(contents.contains(new RegExp(t, multiLine: true)), true);
      });
    });

    test('createH5DataSetSpecifier', () {
      final c1 = class_('c_1')..members = [member('a')..type = 'int'];
      final dss = createH5DataSetSpecifier(c1);
      associateH5DataSetSpecifier(c1, dss);
      /*
      print(c1.definition);
      print('-------------');
      print(dss.definition);
      */
    });

    test('addH5DataSetSpecifier', () {
      final c1 = class_('c_1')..members = [member('a')..type = 'int'];
      final datasetSpecifier = createH5DataSetSpecifier(c1, cppTypeToHdf5Type);
      expect(datasetSpecifier.definition.contains('class C_1_h5_dss'), true);
      expect(datasetSpecifier.definition.contains('using Record_t = C_1'), true);
    });
  });

// end <main>
}
