import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'zip_file.dart';

void main(List<String> args) {
  ArgParser parser = ArgParser();
  parser.addOption('file');

  ArgResults results = parser.parse(args);
  String file = results['file'];

  ZipFile.open(File(path.join(Directory.current.path, file)));
}
