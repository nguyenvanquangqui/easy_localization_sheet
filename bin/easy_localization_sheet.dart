import 'dart:io';

import 'package:easy_localization_sheet/src/sheet_parser.dart' as sheet_parser;
import 'package:easy_localization_sheet/src/utils.dart' as utils;

void main(List<String> arguments) async {
  final configs = utils.getConfig();
  final outputDir = configs.outputDir ?? 'assets';
  try {
    final sheetFile = await utils.getCSVSheet(
      url: configs.csvUrl,
      forPackage: configs.packageName,
    );
    sheet_parser.parseSheet(
      sheetFile: sheetFile,
      outputRelatedPath: outputDir,
    );
    if (configs.useEasyLocalizationGen) {
      final generatedDir = configs.easyLocalizationGenOutputDir;
      final generatedFileName = configs.easyLocalizationGenOutputFileName;
      stdout.writeln('Run easy_localization:generate');
      await Process.run(
        'dart',
        [
          'run',
          'easy_localization:generate',
          '-S',
          outputDir,
          '-f',
          'keys',
          if (generatedDir != null) ...[
            '-O',
            generatedDir,
          ],
          if (generatedFileName != null) ...[
            '-o',
            generatedFileName,
          ],
        ],
      );
    }
    stdout.writeln('Generate successful');
  } catch (e) {
    print(e.toString());
    rethrow;
  }
  exit(0);
}
