import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'icons.dart' as icons;

void main(List<String> args) {
  ArgParser parser = ArgParser();
  parser.addOption('dpi');
  parser.addOption('srcDir');
  parser.addFlag('tinify', defaultsTo: false);

  ArgResults results = parser.parse(args);
  String dpi = results['dpi'];
  String srcDir = results['srcDir'];
  bool tinify = results['tinify'];

  Directory inputDir = Directory(path.join(Directory.current.path, srcDir));
  Directory outputDir = Directory(path.join(inputDir.path, 'output'));
  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);

  icons.createIcons(outputDir, inputDir, int.parse(dpi), tinify);
}
