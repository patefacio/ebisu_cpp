library ebisu_cpp.test_cpp_method;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';

// end <additional imports>

final Logger _logger = new Logger('test_cpp_method');

// custom <library test_cpp_method>
// end <library test_cpp_method>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  group('parm decl', () {
    {
      final decl = 'int x';
      test('"$decl" parsed', () {
        final parmDecl = new ParmDecl.fromDecl(decl);
        expect(parmDecl.id.snake, 'x');
        expect(parmDecl.type, 'int');
      });
    }

    {
      final decl = 'char const* name';
      test('"$decl" parsed', () {
        var parmDecl = new ParmDecl.fromDecl(decl);
        expect(parmDecl.id.snake, 'name');
        expect(parmDecl.type, 'char const*');
        parmDecl = new ParmDecl.fromDecl(
            'std::vector< std::vector < double > > matrix');
        expect(parmDecl.id.snake, 'matrix');
        expect(parmDecl.toString(),
            'std::vector< std::vector < double > > matrix');
      });
    }

    {
      final decl = 'Reduce_func_t reducerFunc';
      test('"$decl" parsed and func name normalized', () {
        final parmDecl = new ParmDecl.fromDecl(decl);
        expect(parmDecl.id.snake, 'reducer_func');
        expect(parmDecl.type, 'Reduce_func_t');
      });
    }
  });

  group('method decl', () {
    {
      final decl = 'void\n\tadd(int a, int b)';
      final tag = decl.replaceAll('\n', '');
      test('"$tag" parsed', () {
        final methodDecl = new MethodDecl.fromDecl(decl);
        expect(methodDecl.id.snake, 'add');
        expect(methodDecl.parmDecls.length, 2);
        expect(methodDecl.parmDecls.first.type, 'int');
        expect(methodDecl.parmDecls.first.id.snake, 'a');
        expect(methodDecl.parmDecls.last.type, 'int');
        expect(methodDecl.parmDecls.last.id.snake, 'b');
      });
    }

    {
      final decl = 'void\n\tempty_method()';
      final tag = decl.replaceAll('\n', '');
      test('"$tag" parsed', () {
        final methodDecl = new MethodDecl.fromDecl(decl);
        expect(methodDecl.id.snake, 'empty_method');
        expect(methodDecl.parmDecls.length, 0);
      });
    }

    {
      final decl =
          'EXCEPTION makeException(int lineNumber,\n\tchar const* file)';
      final tag = decl.replaceAll('\n', '');
      test('"$tag" parsed and name normalized', () {
        final methodDecl = new MethodDecl.fromDecl(decl);
        expect(methodDecl.id.snake, 'make_exception');
        expect(methodDecl.parmDecls.length, 2);
        expect(methodDecl.parmDecls.first.type, 'int');
        expect(methodDecl.parmDecls.first.id.snake, 'line_number');
        expect(methodDecl.parmDecls.last.type, 'char const*');
        expect(methodDecl.parmDecls.last.id.snake, 'file');
      });
    }
  });

  group('template method decl', () {
    {
      final decl = 'void\n\tadd(Foo a, int b)';
      final tag = decl.replaceAll('\n', '');
      test('"$tag" parsed', () {
        final methodDecl = new MethodDecl.fromDecl(decl);
        methodDecl.template = template(['typename Foo']);
        expect(methodDecl.id.snake, 'add');
        expect(methodDecl.parmDecls.length, 2);
        expect(methodDecl.parmDecls.first.type, 'Foo');
        expect(methodDecl.parmDecls.first.id.snake, 'a');
        expect(methodDecl.parmDecls.last.type, 'int');
        expect(methodDecl.parmDecls.last.id.snake, 'b');

        expect(
            darkMatter(methodDecl.asNonVirtual)
                .contains(darkMatter('template< typename FOO >')),
            true);
      });
    }
  });

  group('create method tests', () {
    test('no prefix, use method name', () {
      final i = interface('foo_bar')
        ..methodDecls = [
          methodDecl('void goo(int a, int b) const'),
          methodDecl('void foo(int c) const'),
        ];

      expect(
          darkMatter(
              brCompact(i.createMethodTests().map((t) => scenarioTestText(t)))),
          darkMatter('''
SCENARIO("goo") {
// custom <goo>
// end <goo>
}
SCENARIO("foo") {
// custom <foo>
// end <foo>
}
'''));
    });

    test('with prefix, use method name', () {
      final i = interface('foo_bar')
        ..methodDecls = [
          methodDecl('void goo(int a, int b) const'),
          methodDecl('void foo(int c) const'),
        ];

      expect(
          darkMatter(brCompact(i
              .createMethodTests(prefix: 'bam')
              .map((t) => scenarioTestText(t)))),
          darkMatter('''
SCENARIO("bam goo") {
// custom <bam goo>
// end <bam goo>
}
SCENARIO("bam foo") {
// custom <bam foo>
// end <bam foo>
}
'''));
    });

    test('with prefix, and hash', () {
      final i = interface('foo_bar')
        ..methodDecls = [
          methodDecl('void goo(int a, int b) const'),
          methodDecl('void foo(int c) const'),
        ];

      expect(
          darkMatter(brCompact(i
              .createMethodTests(prefix: 'bam', tagMethodName: false)
              .map((t) => scenarioTestText(t)))),
          darkMatter('''
SCENARIO("bam goo") {
// custom <(928956824)>
// end <(928956824)>
}
SCENARIO("bam foo") {
// custom <(928956824)>
// end <(928956824)>
}

'''));
    });
  });

  /*
  group('method decl with template args', () {
    final md = methodDecl(
        // This fails - due to , in <...>
        'template <typename T = int> void doit(Goo<F,X> const& a, int b)');
    //        'template <typename T = int> void doit(Goo<typename F,X> const& a, int b)');
    //    print(md.definition(true));
    //    print(md.parmDecls.map((pm) => pm.type));
  });
  */

// end <main>
}
