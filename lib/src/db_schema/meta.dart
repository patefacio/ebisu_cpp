part of ebisu_cpp.db_schema;

class Schema {

  Schema(this.tables);

  List<Table> tables = [];

  // custom <class Schema>

  Schema.fromDatabase(String server, {
    List<String> tables : const []
  }) {
    final ini = new OdbcIni();
  }


  // end <class Schema>
}

class Query {


  // custom <class Query>
  // end <class Query>
}

class Table {

  Column columns = [];
  Column pkey = [];

  // custom <class Table>
  // end <class Table>
}

class DbType {


  // custom <class DbType>
  // end <class DbType>
}

class Column {

  String name;
  DbType dbType;

  // custom <class Column>
  // end <class Column>
}
// custom <part meta>
// end <part meta>
