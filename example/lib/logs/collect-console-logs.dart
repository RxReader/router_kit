import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_path_provider/fake_path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class CollectConsoleLogs {
  CollectConsoleLogs._();

  factory CollectConsoleLogs.get() {
    return _instance;
  }

  static final CollectConsoleLogs _instance = CollectConsoleLogs._();

  File _logs;

  Future<void> print(Zone zone, String line) async {
    if (_logs == null) {
      Directory doc = await PathProvider.getDocumentsDirectory();
      Directory console = Directory(path.join(doc.path, 'console'));
      if (!console.existsSync()) {
        console.createSync(recursive: true);
      }
      String day = DateFormat('yyyy_MM_dd').format(DateTime.now().toLocal());
      _logs = File(path.join(console.path, 'console_$day.log'));
      if (!_logs.existsSync()) {
        _logs.createSync(recursive: true);
      }
    }
     _logs.writeAsStringSync(
      '$line\r\n',
      mode: FileMode.append,
      encoding: utf8,
      flush: true,
    );
  }

  Future<List<File>> getAllLogs() async {
    Directory doc = await PathProvider.getDocumentsDirectory();
    Directory console = Directory(path.join(doc.path, 'console'));
    if (!console.existsSync()) {
      console.createSync(recursive: true);
    }
    List<FileSystemEntity> files = console.listSync() ?? <FileSystemEntity>[];
    files.removeWhere((FileSystemEntity element) {
      return !(element is File);
    });
    // 日志文件倒叙
    files.sort((FileSystemEntity a, FileSystemEntity b) {
      return b.statSync().modified.compareTo(a.statSync().modified);
    });
    return files.map<File>((FileSystemEntity file) {
      return file as File;
    }).toList();
  }
}
