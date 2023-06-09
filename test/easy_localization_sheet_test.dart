import 'dart:io';

import 'package:easy_localization_sheet/src/sheet_parser.dart' as parser;
import 'package:easy_localization_sheet/src/utils.dart' as utils;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test(
    'Load config',
    () {
      final configs = utils.getConfig();
      expect(
        configs.csvUrl,
        'https://docs.google.com/spreadsheets/d/1p6oQw6BKObb3RU_fIWskJjofRzEb01cfzfNE14Px4nw/export?format=csv',
      );
    },
  );

  test(
    'Download csv file',
    () async {
      final downloadDir = Directory(
        path.join(Directory.current.path, 'downloaded'),
      );
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }
      final destFile = File(path.join(downloadDir.path, 'downloaded.csv'));
      if (destFile.existsSync()) {
        destFile.deleteSync();
      }
      final file = await utils.getCSVSheet(
        url:
            'https://docs.google.com/spreadsheets/d/1p6oQw6BKObb3RU_fIWskJjofRzEb01cfzfNE14Px4nw/export?format=csv',
        destFile: destFile,
      );
      expect(file.existsSync(), true);
    },
  );

  test('Parse csv', () {
    final input = File(
      path.join(Directory.current.path, 'assets', 'input.csv'),
    );
    final outputDir = Directory(path.join(Directory.current.path, 'generated'));
    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
      outputDir.createSync(recursive: true);
    }
    parser.parseSheet(sheetFile: input, outputRelatedPath: 'generated');
    final languagesInSample = ['en', 'vi'];
    final outputLanguages = outputDir
        .listSync()
        .map((e) => path.basename(e.path).replaceAll('.json', ''))
        .toList()
      ..sort();

    expect(outputLanguages.length, languagesInSample.length);

    final enFile = File(path.join(outputDir.path, 'en.json'));
    expect(enFile.existsSync(), true);
    final expectedResultInEn = File(
      path.join(Directory.current.path, 'assets', 'validated_result.json'),
    ).readAsStringSync();
    expect(enFile.readAsStringSync(), expectedResultInEn);
  });
}
