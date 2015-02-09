part of ebisu_cpp.db_schema;

/// Given a schema generates code to support accessing tables and configured
/// queries. Makes use of the poco c++ library.
///
class PocoSchemaCodeGenerator extends SchemaCodeGenerator {
  Id get sessionClassId => _sessionClassId;
  String get sessionClassName => _sessionClassName;
  // custom <class PocoSchemaCodeGenerator>

  PocoSchemaCodeGenerator(Schema schema) : super(schema) {
    _sessionClassId = new Id('connection_${id.snake}');
    _sessionClassName = _sessionClassId.capSnake;
  }

  get namespace => super.namespace;

  TableGatewayGenerator createTableGatewayGenerator(Table t) =>
      new PocoTableGatewayGenerator(installation, this, t);

  // end <class PocoSchemaCodeGenerator>
  Id _sessionClassId;
  String _sessionClassName;
}

class PocoTableGatewayGenerator extends TableGatewayGenerator {
  // custom <class PocoTableGatewayGenerator>

  PocoTableGatewayGenerator(Installation installation,
      SchemaCodeGenerator schemaCodeGenerator, Table table)
      : super(installation, schemaCodeGenerator, table);

  void finishClass(Class cls) {}

  void finishGatewayClass(Class gatewayClass) {}

  void addRequiredIncludes(Header hdr) => hdr.includes.addAll([]);

  // end <class PocoTableGatewayGenerator>
}
// custom <part poco_generator>
// end <part poco_generator>
