import 'dart:io';

import 'package:args/args.dart';
import 'package:image/image.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;
import 'android.dart' as android;
import 'ios.dart' as ios;

void main(List<String> args) {
//  print('args: $args');

  ArgParser parser = ArgParser();
  parser.addOption('platform');
  parser.addOption('icon');

  ArgResults results = parser.parse(args);
  String platform = results['platform'];
  String icon = results['icon'];

  String mimeType = mime.lookupMimeType(icon);
  if (mimeType != 'image/png') {
    throw UnsupportedError('Unsupported Icon: $icon');
  }
  File sourceFile = File(path.join(Directory.current.path, icon));
  Image image = decodeImage(sourceFile.readAsBytesSync());
  if (image.width != image.height) {
    throw UnsupportedError('Unsupported Icon: $icon(${image.width}x${image.height})');
  }
  if (image.width < 1024 || image.height < 1024) {
    throw UnsupportedError('Unsupported Icon: $icon(${image.width}x${image.height})');
  }
  Directory outputDir = Directory(path.join(sourceFile.parent.path, 'output'));
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  Directory platformOutputDir = Directory(path.join(outputDir.path, platform));
  if (platformOutputDir.existsSync()) {
    platformOutputDir.deleteSync(recursive: true);
  }
  platformOutputDir.createSync(recursive: true);
  switch (platform) {
    case 'android':
      android.createDefaultIcons(platformOutputDir, image);
      break;
    case 'ios':
      ios.createDefaultIcons(platformOutputDir, image);
      break;
    default:
      throw UnsupportedError('Unsupported Platform: $platform');
  }
}
