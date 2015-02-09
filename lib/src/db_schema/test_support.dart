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
  get rowsListDecl => '$rowListType $rowList;';
  get finalCleanup => '''
delete_rows($gw);''';

  get declareAndCleanup => '''
auto $gw = $className<>::instance();
delete_rows($gw);
$rowsListDecl''';

  get randomizePatchAndInsert => foreignKeys.isEmpty
      ? '''
random_rows($rowList);
insert_rows($gw, $rowList);
'''
      : '''
random_rows($rowList);
patch_rows($rowList);
insert_rows($gw, $rowList);
''';

  get randomizePatchAndUpdate => foreignKeys.isEmpty
      ? '''
randomize_row_values($rowList);
update_rows($gw, $rowList);
'''
      : '''
randomize_row_values($rowList);
patch_rows($rowList);
update_rows($gw, $rowList);
''';

  print(String vname) => '''
$className<>::print_recordset_as_table(
  $vname, std::cout);''';

  // end <class Gateway>
}

/// Class to generate test code to exercise the table gateway
class GatewayTestGenerator {
  GatewayTestGenerator(this.test, this.tableDetails, this.namespace) {
    // custom <GatewayTestGenerator>

    final schema = tableDetails.schema;
    tableDetails.fkeyPath.forEach((FkeyPathEntry fpe) {
      gateways
          .add(new Gateway(new TableDetails.fromTable(schema, fpe.refTable)));
    });
    gateways.add(new Gateway(tableDetails));

    test
      ..includes.add('fcs/utils/streamers/random.hpp')
      ..addTestImplementations(
          {'insert_update_delete_rows': _testInsertUpdateDeleteRows,})
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

  get swapPostInsert => table.hasAutoIncrement
      ? 'std::swap(${gateways.last.rowList}, ${gateways.last.postInsertRows});'
      : '';

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

int const num_rows = 20;
Random_source random_source;

template< typename GW >
void delete_rows(GW &gw) {
  gw.delete_all_rows();
  auto rows = gw.select_all_rows();
  BOOST_REQUIRE(rows.empty());
}

template< typename Row_list_t >
void random_rows(Row_list_t &rows) {
  rows.reserve(num_rows);
  rows.clear();
  for(int i=0; i<num_rows; ++i) {
    typename Row_list_t::value_type row;
    random_source >> row;
    rows.push_back(row);
  }
}

template< typename Row_list_t >
void randomize_row_values(Row_list_t &rows) {
  for(int i=0; i<num_rows; ++i) {
    random_source >> rows[i].second;
  }
}

template< typename GW >
void insert_rows(GW &gw, typename GW::Row_list_t & rows) {
  gw.insert(rows);
  auto again = gw.select_all_rows();
  BOOST_REQUIRE(again.size() == rows.size());
  for(int i=0; i<rows.size(); ++i) {
    BOOST_REQUIRE(again[i].second == rows[i].second);
  }
  std::swap(again, rows);
}

template< typename GW >
void update_rows(GW &gw, typename GW::Row_list_t const& rows) {
  gw.update(rows);
  auto again = gw.select_all_rows();
  BOOST_REQUIRE(again.size() == rows.size());
  for(int i=0; i<rows.size(); ++i) {
    BOOST_REQUIRE(again[i].second == rows[i].second);
  }
}

template< typename GW >
void find_by_key_check(GW &gw, typename GW::Row_list_t const& rows) {
  typename GW::Value_t value;
  for(int i=0; i<rows.size(); ++i) {
    gw.find_row_by_key(rows[i].first, value);
    BOOST_REQUIRE(rows[i].second == value);
  }
}

${_linkUp}

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
    for (var gw in gateways) {
      final table = gw.table;
      for (var fk in gw.foreignKeys.values) {
        final refGw = gateways.firstWhere((gw) => gw.table == fk.refTable);
        parts.add('''
void patch_rows(${gw.rowListType} & rows) {
  auto ${refGw.rowList} = ${refGw.className}<>::instance().select_all_rows();
  BOOST_ASSERT(${refGw.rowList}.size() == num_rows);
  for(int i=0; i<num_rows; ++i) {
    link_rows(rows[i], ${refGw.rowList}[i]);
  }
}
''');
      }
    }
    return parts.join('\n');
  }

  get _testInsertUpdateDeleteRows => '''
// testing insertion and deletion
${gateways.reversed.map((gw) => gw.declareAndCleanup).join('\n')}

${gateways.map((gw) => gw.randomizePatchAndInsert).join()}

${gateways.map((gw) => gw.randomizePatchAndUpdate).join()}

${gateways.map((gw) => 'find_by_key_check(${gw.gw}, ${gw.rowList});').join('\n')}

if(false) {
${indentBlock(combine(gateways.map((gw) => gw.print(gw.rowList))))}
}

${gateways.reversed.map((gw) => gw.finalCleanup).join('\n')}

''';

  // end <class GatewayTestGenerator>
}
// custom <part test_support>
// end <part test_support>
