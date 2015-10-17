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
        '"m_char".*H5T_NATIVE_CHAR',
        '"m_char".*H5T_NATIVE_CHAR',
        '"m_int8".*H5T_NATIVE_SCHAR',
        '"m_int16".*H5T_NATIVE_INT16',
        '"m_int32".*H5T_NATIVE_INT32',
        '"m_int64".*H5T_NATIVE_INT64',
        '"m_uint16".*H5T_NATIVE_UINT16',
        '"m_uint32".*H5T_NATIVE_UINT32',
        '"m_uint64".*H5T_NATIVE_UINT64',
        '"m_long_int".*H5T_NATIVE_LONG',
        '"m_long_double".*H5T_NATIVE_LDOUBLE',
        '"m_long_long".*H5T_NATIVE_LLONG',
        '"m_unsigned_int".*H5T_NATIVE_UINT32',
        '"m_unsigned_long".*H5T_NATIVE_ULONG',
        '"m_unsigned_long_long".*H5T_NATIVE_ULLONG',
        '"m_char".*H5T_NATIVE_CHAR',
        '"m_unsigned_char".*H5T_NATIVE_UCHAR',
        '"m_signed_char".*H5T_NATIVE_SCHAR',
      ].forEach((var t) {
        expect(contents.contains(new RegExp(t)), true);
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
      addH5DataSetSpecifier(c1);
      expect(c1.definition.contains('class H5_data_set_specifier'), true);
    });
  });

// end <main>
}
