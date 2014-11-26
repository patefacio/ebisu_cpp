part of ebisu_cpp.db_schema;

class Gateway {
  const Gateway(this.tableDetails);

  final TableDetails tableDetails;
  // custom <class Gateway>

  get table => tableDetails.table;
  get foreignKeys => table.foreignKeys;
  get className => tableDetails.className;
  get rowType => '$className<>::Row_t';
  get rowListType => '$className<>::Row_list_t';
  get gw => '${tableDetails.tableId.snake}_gw';
  get row => '${tableDetails.tableId.snake}_row';
  get rowDecl => '$rowType $row;';
  get rowList => '${row}s';
  get postInsertRows => 'post_insert_${row}s';
  get updatedRows => 'updated_${row}s';
  get updatedRowsDecl => 'auto $updatedRows = $rowList;';
  get rowsListDecl => '$rowListType $rowList;';
  get declareAndCleanup => '''
auto $gw = $className<>::instance();
$rowsListDecl
{
  $gw.delete_all_rows();
  auto rows = $gw.select_all_rows();
  BOOST_REQUIRE(rows.empty());
}''';

  get randomize => '''
random_source >> $row;
''';

  get randomizeUpdated => '''
random_source >> $updatedRows[i].second;
BOOST_REQUIRE($updatedRows[i].second !=
              $rowList[i].second);
''';

  get pushRecord => '''
$rowList.push_back($row);
''';

  get insertRows => '''
$gw.insert($rowList);
auto $postInsertRows =
  $gw.select_all_rows();
BOOST_REQUIRE($postInsertRows.size() == num_rows);
''';

  get compareKeys => table.hasAutoIncrement? '' :
    'BOOST_REQUIRE($rowList[i].first == $postInsertRows[i].first)';
  get compareValues => '''
BOOST_REQUIRE($rowList[i].second ==
              $postInsertRows[i].second);''';

  get swap => table.hasAutoIncrement? 'std::swap($rowList, $postInsertRows);' : '';
  get compareRows => combine([ compareKeys, compareValues, swap ]);

  print(String vname) => '''
$className<>::print_recordset_as_table(
  $vname, std::cout);''';

  get updateRows => '$gw.update($updatedRows);';
  get checkUpdate => '''
{
  $className<>::Value_t value;
  bool found = $gw.find_row_by_key(
    $updatedRows[i].first, value);
  BOOST_REQUIRE(found);
  BOOST_REQUIRE(value == $updatedRows[i].second);
}''';

  // end <class Gateway>
}

/// Class to generate test code to exercise the table gateway
class GatewayTestGenerator {
  GatewayTestGenerator(this.test, this.tableDetails, this.namespace) {
    // custom <GatewayTestGenerator>

    final schema = tableDetails.schema;
    tableDetails.fkeyPath.forEach((FkeyPathEntry fpe) {
      gateways.add(
        new Gateway(
          new TableDetails.fromTable(schema, fpe.refTable)));
    });
    gateways.add(new Gateway(tableDetails));

    test
      ..includes.add('fcs/utils/streamers/random.hpp')
      ..addTestImplementations({
        'insert_update_delete_rows' : _testInsertUpdateDeleteRows,
      })
      ..getCodeBlock(fcbPreNamespace).snippets.add(_randomRow);

    // end <GatewayTestGenerator>
  }

  Test test;
  TableDetails tableDetails;
  Namespace namespace;
  /// Table details for transitive closure by foreign keys
  List<Gateway> gateways = [];
  // custom <class GatewayTestGenerator>

  get className => tableDetails.className;
  get table => tableDetails.table;
  get columnIds => tableDetails.columnIds;
  get keyClassName => tableDetails.keyClassName;
  get valueClassName => tableDetails.valueClassName;
  get keyColumns => tableDetails.keyColumns;
  get valueColumns => tableDetails.valueColumns;
  get fkeyPath => tableDetails.fkeyPath;


  _tableRandomSupport(TableDetails tableDetails) => '''
${_classRandomRow(tableDetails.keyClassName, tableDetails.keyColumns)}
${_classRandomRow(tableDetails.valueClassName, tableDetails.valueColumns)}

  template< >
  inline Random_source & operator>>
    (Random_source &source, ${tableDetails.className}<>::Row_t &row) {
    source >> row.first >> row.second;
    return source;
  }
''';

  get _randomRow => '''

using namespace $namespace;
using namespace fcs::utils::streamers;
using fcs::utils::streamers::operator<<;

namespace fcs {
namespace utils {
namespace streamers {
  // random row generation

${gateways.map((gw) => _tableRandomSupport(gw.tableDetails)).join('\n')}

}
}
}
''';

  _classRandomRow(String className, Iterable<Id> columnIds) => '''
  template< >
  inline Random_source & operator>>
    (Random_source &source, $className &obj) {
    source ${columnIds.map((col) => '>> obj.${idFromString(col.name).snake}').join('\n      ')};
    return source;
  }
''';

  get _linkUp {
    var parts = [];
    for(var gw in gateways) {
      final table = gw.table;
      for(var fk in gw.foreignKeys.values) {
        final refGw = gateways.firstWhere((gw) => gw.table == fk.refTable);
        parts.add('link_rows(${gw.row}, ${refGw.row});');
      }
    }
    return parts.join('\n');
  }

  get _testInsertUpdateDeleteRows => '''
// testing insertion and deletion
${gateways.map((gw) => gw.declareAndCleanup).join('\n')}

// create some records with random data
int const num_rows = 20;
Random_source random_source;

for(int i=0; i<num_rows; ++i) {

  // Declare all rows
  ${gateways.map((gw) => gw.rowDecl).join('\n  ')}

  // Generate random data for all rows
${gateways.map((gw) => indentBlock(gw.randomize)).join()}

  // Link up reference ids
${indentBlock(_linkUp)}

  // Push related records
${gateways.map((gw) => indentBlock(gw.pushRecord)).join()}
}

// insert those records, select back and validate
${gateways.map((gw) => gw.insertRows).join()}
for(size_t i=0; i<num_rows; i++) {
${indentBlock(combine(gateways.map((gw) => gw.compareRows)))}
}

// now update all values in memory with new random data
${combine(gateways.map((gw) => gw.updatedRowsDecl))}
for(size_t i=0; i<num_rows; i++) {
${indentBlock(gateways.map((gw) => gw.randomizeUpdated).join())}
}

if(false) {
${indentBlock(combine(gateways.map((gw) => gw.print(gw.updatedRows))))}
}

// push updates to database via update
${combine(gateways.map((gw) => gw.updateRows))}

// verify the updates
for(size_t i=0; i<num_rows; i++) {
${indentBlock(combine(gateways.map((gw) => gw.checkUpdate)))}
}

''';

  // end <class GatewayTestGenerator>
}
// custom <part test_support>
// end <part test_support>
