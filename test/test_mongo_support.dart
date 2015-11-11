library ebisu_cpp.test_mongo_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/mongo_support.dart';

// end <additional imports>

final _logger = new Logger('test_mongo_support');

// custom <library test_mongo_support>
// end <library test_mongo_support>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('pod field', () {
    final int32Field = podField('int32', bsonInt32);
    print(int32Field);
  });

  test('pod', () {
    final address = podObject('address')
      ..podFields = [
        podField('street', bsonString),
        podField('zipcode', bsonString),
        podField('state', bsonString),
      ];


    print(address);

    final person = podObject('person');

    person
      ..podFields = [
        podField('name', bsonString),
        podField('age', bsonInt32),
        podField('birth_date', bsonDate),
        podField('address', address),
        //podArray('children', podReference('person', person))
      ];

    print(person);

    final personHeader = podHeader('person')
      ..pods = [person]
      ..namespace = namespace(['config', 'users']);

    print(personHeader);
  });

// end <main>
}
