part of ebisu_cpp.db_schema;

/// Given a schema generates code to support accessing tables and configured queries
class SchemaCodeGenerator extends Object with InstallationCodeGenerator {

  Schema schema;
  List<Query> queries = [];
  TableFilter tableFilter = (Table t) => true;

  // custom <class SchemaCodeGenerator>

  SchemaCodeGenerator(this.schema);

  get tables => schema.tables.where((t) => tableFilter(t));

  void generate() {
    tables.forEach((Table t) {
      final tgg = new TableGatewayGenerator(schema, t);
      print(tgg.header.contents);
    });
  }

  // end <class SchemaCodeGenerator>
}

class TableGatewayGenerator {

  TableGatewayGenerator(this.schema, this.table);

  Schema schema;
  Table table;

  // custom <class TableGatewayGenerator>

  _makeMember(c) =>
    member(c.name)
    ..cppAccess = public
    ..type = c.cppType
    ..noInit = true;

  _stringListSupport(Iterable<Member> members) => '''
static inline
void member_names_list(String_list_t &out) {
  ${members.map((m) => 'out.push_back("${m.vname}");').join('\n  ')}
}

inline
void to_string_list(String_list_t &out) const {
  ${members.map((m) => 'out.push_back(boost::lexical_cast< std::string >(${m.vname}));').join('\n  ')}
}''';

  _makeClass(String id, Iterable<Column> columns) {
    final result = class_(id)
      ..struct = true
      ..opEqual..opLess
      ..streamable = true
      ..members = columns.map((c) => _makeMember(c)).toList();
    return result
      ..getCodeBlock(clsPublic)
      .snippets
      .add(_stringListSupport(result.members));
  }

  Header get header {
    final tableId = idFromString(table.name);
    final tableName = tableId.snake;
    final pkeyColumns = table.pkeyColumns;
    final valueColumns = table.valueColumns;
    final ns = namespace(['fcs','orm', tableName, 'table']);
    print('Generating ${table.name} in schema ${schema.name}');
    final result = new Header(tableId)
    ..headers = [
      'cstdint',
      'sstream',
      'vector',
      'boost/any.hpp',
      'fcs/orm/otl_config.hpp',
      'fcs/orm/otl_utils.hpp',
      'fcs/orm/orm_to_string_table.hpp',
    ]
    ..namespace = ns
    ..classes = [
      _makeClass('${tableName}_pkey', pkeyColumns),
      _makeClass('${tableName}_value', valueColumns),
    ];
    return result;
  }

  // end <class TableGatewayGenerator>
}
// custom <part generator>

typedef bool TableFilter(Table);

TableFilter TableNameFilter(Iterable<String> tableNames) =>
  (Table t) => tableNames.contains(t.name);

// end <part generator>
