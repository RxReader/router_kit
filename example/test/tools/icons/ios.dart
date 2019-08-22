import 'dart:io';

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../tinify/tinify_manager.dart';

class IosAppIcon {
  const IosAppIcon({
    @required this.name,
    @required this.size,
  });

  final String name;
  final int size;
}

const List<IosAppIcon> appIcons = <IosAppIcon>[
  IosAppIcon(name: 'Icon-App-20x20@1x.png', size: 20),
  IosAppIcon(name: 'Icon-App-20x20@2x.png', size: 40),
  IosAppIcon(name: 'Icon-App-20x20@3x.png', size: 60),
  IosAppIcon(name: 'Icon-App-29x29@1x.png', size: 29),
  IosAppIcon(name: 'Icon-App-29x29@2x.png', size: 58),
  IosAppIcon(name: 'Icon-App-29x29@3x.png', size: 87),
  IosAppIcon(name: 'Icon-App-40x40@1x.png', size: 40),
  IosAppIcon(name: 'Icon-App-40x40@2x.png', size: 80),
  IosAppIcon(name: 'Icon-App-40x40@3x.png', size: 120),
  IosAppIcon(name: 'Icon-App-60x60@2x.png', size: 120),
  IosAppIcon(name: 'Icon-App-60x60@3x.png', size: 180),
  IosAppIcon(name: 'Icon-App-76x76@1x.png', size: 76),
  IosAppIcon(name: 'Icon-App-76x76@2x.png', size: 152),
  IosAppIcon(name: 'Icon-App-83.5x83.5@2x.png', size: 167),
  IosAppIcon(name: 'Icon-App-1024x1024@1x.png', size: 1024),
];

Future<void> createDefaultIcons(Directory outputDir, Image image, bool tinify) async {
  for (IosAppIcon appIcon in appIcons) {
    Image src = copyResize(
      image,
      width: appIcon.size,
      height: appIcon.size,
      interpolation: Interpolation.average,
    );
    File save = File(path.join(outputDir.path, appIcon.name));
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
