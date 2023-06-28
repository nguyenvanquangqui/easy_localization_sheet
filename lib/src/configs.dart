// Config for parser
class Configs {
  final String csvUrl;
  final String? outputDir;
  final String? packageName;
  final bool useEasyLocalizationGen;
  final String? easyLocalizationGenOutputDir;
  final String? easyLocalizationGenOutputFileName;

  Configs({
    required this.csvUrl,
    this.outputDir,
    this.packageName,
    required this.useEasyLocalizationGen,
    this.easyLocalizationGenOutputDir,
    this.easyLocalizationGenOutputFileName,
  });
}
