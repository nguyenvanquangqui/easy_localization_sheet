import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

/// Parse content of csv file and write to destination file
/// [sheetFile] csv source file
/// [outputRelatedPath] output path
void parseSheet({required File sheetFile, required String outputRelatedPath}) {
  final input = sheetFile.readAsStringSync();
  final rows = CsvToListConverter().convert(input);
  if (rows.length < 2) {
    throw Exception('Invalid csv');
  }
  while (rows[0].first.toString().toLowerCase() != 'key') {
    rows.removeAt(0);
  }
  final header = rows[0].map((e) => e.toString().trim()).toList();
  if (header.length < 2) {
    throw Exception('Invalid csv');
  }

  final supportedLanguages = header.toList()..removeAt(0);
  supportedLanguages.removeWhere((element) => element.startsWith('('));

  if (supportedLanguages.isEmpty) {
    throw Exception('Supported languages not found');
  }

  final contents = {};
  for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex].map((e) => e.toString()).toList();
    for (var language in supportedLanguages) {
      final languageColumnIndex = header.indexOf(language);
      if (contents[language] == null) {
        contents[language] = <String, dynamic>{};
      }
      final fullKey = row[0];
      if (fullKey.isEmpty) {
        continue;
      }
      appendContents(
        contents: contents,
        language: language,
        fullKey: row[0],
        languageValue: row[languageColumnIndex],
      );
    }
  }

  final outputDir = Directory(
    path.join(
      Directory.current.path,
      outputRelatedPath,
    ),
  );
  final encoder = JsonEncoder.withIndent('  ');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  for (var language in supportedLanguages) {
    final content = contents[language];
    if (content == null) {
      continue;
    }
    final file = File(path.join(outputDir.path, '$language.json'));
    file.writeAsStringSync(encoder.convert(content), flush: true);
  }
}

/// Append value for specific [language] to original [contents]
void appendContents({
  required Map contents,
  required String language,
  required String fullKey,
  required String languageValue,
}) {
  Map nestedContent = contents[language];
  final nestedKeys = fullKey.split('.');
  for (int nestedLevel = 0; nestedLevel < nestedKeys.length; nestedLevel++) {
    final key = nestedKeys[nestedLevel];

    if (nestedLevel == nestedKeys.length - 1) {
      if (nestedContent[key] != null) {
        stdout.writeln('WARNING: Duplicate key [$language]-[$fullKey]');
      }
      nestedContent[key] = languageValue;
    } else {
      var content = nestedContent[key] as Map<String, dynamic>?;
      if (content == null) {
        content = <String, dynamic>{};
        nestedContent[key] = content;
      }
      nestedContent = content;
    }
  }
}
