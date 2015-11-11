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

class PodType {
  BsonType bsonType;

  // custom <class PodType>

  PodType(this.bsonType);

  // end <class PodType>

}

class PodScalar extends PodType {
  // custom <class PodScalar>

  PodScalar(BsonType bsonType) : super(bsonType);
  toString() => 'PodScalar($bsonType)';

  // end <class PodScalar>

}

class PodArray extends PodType {
  PodType referredType;

  // custom <class PodArray>

  PodArray(this.referredType) : super(BsonType.bsonArray);
  toString() => 'PodArray($bsonType<${referredType.id}>)';

  // end <class PodArray>

}

class PodField {
  Id get id => _id;

  /// If true the field is defined as index
  bool isIndex = false;
  PodType podType;
  dynamic defaultValue;

  // custom <class PodField>

  PodField(this._id, [this.podType]);

  String toBson();
  String fromBson();

  toString() => 'PodField($id:$podType)';

  // end <class PodField>

  Id _id;
}

class PodObject extends PodType {
  Id get id => _id;
  List<PodField> podFields = [];

  // custom <class PodObject>

  PodObject(this._id, [this.podFields]) : super(BsonType.bsonObject);

  toString() =>
      brCompact(['PodObject($id)', indentBlock(brCompact(podFields))]);

  // end <class PodObject>

  Id _id;
}

class PodHeader {
  Id get id => _id;
  List<Pod> pods = [];
  Namespace namespace;

  // custom <class PodHeader>

  PodHeader(this._id, [this.pods, this.namespace]);

  toString() => brCompact([
        'namespace $namespace {',
        indentBlock(
            brCompact(['PodHeader($id)', indentBlock(brCompact(pods))])),
        '}'
      ]);

  Header get header {
    if (_header == null) {
      final allPods = new Set<PodObject>();
      pods.forEach((pod) => _collectPods(pod, allPods));
      _header = new Header(id)
        ..namespace = namespace
        ..classes =
            allPods.toList().reversed.map((p) => _makeClass(p)).toList();
    }
    return _header;
  }

  Set _collectPods(PodObject podObject, Set<PodObject> uniquePods) {
    if (!uniquePods.contains(podObject)) {
      uniquePods.add(podObject);
      for (PodField podField in podObject.podFields) {
        final p = podField.podType;
        if (p is PodObject) {
          _collectPods(p, uniquePods);
        } else if (p is PodArray && p.referredType is PodObject) {
          _collectPods(p.referredType, uniquePods);
        }
      }
    }
  }

  Class _makeClass(PodObject pod) => class_(pod.id)
    ..isStruct = true
    ..members = pod.podFields.map((pf) => _makeMember(pf)).toList();

  Member _makeMember(PodField podField) => member(podField.id)
    ..type = getCppType(podField.podType)
    ..init = podField.defaultValue
    ..cppAccess = public;

  // end <class PodHeader>

  Id _id;
  Header _header;
}

// custom <part mongo_support>

PodField podField(id, [podType]) {
  id = makeId(id);
  if (podType == null) {
    return new PodField(id);
  } else if (podType is PodType) {
    return new PodField(id, podType);
  } else if (podType is BsonType) {
    return new PodField(id, new PodScalar(podType));
  }
}

PodObject podObject(id, [podFields]) => new PodObject(makeId(id), podFields);

PodHeader podHeader(id, [List<Pod> pods, Namespace namespace]) =>
    new PodHeader(makeId(id), pods, namespace);

PodArray podArray(PodType referredType) => new PodArray(referredType);

PodField podArrayField(id, PodType referredType) =>
    podField(id, podArray(referredType));

final _bsonToCpp = {
  bsonDouble: 'double',
  bsonString: 'std::string',
  bsonObject: null,
  bsonArray: null,
  bsonBinaryData: null,
  bsonObjectId: 'Object_id_t',
  bsonBoolean: 'bool',
  bsonDate: 'Date_t',
  bsonNull: null,
  bsonRegex: 'Regexp_t',
  bsonInt32: 'int32_t',
  bsonInt64: 'int64_t',
  bsonTimestamp: 'Timestamp_t',
};

String getCppType(PodType podType) {
  final bsonType = podType.bsonType;
  String result;
  if (bsonType == bsonObject) {
    result = podType.id.capCamel;
  } else if (bsonType == bsonArray) {
    result = 'std::vector<${getCppType(podType.referredType)}>';
  } else {
    result = _bsonToCpp[bsonType];
  }
  return result;
}

// end <part mongo_support>
