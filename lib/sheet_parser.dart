import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

Future parseSheet({required File sheetFile, String? outputRelatedPath}) async {
  final input = sheetFile.openRead();
  final rows = await input
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();
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

  final languageColumnIndexes = <String, int>{};
  final supportedLanguages = header.toList()..removeAt(0);
  supportedLanguages.removeWhere((element) => element.startsWith('('));

  if (supportedLanguages.isEmpty) {
    throw Exception('Supported languages not found');
  }
  for (final language in supportedLanguages) {
    languageColumnIndexes[language] = header.indexOf(language);
  }

  final contents = {};
  for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex].map((e) => e.toString()).toList();
    for (var language in supportedLanguages) {
      final languageColumnIndex = languageColumnIndexes[language];
      if (languageColumnIndex == null) {
        continue;
      }
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
        columnIndex: languageColumnIndex,
        fullKey: row[0],
        row: row,
      );
    }
  }

  final outputDir = Directory(
    path.join(
      Directory.current.path,
      outputRelatedPath ?? 'assets',
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
    await file.writeAsString(encoder.convert(content));
  }
}

void appendContents({
  required Map contents,
  required String language,
  required int columnIndex,
  required String fullKey,
  required List<String> row,
}) {
  final languageValue = row[columnIndex];
  Map nestedContent = contents[language];
  final nestedKeys = fullKey.split('.');
  for (int nestedLevel = 0; nestedLevel < nestedKeys.length; nestedLevel++) {
    final key = nestedKeys[nestedLevel];

    if (nestedLevel == nestedKeys.length - 1) {
      nestedContent[key] = languageValue;
    } else {
      var content = nestedContent[key] as Map<dynamic, dynamic>?;
      if (content == null) {
        content = <String, dynamic>{};
        nestedContent[key] = content;
      }
      nestedContent = content;
    }
  }
}
