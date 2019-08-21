import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

class IosIconTemplate {
  IosIconTemplate({
    this.name,
    this.size,
  });

  final String name;
  final int size;
}

List<IosIconTemplate> iosIcons = <IosIconTemplate>[
  IosIconTemplate(name: 'Icon-App-20x20@1x.png', size: 20),
  IosIconTemplate(name: 'Icon-App-20x20@2x.png', size: 40),
  IosIconTemplate(name: 'Icon-App-20x20@3x.png', size: 60),
  IosIconTemplate(name: 'Icon-App-29x29@1x.png', size: 29),
  IosIconTemplate(name: 'Icon-App-29x29@2x.png', size: 58),
  IosIconTemplate(name: 'Icon-App-29x29@3x.png', size: 87),
  IosIconTemplate(name: 'Icon-App-40x40@1x.png', size: 40),
  IosIconTemplate(name: 'Icon-App-40x40@2x.png', size: 80),
  IosIconTemplate(name: 'Icon-App-40x40@3x.png', size: 120),
  IosIconTemplate(name: 'Icon-App-60x60@2x.png', size: 120),
  IosIconTemplate(name: 'Icon-App-60x60@3x.png', size: 180),
  IosIconTemplate(name: 'Icon-App-76x76@1x.png', size: 76),
  IosIconTemplate(name: 'Icon-App-76x76@2x.png', size: 152),
  IosIconTemplate(name: 'Icon-App-83.5x83.5@2x.png', size: 167),
  IosIconTemplate(name: 'Icon-App-1024x1024@1x.png', size: 1024),
];

void createDefaultIcons(Directory outputDir, Image image) {
  for (IosIconTemplate iosIcon in iosIcons) {
    Image src = copyResize(image, width: iosIcon.size, height: iosIcon.size, interpolation: Interpolation.average);
    File save = File(path.join(outputDir.path, iosIcon.name));
    if (save.existsSync()) {
      save.deleteSync(recursive: true);
    }
    save.createSync(recursive: true);
    save.writeAsBytesSync(encodePng(src));
  }
}
