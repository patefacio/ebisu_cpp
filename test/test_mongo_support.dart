library ebisu_cpp.test_mongo_support;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

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
    final int32Field = podScalar('int32', bsonInt32);
    print(int32Field);
  });

  test('pod', () {
    final address = pod('address')
      ..podFields = [
        podScalar('street', bsonString),
        podScalar('zipcode', bsonString),
        podScalar('state', bsonString),
      ];

    final person = pod('person');

    person
      ..podFields = [
        podScalar('name', bsonString),
        podScalar('age', bsonInt32),
        podScalar('birth_date', bsonDate),
        podReference('address', address),
        podArray('children', podReference('person', person))
      ];


    print(person);
  });

// end <main>
}
