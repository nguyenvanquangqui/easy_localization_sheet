import 'dart:io';

import 'package:easy_localization_sheet/src/sheet_parser.dart' as sheet_parser;
import 'package:easy_localization_sheet/src/utils.dart' as utils;

void main(List<String> arguments) async {
  final configs = utils.getConfig();
  try {
    final sheetFile = await utils.getCSVSheet(
      url: configs.csvUrl,
      forPackage: configs.packageName,
    );
    sheet_parser.parseSheet(
      sheetFile: sheetFile,
      outputRelatedPath: configs.outputDir,
    );
    print('Generate successful');
  } catch (e) {
    print(e.toString());
    rethrow;
  }
  exit(0);
}
