import 'package:easy_localization_sheet/sheet_parser.dart' as sheet_parser;
import 'package:easy_localization_sheet/utils.dart' as utils;

void main(List<String> arguments) async {
  final configs = utils.getConfig();
  try {
    final sheetFile = await utils.getCSVSheet(url: configs.csvUrl);
    await sheet_parser.parseSheet(
      sheetFile: sheetFile,
      outputRelatedPath: configs.outputDir,
    );
  } catch (e) {
    print(e.toString());
    rethrow;
  }
}
