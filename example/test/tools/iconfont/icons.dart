import 'dart:io';

import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;

class Resolution {
  const Resolution({
    @required this.nx,
    this.nxDir = '',
  });

  final double nx;
  final String nxDir;
}

const List<Resolution> resolutions = <Resolution>[
  Resolution(nx: 1.0),
  Resolution(nx: 2.0, nxDir: '2.0x'),
  Resolution(nx: 3.0, nxDir: '3.0x'),
];

void createIcons(Directory outputDir, Directory inputDir, int dpi) {
  List<FileSystemEntity> files = inputDir.listSync();
  for (FileSystemEntity file in files) {
    if (file is File) {
      String relativePath = file.path.replaceAll(inputDir.path, '');
      String mimeType = mime.lookupMimeType(file.path);
      if (mimeType != 'image/png' && mimeType != 'image/jpeg') {
        throw UnsupportedError('Unsupported Icon: $relativePath');
      }
      Image image = decodeImage(file.readAsBytesSync());
      if (image.width != image.height) {
        throw UnsupportedError(
            'Unsupported Icon: $relativePath(${image.width}x${image.height})');
      }
      if (image.width < dpi * 3 || image.height < dpi * 3) {
        throw UnsupportedError(
            'Unsupported Icon: $relativePath(${image.width}x${image.height})');
      }
      for (Resolution resolution in resolutions) {
        Image src = copyResize(
          image,
          width: (dpi * resolution.nx).ceil(),
          height: (dpi * resolution.nx).ceil(),
          interpolation: Interpolation.average,
        );
        File save = File(path.join(
            outputDir.path, resolution.nxDir, path.basename(file.path)));
        if (save.existsSync()) {
          save.deleteSync(recursive: true);
        }
        save.createSync(recursive: true);
        save.writeAsBytesSync(
          encodePng(src),
          mode: FileMode.writeOnly,
          flush: true,
        );
      }
    }
  }
}
