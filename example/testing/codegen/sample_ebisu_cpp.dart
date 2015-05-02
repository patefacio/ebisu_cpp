#!/usr/bin/env dart
/// Creates an ebisu setup
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu_cpp/ebisu_cpp.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

main() {

  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  String here = absolute(Platform.script.toFilePath());
  final dir = dirname(dirname(here));
  final sample = installation('sample')
    ..root = dir
    ..libs = [
      lib('sample')
      ..headers = [
        header('foo')
        ..testScenarios = [

          testScenario('basics',
              given('a vector with some items', [
                when('the size is increased',
                    then('the size and capacity change')),
                when('the size is reduced',
                    then('the size channges but not capacity')),
                when('more capacity is reserved',
                    then('the capacity changes but not the size')),
                when('less capacity is reserved',
                    then('neither size nore capacity is changed')),
              ])),

          testScenario('basics')
          ..withGiven('a vector with some items', (Given given) {
            given
              ..addWhen('the size is increased')
              .addThen('the size and capacity change')
              ..addWhen('the size is reduced')
              .addThen('the size channges but not capacity')
              ..addWhen('more capacity is reserved')
              .addThen('the capacity changes but not the size')
              ..addWhen('less capacity is reserved')
              .addThen('neither size nore capacity is changed');
          }),

          testScenario('basics')
          .addGiven('a vector with some items')
          ..addWhen('the size is increased')
          .addThen('the size and capacity change')
          ..addWhen('the size is reduced')
          .addThen('the size channges but not capacity')
          ..addWhen('more capacity is reserved')
          .addThen('the capacity changes but not the size')
          ..addWhen('less capacity is reserved')
          .addThen('neither size nore capacity is changed')
        ]
      ]
    ];

  sample.generate();

  print(sample.progeny.map((c) => '  ${c.runtimeType}:${c.id}\n').toList());

  print(sample.libs.first.headers.first.testScenarios.first);
  print(sample.libs.first.headers.first.testScenarios.last);


}
