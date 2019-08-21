import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;

void main(List<String> args) {
//  print('args: $args');

  ArgParser parser = ArgParser();
  parser.addOption('platform');
  parser.addOption('assets');

  ArgResults results = parser.parse(args);
  String platform = results['platform'];
  String assets = results['assets'];

//  platform = 'android';
//  assets = '/Users/v7lin/full-stack-developer/zhangzhongyun/flutter_router/example/build/app/intermediates/merged_assets/debug/mergeDebugAssets/out/flutter_assets';

  optimizeAssets(platform, assets);
}

void optimizeAssets(String platform, String assets) {
  File manifest = File(path.join(assets, 'AssetManifest.json'));
  String manifestContent = manifest.readAsStringSync();
  Map<dynamic, dynamic> result = <dynamic, dynamic>{};
  Map<dynamic, dynamic> map = json.decode(manifestContent);
  for (dynamic key in map.keys) {
    List<dynamic> value = map[key] as List<dynamic>;
    if (key is String) {
      String mimeType = mime.lookupMimeType(key);
      if (mimeType != null && mimeType.isNotEmpty && mimeType.startsWith('image/')) {
        if (value != null && value.isNotEmpty && value.length > 1) {
          value = <dynamic>[...value];
          List<dynamic> remove = <dynamic>[];
          for (int i = platform == 'ios' ? value.length - 3 : value.length - 2; i >= 0; i --) {
            remove.add(value[i]);
            File(path.join(assets, value[i])).deleteSync();
          }
          value.removeWhere((dynamic e) {
            return remove.contains(e);
          });
        }
      }
    }
    result[key] = value;
  }
  manifest.writeAsStringSync(json.encode(result), mode: FileMode.write, flush: true);
}
