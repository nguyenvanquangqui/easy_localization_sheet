import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

/// Parse content of csv file and write to destination file
/// [sheetFile] csv source file
/// [outputRelatedPath] output path
void parseSheet({required File sheetFile, required String outputRelatedPath}) {
  final data = _getValidatedInput(sheetFile);
  final supportedLanguages = data.supportedLanguages;
  final keyColumnCount = data.keyColumnCount;
  final header = data.header;
  final rows = data.rows;
  final contents = <String, dynamic>{};
  for (final language in supportedLanguages) {
    contents[language] = <String, dynamic>{};
  }

  List<List<String>> keyColumnsHistory = [];
  for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    final keyColumns = row
        .sublist(0, keyColumnCount)
        .map(
          (e) => e.trim(),
        )
        .toList();
    if (keyColumns.isEmpty) {
      continue;
    }
    if (keyColumns.first.isNotEmpty) {
      keyColumnsHistory.clear();
    }
    for (final language in supportedLanguages) {
      _appendContents(
        contents: contents[language],
        language: language,
        languageValue: row[header.indexOf(language)],
        keyColumns: keyColumns,
        keyColumnsHistory: keyColumnsHistory,
      );
    }
    keyColumnsHistory.add(keyColumns);
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
void _appendContents({
  required Map<String, dynamic> contents,
  required String language,
  required String languageValue,
  required List<String> keyColumns,
  required List<List<String>> keyColumnsHistory,
}) {
  Map<String, dynamic> object = contents;
  for (var keyIndex = 0; keyIndex < keyColumns.length; keyIndex++) {
    var key = keyColumns[keyIndex];
    final hasChildren = _hasChildren(
      keyColumns: keyColumns,
      keyIndex: keyIndex,
    );
    if (!hasChildren) {
      if (object[key] != null) {
        stdout.writeln('WARNING: Duplicate key [$language]-[$keyColumns]');
      }
      object[key] = languageValue;
      break;
    }
    if (key.isEmpty) {
      key = _findKeyFromHistory(history: keyColumnsHistory, index: keyIndex);
    }
    if (object[key] == null) {
      final nestedObject = <String, dynamic>{};
      object[key] = nestedObject;
    }
    object = object[key];
  }
}

/// Validate input then return the validated data
CsvSheetData _getValidatedInput(File file) {
  final rows = CsvToListConverter().convert<String>(
    file.readAsStringSync(),
    shouldParseNumbers: false,
  );
  while (rows.isNotEmpty && rows[0].first.toString().toLowerCase() != 'key') {
    rows.removeAt(0);
  }
  if (rows.isEmpty) {
    throw Exception('[key] must exists in the first column');
  }
  final header = rows.removeAt(0);
  int keyColumnCount = 1;
  for (var i = 1; i < header.length; i++) {
    final key = header[i];
    if (key.isNotEmpty) break;
    keyColumnCount++;
  }
  final supportedLanguages =
      header.sublist(keyColumnCount).map((e) => e.trim()).toList()
        ..removeWhere(
          (e) => e.startsWith('('),
        );

  if (supportedLanguages.isEmpty) {
    throw Exception('Supported languages not found');
  }
  return CsvSheetData(
    supportedLanguages: supportedLanguages.toSet(),
    keyColumnCount: keyColumnCount,
    header: header,
    rows: rows,
  );
}

String _findKeyFromHistory({
  required List<List<String>> history,
  required int index,
}) {
  for (int i = history.length - 1; i >= 0; i--) {
    final keyColumns = history[i];
    final key = keyColumns[index];
    if (key.isNotEmpty) {
      return key;
    }
  }
  return '';
}

bool _hasChildren({required List<String> keyColumns, required int keyIndex}) {
  if (keyIndex >= keyColumns.length - 1) return false;
  final childrenStartIndex = keyIndex + 1;
  return keyColumns.sublist(childrenStartIndex).any((e) => e.isNotEmpty);
}

/// An validated data of sheet
class CsvSheetData {
  CsvSheetData({
    required this.supportedLanguages,
    required this.keyColumnCount,
    required this.header,
    required this.rows,
  });

  final Set<String> supportedLanguages;
  final int keyColumnCount;
  final List<String> header;
  final List<List<String>> rows;
}
