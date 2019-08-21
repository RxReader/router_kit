import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

class AndroidIconTemplate {
  AndroidIconTemplate({
    this.size,
    this.directoryName,
  });

  final String directoryName;
  final int size;
}

List<AndroidIconTemplate> androidIcons = <AndroidIconTemplate>[
  AndroidIconTemplate(directoryName: 'mipmap-mdpi', size: 48),
  AndroidIconTemplate(directoryName: 'mipmap-hdpi', size: 72),
  AndroidIconTemplate(directoryName: 'mipmap-xhdpi', size: 96),
  AndroidIconTemplate(directoryName: 'mipmap-xxhdpi', size: 144),
  AndroidIconTemplate(directoryName: 'mipmap-xxxhdpi', size: 192),
];

void createDefaultIcons(Directory outputDir, Image image) {
  for (AndroidIconTemplate androidIcon in androidIcons) {
    Image src = copyResize(image, width: androidIcon.size, height: androidIcon.size, interpolation: Interpolation.average);
    File save = File(path.join(outputDir.path, androidIcon.directoryName, 'ic_launcher.png'));
    if (save.existsSync()) {
      save.deleteSync(recursive: true);
    }
    save.createSync(recursive: true);
    save.writeAsBytesSync(encodePng(src));
  }
}
