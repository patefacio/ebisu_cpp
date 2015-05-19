import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:ebisu_cpp/cookbook.dart';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';

main() {

  var dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag');

  print(dispatch.dispatchBlock);

  dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag')
    ..enumeratorType = dctCptr;

  print(dispatch.dispatchBlock);

  dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag')
    ..discriminatorType = dctStdString
    ..enumeratorType = dctCptr;

  print('et ${dispatch.enumeratorType} dt ${dispatch.discriminatorType}');

  print(dispatch.dispatchBlock);

  dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag')
    ..discriminatorType = dctCptr
    ..enumeratorType = dctStdString;

  print(dispatch.dispatchBlock);

  dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag')
    ..discriminatorType = dctCptr
    ..enumeratorType = dctCptr;

  print(dispatch.dispatchBlock);

  dispatch = new IfElseIfEnumeratedDispatcher(
      [ 'type_declaration', 'structure', 'member', 'function' ],
      (dispatcher, enumerator) => 'handle_xml_${enumerator}(node);',
      enumerator : 'node.tag')
    ..discriminatorType = dctCptr
    ..enumeratorType = dctStringLiteral;

  print(dispatch.dispatchBlock);

}
