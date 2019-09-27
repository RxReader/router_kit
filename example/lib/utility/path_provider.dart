import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PathProvider {
  PathProvider._();

  // cache
  static const String api = 'api';
  static const String images = 'images';

  // file
  static const String nativeLibrary = 'nativeLibrary';

  static Future<Directory> buildCacheDir({
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

  static Future<Directory> buildFileDir({
    @required String type,
    String subtype,
  }) async {
    Directory fileDir = await getApplicationSupportDirectory();
    Directory destDir = Directory(path.join(fileDir.path, type, subtype));
    if (!destDir.existsSync()) {
      destDir.createSync(recursive: true);
    }
    return destDir;
  }
}
