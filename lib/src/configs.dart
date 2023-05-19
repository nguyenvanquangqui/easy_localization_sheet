// Config for parser
class Configs {
  final String csvUrl;
  final String? outputDir;
  final String? packageName;

  Configs({
    required this.csvUrl,
    this.outputDir,
    this.packageName,
  });
}
