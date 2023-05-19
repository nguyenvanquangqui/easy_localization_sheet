import 'dart:io';

import 'package:easy_localization_sheet/configs.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

Configs getConfig() {
  final currentPath = Directory.current.path;
  final pubspecYamlFile = File(path.join(currentPath, 'pubspec.yaml'));
  final pubspecYaml = loadYaml(pubspecYamlFile.readAsStringSync());
  final easyLocalizationSheetConfigs = pubspecYaml['easy_localization_sheet'];
  String? csvUrl;
  String? outputDir;
  if (easyLocalizationSheetConfigs != null) {
    csvUrl = easyLocalizationSheetConfigs['csv_url'];
    outputDir = easyLocalizationSheetConfigs['output_dir'];
  }

  if (csvUrl == null) {
    throw Exception('`csv_url` is required');
  }

  return Configs(
    csvUrl: csvUrl,
    outputDir: outputDir,
    packageName: pubspecYaml['name'],
  );
}

Future<File> getCSVSheet({
  required String url,
  File? destFile,
  String? forPackage,
}) async {
  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  final file = destFile ??
      File(
        path.join(
          getTempDir(forPackage: forPackage).path,
          'data.csv',
        ),
      );
  await response.pipe(file.openWrite());
  return file;
}

Directory getTempDir({String? forPackage}) {
  final tempDir = Directory(
    path.join(
      Directory.systemTemp.path,
      'easy_localization_sheet',
      forPackage ?? '',
    ),
  );
  if (!tempDir.existsSync()) {
    tempDir.createSync(recursive: true);
  }
  return tempDir;
}
