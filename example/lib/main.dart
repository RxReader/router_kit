import 'dart:async';
import 'dart:io';

import 'package:example/app/app.dart';
import 'package:example/logs/collect-console-logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runZoned(
    () {
      runApp(App());
    },
    zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      // 全局控制台日志拦截
      parent.print(zone, 'Intercepted: $line');
      CollectConsoleLogs.get().print(zone, line);
    }),
    onError: (Object error, [StackTrace stackTrace]) {
      print(error);
      print(stackTrace);
    },
  );

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
