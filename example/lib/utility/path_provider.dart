import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PathProvider {
  static const String api = 'api';
  static const String images = 'images';

  static FutureOr<Directory> buildCacheDir({
    @required String type,
    String subtype,
  }) async {
    Directory temporaryDir = await getTemporaryDirectory();
    Directory destDir = Directory(path.join(temporaryDir.path, type, subtype));
    if (!destDir.existsSync()) {
      destDir.createSync(recursive: true);
    }
    return destDir;
  }
}
