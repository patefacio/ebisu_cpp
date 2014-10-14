part of ebisu_cpp.db_schema;

/// Given a schema generates code to support accessing tables and configured queries
class SchemaCodeGenerator extends Object with CodeGenerator {

  Schema schema;
  List<Query> queries = [];
  TableFilter tableFilter = (Table t) => true;

  // custom <class SchemaCodeGenerator>

  SchemaCodeGenerator(this.schema);

  get tables => schema.tables.where((t) => tableFilter(t));

  void generate() {
    print('Generating Schemas');
    tables.forEach((Table t) {
      final tgg = new TableGatewayGenerator(t);
      tgg.generate();
    });
  }

  // end <class SchemaCodeGenerator>
}

class TableGatewayGenerator {

  TableGatewayGenerator(this.table);

  Table table;

  // custom <class TableGatewayGenerator>

  void generate() {
    print('Generating ${table.name}');
  }

  // end <class TableGatewayGenerator>
}
// custom <part generator>

typedef bool TableFilter(Table);

TableFilter TableNameFilter(Iterable<String> tableNames) =>
  (Table t) => tableNames.contains(t.name);

// end <part generator>
