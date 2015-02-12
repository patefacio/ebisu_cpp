/// Generates code to support **CRUD** operations on relational database tables.
///
library ebisu_cpp.db_schema;

import 'dart:async';
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/cpp.dart';
import 'package:id/id.dart';
import 'package:ini/ini.dart';
import 'package:magus/schema.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/core.dart';
import 'package:sqljocky/sqljocky.dart' hide Query;
// custom <additional imports>
// end <additional imports>

part 'src/db_schema/meta.dart';
part 'src/db_schema/test_support.dart';
part 'src/db_schema/generator.dart';
part 'src/db_schema/otl_generator.dart';
part 'src/db_schema/poco_generator.dart';

// custom <library db_schema>
// end <library db_schema>
