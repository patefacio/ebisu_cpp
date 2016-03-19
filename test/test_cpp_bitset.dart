library ebisu_cpp.test_cpp_bitset;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu/ebisu.dart';

// end <additional imports>

final _logger = new Logger('test_cpp_bitset');

// custom <library test_cpp_bitset>
// end <library test_cpp_bitset>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('bitset', () {
    test('bitset basics', () {
      var cls = class_('s')
        ..isStruct = true
        ..defaultCppAccess = public
        ..members = [
          bitset('bs_3_u_int8', 3)
            ..doc =
                'This is a 3 bit unsigned char bitset where type is inferred as unsigned char',
          bitset('bs_31_u_int32', 31)
            ..doc =
                'This is a 32 bit unsigned char bitset where type is inferred as usigned int',
          bitset('bs_33_u_int64', 33)
            ..doc =
                'This is a 33 bit unsigned char bitset where type is inferred as usigned long long',
          bitset('bs_4_u_int8_specified', 4, bitsetType: bsUInt8),
          bitset('bs_4_u_int32_specified', 4, bitsetType: bsUInt32),
          bitset('bs_15_u_int64_specified', 15, bitsetType: bsUInt64),

          bitset('bs_30_int8_specified', 30, bitsetType: bsInt8),
          bitset('bs_30_int32_specified', 30, bitsetType: bsInt32),
          bitset('bs_30_int64_specified', 30, bitsetType: bsInt64),

          member('x')..init = 3
        ]
        ..setAsRoot();

      expect(cls.getMember('bs_3_u_int8').type, 'std::uint8_t');
      expect(cls.getMember('bs_31_u_int32').type, 'std::uint32_t');
      expect(cls.getMember('bs_33_u_int64').type, 'std::uint64_t');
      expect(cls.getMember('bs_4_u_int8_specified').type, 'std::uint8_t');
      expect(cls.getMember('bs_4_u_int32_specified').type, 'std::uint32_t');
      expect(cls.getMember('bs_15_u_int64_specified').type, 'std::uint64_t');

      expect(cls.getMember('bs_30_int8_specified').type, 'std::int8_t');
      expect(cls.getMember('bs_30_int32_specified').type, 'std::int32_t');
      expect(cls.getMember('bs_30_int64_specified').type, 'std::int64_t');

      expect(darkMatter(cls.definition), darkMatter('''
struct S
{
  /**
   This is a 3 bit unsigned char bitset where type is inferred as unsigned char
  */
  std::uint8_t bs_3_u_int8 : 3;

  /**
   This is a 32 bit unsigned char bitset where type is inferred as usigned int
  */
  std::uint32_t bs_31_u_int32 : 31;

  /**
   This is a 33 bit unsigned char bitset where type is inferred as usigned long long
  */
  std::uint64_t bs_33_u_int64 : 33;
  std::uint8_t bs_4_u_int8_specified : 4;
  std::uint32_t bs_4_u_int32_specified : 4;
  std::uint64_t bs_15_u_int64_specified : 15;
  std::int8_t bs_30_int8_specified : 30;
  std::int32_t bs_30_int32_specified : 30;
  std::int64_t bs_30_int64_specified : 30;
  int x { 3 };
};
'''));
    });
  });

// end <main>
}
