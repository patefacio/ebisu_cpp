library ebisu_cpp.test_cpp_forward_decl;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_forward_decl');

// custom <library test_cpp_forward_decl>
// end <library test_cpp_forward_decl>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('forward decl basics', () {
    expect(
        darkMatter(
            forwardDecl('text_stream', namespace(['decode', 'streamers']))),
        darkMatter(
            'namespace decode { namespace streamers { class text_stream; } }'));
  });

  test('template forward decl basics', () {
    expect(
        darkMatter(
            forwardDecl('text_stream', namespace(['decode', 'streamers']))
              ..template = template(['typename T'])),
        darkMatter('''
namespace decode {
namespace streamers {
  template< typename T >class text_stream;
}
}
'''));

    final fd = forwardDecl('text_stream', namespace(['decode', 'streamers']))
      ..template = template(['typename T'])
      ..doc = 'Here is a comment for this hairy forward decl';

    expect(darkMatter(fd), darkMatter('''
/**
   Here is a comment for this hairy forward decl
*/
namespace decode {
namespace streamers {
  template< typename T >class text_stream;
}
}
'''));
  });

// end <main>
}
