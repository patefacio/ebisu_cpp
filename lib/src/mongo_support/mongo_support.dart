part of ebisu_cpp.mongo_support;

enum BsonTypes {
  bsonDouble,
  bsonString,
  bsonObject,
  bsonArray,
  bsonBinaryData,
  bsonObjectId,
  bsonBoolean,
  bsonDate,
  bsonNull,
  bsonRegex,
  bsonInt32,
  bsonInt64,
  bsonTimestamp
}

class PodField {
  Id id;
  BsonType bsonType;

  // custom <class PodField>
  // end <class PodField>

}

class Pod {
  Id id;
  List<PodField> podFields = [];

  // custom <class Pod>
  // end <class Pod>

}

// custom <part mongo_support>
// end <part mongo_support>
