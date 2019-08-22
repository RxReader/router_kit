import 'dart:io';

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../tinify/tinify_manager.dart';

class AndroidAppIcon {
  const AndroidAppIcon({
    @required this.size,
    @required this.directoryName,
  });

  final String directoryName;
  final int size;
}

const List<AndroidAppIcon> appIcons = <AndroidAppIcon>[
  AndroidAppIcon(directoryName: 'mipmap-mdpi', size: 48),
  AndroidAppIcon(directoryName: 'mipmap-hdpi', size: 72),
  AndroidAppIcon(directoryName: 'mipmap-xhdpi', size: 96),
  AndroidAppIcon(directoryName: 'mipmap-xxhdpi', size: 144),
  AndroidAppIcon(directoryName: 'mipmap-xxxhdpi', size: 192),
];

Future<void> createDefaultIcons(Directory outputDir, Image image, bool tinify) async {
  for (AndroidAppIcon appIcon in appIcons) {
    Image src = copyResize(
      image,
      width: appIcon.size,
      height: appIcon.size,
      interpolation: Interpolation.average,
    );
    File save = File(
        path.join(outputDir.path, appIcon.directoryName, 'ic_launcher.png'));
    if (save.existsSync()) {
      save.deleteSync(recursive: true);
    }
    if (!save.parent.existsSync()) {
      save.parent.createSync(recursive: true);
    }
    save.writeAsBytesSync(
      tinify ? await TinifyManager.get().compress(encodePng(src)) : encodePng(src),
      mode: FileMode.writeOnly,
      flush: true,
    );
  }
}
