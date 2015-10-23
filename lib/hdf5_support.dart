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

// custom <library hdf5_support>
// end <library hdf5_support>
