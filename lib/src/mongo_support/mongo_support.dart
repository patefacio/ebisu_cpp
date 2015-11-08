part of ebisu_cpp.mongo_support;

enum BsonType {
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
/// Convenient access to BsonType.bsonDouble with *bsonDouble* see [BsonType].
///
const BsonType bsonDouble = BsonType.bsonDouble;

/// Convenient access to BsonType.bsonString with *bsonString* see [BsonType].
///
const BsonType bsonString = BsonType.bsonString;

/// Convenient access to BsonType.bsonObject with *bsonObject* see [BsonType].
///
const BsonType bsonObject = BsonType.bsonObject;

/// Convenient access to BsonType.bsonArray with *bsonArray* see [BsonType].
///
const BsonType bsonArray = BsonType.bsonArray;

/// Convenient access to BsonType.bsonBinaryData with *bsonBinaryData* see [BsonType].
///
const BsonType bsonBinaryData = BsonType.bsonBinaryData;

/// Convenient access to BsonType.bsonObjectId with *bsonObjectId* see [BsonType].
///
const BsonType bsonObjectId = BsonType.bsonObjectId;

/// Convenient access to BsonType.bsonBoolean with *bsonBoolean* see [BsonType].
///
const BsonType bsonBoolean = BsonType.bsonBoolean;

/// Convenient access to BsonType.bsonDate with *bsonDate* see [BsonType].
///
const BsonType bsonDate = BsonType.bsonDate;

/// Convenient access to BsonType.bsonNull with *bsonNull* see [BsonType].
///
const BsonType bsonNull = BsonType.bsonNull;

/// Convenient access to BsonType.bsonRegex with *bsonRegex* see [BsonType].
///
const BsonType bsonRegex = BsonType.bsonRegex;

/// Convenient access to BsonType.bsonInt32 with *bsonInt32* see [BsonType].
///
const BsonType bsonInt32 = BsonType.bsonInt32;

/// Convenient access to BsonType.bsonInt64 with *bsonInt64* see [BsonType].
///
const BsonType bsonInt64 = BsonType.bsonInt64;

/// Convenient access to BsonType.bsonTimestamp with *bsonTimestamp* see [BsonType].
///
const BsonType bsonTimestamp = BsonType.bsonTimestamp;

abstract class PodField {

  Id get id => _id;
  /// If true the field is defined as index
  bool isIndex = false;

  // custom <class PodField>

  PodField(this._id);

  String toBson();
  String fromBson();

  toString() => 'PodField($id:$bsonType)';

  // end <class PodField>

  Id _id;

}


class PodScalar extends PodField {

  BsonType bsonType;

  // custom <class PodScalar>

  PodScalar(Id id, [BsonType this.bsonType]) : super(id);
  toString() => 'PodScalar($id:$bsonType)';

  // end <class PodScalar>

}


class PodArray extends PodField {

  PodField podField;

  // custom <class PodArray>

  PodArray(Id id, [PodField this.podField]) : super(id);
  toString() => 'PodArray($id:$podField)';

  // end <class PodArray>

}


class PodReference extends PodField {

  Pod pod;

  // custom <class PodReference>

  PodReference(Id id, [ Pod this.pod ]) : super(id);

  toString() => 'PodReference($id = ${pod.id.toString()})';

  // end <class PodReference>

}


class Pod {

  Id get id => _id;
  List<PodField> podFields = [];

  // custom <class Pod>

  Pod(this._id, [List<PodField> this.podFields]);

  toString() => '''
Pod($id)
${indentBlock(brCompact(podFields))}
''';

  // end <class Pod>

  Id _id;

}

// custom <part mongo_support>

PodField podScalar(id, [BsonType bsonType]) =>
    new PodScalar(makeId(id), bsonType);

Pod pod(id, [List<PodField> podFields]) =>
  new Pod(makeId(id), podFields);

PodReference podReference(id, [Pod pod]) =>
  new PodReference(makeId(id), pod);

PodArray podArray(id, [PodField podField]) =>
  new PodArray(makeId(id), podField);

// end <part mongo_support>
