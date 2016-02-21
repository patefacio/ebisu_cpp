/// Library to facilate generation of c++ code.
///
/// The intent is to get as declarative as possible with the specification of C++
/// entities to make code generation as simple and fun as possible. The primary
/// focus of these utilities is in generating the *structure* of c++ code. This is
/// achieved by modeling the C++ language at a relatively high level and selectively
/// choosing what parts of the language lend themselves to the approach.
///
/// For sample code that uses this library to generate its structure see:
/// [fcs project](https://github.com/patefacio/fcs)
///
/// For a small taste, the following is the current description of a small C++
/// library called *raii* which provides a few utilities for handling the *resource
/// acquisition is initialization* idiom.
///
///     import 'package:ebisu_cpp/cpp.dart';
///     import '../../lib/installation.dart';
///
///     final raii = lib('raii')
///       ..namespace = namespace([ 'fcs', 'raii' ])
///       ..headers = [
///         header('change_tracker')
///         ..includes = [ 'boost/call_traits.hpp' ]
///         ..classes = [
///           class_('change_tracker')
///           ..descr = '''
///     Tracks current/previous values of the given type of data. For some
///     algorithms it is useful to be able to examine/perform logic on
///     current value and compare or evalutate how it has changed since
///     previous value.'''
///           ..template = [ 'typename T' ]
///           ..customBlocks = [clsPublic]
///           ..members = [
///             member('current')..type = 'T'..access = ro,
///             member('previous')..type = 'T'..access = ro,
///           ],
///           ...
///         ],
///         header('api_initializer')
///         ..test.customBlocks = [ fcbPreNamespace ]
///         ..test.includes.addAll(['vector', 'fcs/utils/streamers/containers.hpp', ])
///         ..includes = [ 'list', 'map', 'memory' ]
///         ..usings = [
///           'Void_func_t = void (*)(void)',
///         ]
///         ..classes = [
///           class_('functor_scope_exit')
///           ..template = [ 'typename FUNCTOR = Void_func_t' ]
///           ..usings = [ 'Functor_t = FUNCTOR' ]
///           ..customBlocks = [ clsPublic ]
///           ..memberCtors = [ memberCtor(['functor']) ]
///           ..members = [
///             member('functor')..type = 'Functor_t'..hasNoInit = true..access = ro,
///           ],
///           ...
///           class_('api_initializer')
///           ..usings = [
///             'Api_initializer_registry_t = Api_initializer_registry< INIT_FUNC, UNINIT_FUNC >'
///           ]
///           ..template = [
///             'typename INIT_FUNC = Void_func_t',
///             'typename UNINIT_FUNC = Void_func_t',
///           ]
///           ..customBlocks = [ clsPublic ]
///         ]
///       ];
///
///     addItems() => installation.addLib(raii);
///
///     main() {
///       addItems();
///       installation.generate();
///     }
///
/// When that script is run, the following is output:
///
///     No change: $TOP/fcs/cpp/fcs/raii/change_tracker.hpp
///     No change: $TOP/fcs/cpp/fcs/raii/api_initializer.hpp
///     No change: $TOP/fcs/cpp/tests/fcs/raii/test_change_tracker.cpp
///     No change: $TOP/fcs/cpp/tests/fcs/raii/test_api_initializer.cpp
///
/// So when the script is run the code is *regenerated* and any changed files will
/// be indicated as such. In this case, since the code was previously generated, it
/// indicates there were no updates.
library ebisu_cpp.ebisu_cpp;

import 'dart:collection';
import 'dart:io';
import 'dart:math' hide max;
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:petitparser/petitparser.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

part 'src/ebisu_cpp/access.dart';
part 'src/ebisu_cpp/app.dart';
part 'src/ebisu_cpp/benchmark.dart';
part 'src/ebisu_cpp/class.dart';
part 'src/ebisu_cpp/cmake_support.dart';
part 'src/ebisu_cpp/control_flow.dart';
part 'src/ebisu_cpp/cpp_entity.dart';
part 'src/ebisu_cpp/cpp_standard.dart';
part 'src/ebisu_cpp/decorator.dart';
part 'src/ebisu_cpp/doxy.dart';
part 'src/ebisu_cpp/emacs_support.dart';
part 'src/ebisu_cpp/enum.dart';
part 'src/ebisu_cpp/exception.dart';
part 'src/ebisu_cpp/file.dart';
part 'src/ebisu_cpp/generic.dart';
part 'src/ebisu_cpp/header.dart';
part 'src/ebisu_cpp/impl.dart';
part 'src/ebisu_cpp/installation.dart';
part 'src/ebisu_cpp/lib.dart';
part 'src/ebisu_cpp/log_provider.dart';
part 'src/ebisu_cpp/member.dart';
part 'src/ebisu_cpp/method.dart';
part 'src/ebisu_cpp/pointer.dart';
part 'src/ebisu_cpp/printer_support.dart';
part 'src/ebisu_cpp/serializer.dart';
part 'src/ebisu_cpp/template.dart';
part 'src/ebisu_cpp/test.dart';
part 'src/ebisu_cpp/test_provider.dart';
part 'src/ebisu_cpp/union.dart';
part 'src/ebisu_cpp/using.dart';
part 'src/ebisu_cpp/utils.dart';
part 'src/ebisu_cpp/versioning.dart';

final _logger = new Logger('ebisu_cpp');

// custom <library ebisu_cpp>
// end <library ebisu_cpp>
