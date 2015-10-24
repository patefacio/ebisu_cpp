/// Provide C++ classes support for reading/writing to hdf5 packet table
library ebisu_cpp.hdf5_support;

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';

// custom <additional imports>
// end <additional imports>

part 'src/hdf5_support/packet_table.dart';

/// Types defined in h5t api
enum H5tType {
  h5tNativeChar,
  h5tNativeSchar,
  h5tNativeUchar,
  h5tNativeShort,
  h5tNativeUshort,
  h5tNativeInt,
  h5tNativeUint,
  h5tNativeLong,
  h5tNativeUlong,
  h5tNativeLlong,
  h5tNativeUllong,
  h5tNativeFloat,
  h5tNativeDouble,
  h5tNativeInt16,
  h5tNativeInt32,
  h5tNativeInt64,
  h5tNativeUint16,
  h5tNativeUint32,
  h5tNativeUint64,
  h5tNativeLdouble,
  h5tNativeB8,
  h5tNativeB16,
  h5tNativeB32,
  h5tNativeB64,
  h5tNativeOpaque,
  h5tNativeHaddr,
  h5tNativeHsize,
  h5tNativeHssize,
  h5tNativeHerr,
  h5tNativeHbool
}

Map h5tToCppType = {
  H5tType.h5tNativeChar: "H5T_NATIVE_CHAR",
  H5tType.h5tNativeSchar: "H5T_NATIVE_SCHAR",
  H5tType.h5tNativeUchar: "H5T_NATIVE_UCHAR",
  H5tType.h5tNativeShort: "H5T_NATIVE_SHORT",
  H5tType.h5tNativeUshort: "H5T_NATIVE_USHORT",
  H5tType.h5tNativeInt: "H5T_NATIVE_INT",
  H5tType.h5tNativeUint: "H5T_NATIVE_UINT",
  H5tType.h5tNativeLong: "H5T_NATIVE_LONG",
  H5tType.h5tNativeUlong: "H5T_NATIVE_ULONG",
  H5tType.h5tNativeLlong: "H5T_NATIVE_LLONG",
  H5tType.h5tNativeUllong: "H5T_NATIVE_ULLONG",
  H5tType.h5tNativeFloat: "H5T_NATIVE_FLOAT",
  H5tType.h5tNativeDouble: "H5T_NATIVE_DOUBLE",
  H5tType.h5tNativeInt16: "H5T_NATIVE_INT16",
  H5tType.h5tNativeInt32: "H5T_NATIVE_INT32",
  H5tType.h5tNativeInt64: "H5T_NATIVE_INT64",
  H5tType.h5tNativeUint16: "H5T_NATIVE_UINT16",
  H5tType.h5tNativeUint32: "H5T_NATIVE_UINT32",
  H5tType.h5tNativeUint64: "H5T_NATIVE_UINT64",
  H5tType.h5tNativeLdouble: "H5T_NATIVE_LDOUBLE",
  H5tType.h5tNativeB8: "H5T_NATIVE_B8",
  H5tType.h5tNativeB16: "H5T_NATIVE_B16",
  H5tType.h5tNativeB32: "H5T_NATIVE_B32",
  H5tType.h5tNativeB64: "H5T_NATIVE_B64",
  H5tType.h5tNativeOpaque: "H5T_NATIVE_OPAQUE",
  H5tType.h5tNativeHaddr: "H5T_NATIVE_HADDR",
  H5tType.h5tNativeHsize: "H5T_NATIVE_HSIZE",
  H5tType.h5tNativeHssize: "H5T_NATIVE_HSSIZE",
  H5tType.h5tNativeHerr: "H5T_NATIVE_HERR",
  H5tType.h5tNativeHbool: "H5T_NATIVE_HBOOL"
};

// custom <library hdf5_support>
// end <library hdf5_support>
