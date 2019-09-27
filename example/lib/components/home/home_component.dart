import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:device_info/device_info.dart';
import 'package:example/components/banner/banner_component.dart';
import 'package:example/components/nested_scroll/nested_scroll_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';
import 'package:example/logs/collect-console-logs.dart';
import 'package:example/router/app_router.dart';
import 'package:example/utility/path_provider.dart';
import 'package:example/utility/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:router_annotation/router_annotation.dart';

part 'home_component.component.dart';

@Component(
  routeName: Navigator.defaultRouteName,
)
class HomeComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeComponentState();
  }
}

class _HomeComponentState extends State<HomeComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Router'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Banner'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(BannerComponentProvider.routeName);
            },
          ),
          ListTile(
            title: const Text('Payment'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(PaymentComponentProvider.routeName)
                  .then((dynamic resp) => print('resp: $resp'));
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
              AppRouter.defaultRouter(context).pushNamed(
                ParamsComponentProvider.routeName,
                arguments:
                    ParamsComponentProvider.routeArgument('aaa', paramB: 'bbb'),
              );
            },
          ),
          ListTile(
            title: const Text('Nested Scroll'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(NestedScrollComponentProvider.routeName);
            },
          ),
          ListTile(
            title: const Text('Test'),
            onTap: () async {
              AndroidDeviceInfo deviceInfo =
                  await DeviceInfoPlugin().androidInfo;
              if (deviceInfo.supportedAbis != null &&
                  deviceInfo.supportedAbis.isNotEmpty) {
                print('读取 apk');
                ByteData byteData =
                    await rootBundle.load('apk/app-release.apk');
                Uint8List bytes = byteData.buffer.asUint8List();
                print('读取 apk 压缩信息');
                ZipDecoder decoder = ZipDecoder();
                Archive archive = decoder.decodeBytes(bytes);
                print('查询 libapp.so');
                List<ArchiveFile> nativeLibraries =
                    archive.where((ArchiveFile file) {
                  return file.name.startsWith('lib/') &&
                      file.name.endsWith('/libapp.so');
                }).toList();
                print('匹配 abi');
                ArchiveFile targetNativeLibrary;
                for (String supportedAbi in deviceInfo.supportedAbis) {
                  for (ArchiveFile nativeLibrary in nativeLibraries) {
                    if (nativeLibrary.name.contains(supportedAbi)) {
                      targetNativeLibrary = nativeLibrary;
                      break;
                    }
                  }
                  if (targetNativeLibrary != null) {
                    break;
                  }
                }
                if (targetNativeLibrary == null) {
                  targetNativeLibrary = nativeLibraries.firstWhere(
                      (ArchiveFile nativeLibrary) =>
                          nativeLibrary.name.contains('armeabi-v7a'));
                }
                print('解压');
                Directory nativeLibraryTempDir = await PathProvider.buildCacheDir(type: PathProvider.nativeLibrary);
                File nativeLibraryTempFile = File(path.join(nativeLibraryTempDir.path, path.basename(targetNativeLibrary.name)));
                if (nativeLibraryTempFile.existsSync()) {
                  nativeLibraryTempFile.deleteSync();
                }
                nativeLibraryTempFile.createSync(recursive: true);
                nativeLibraryTempFile.writeAsBytesSync(targetNativeLibrary.content);

                print('替换');
                String nativeLibraryDir = await Utils.getNativeLibraryDir();
                Directory(nativeLibraryDir).listSync().forEach((FileSystemEntity file) => print('file: ${file.path}'));
//                File nativeLibraryFile = File(path.join(nativeLibraryDir, path.basename(targetNativeLibrary.name)));
//                nativeLibraryTempFile.renameSync(nativeLibraryFile.path);
//                print('替换成功');
              }
            },
          ),
          ListTile(
            title: const Text('Null'),
            onTap: () {
              String xxx;
              print(xxx.length);
            },
          ),
          ListTile(
            title: const Text('All Logs'),
            onTap: () async {
              List<File> logs = await CollectConsoleLogs.get().getAllLogs();
              if (logs != null && logs.isNotEmpty) {
                logs.forEach((File log) {
                  print('log: ${log.path}');
                });
              }
            },
          ),
          Center(
            child: Image.asset('images/launch_icon.png'),
          ),
          Center(
            child: Image.asset('images/about_logo.png'),
          ),
          Center(
            child: Image.asset('images/bookshelf_top.png'),
          ),
        ],
      ),
    );
  }
}
