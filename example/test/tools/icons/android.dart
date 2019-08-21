import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as path;

class AndroidAppIcon {
  AndroidAppIcon({
    this.size,
    this.directoryName,
  });

  final String directoryName;
  final int size;
}

List<AndroidAppIcon> appIcons = <AndroidAppIcon>[
  AndroidAppIcon(directoryName: 'mipmap-mdpi', size: 48),
  AndroidAppIcon(directoryName: 'mipmap-hdpi', size: 72),
  AndroidAppIcon(directoryName: 'mipmap-xhdpi', size: 96),
  AndroidAppIcon(directoryName: 'mipmap-xxhdpi', size: 144),
  AndroidAppIcon(directoryName: 'mipmap-xxxhdpi', size: 192),
];

void createDefaultIcons(Directory outputDir, Image image) {
  for (AndroidAppIcon appIcon in appIcons) {
    Image src = copyResize(image, width: appIcon.size, height: appIcon.size, interpolation: Interpolation.average);
    File save = File(path.join(outputDir.path, appIcon.directoryName, 'ic_launcher.png'));
    if (save.existsSync()) {
      save.deleteSync(recursive: true);
    }
    save.createSync(recursive: true);
    save.writeAsBytesSync(encodePng(src));
  }
}
