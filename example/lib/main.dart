import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:example/app/app.dart';
import 'package:example/logs/collect_console_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  void _reportError(Object error, StackTrace stackTrace) {}

  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.dumpErrorToConsole(details);
    _reportError(details.exception, details.stack);
  };

  Isolate.current.addErrorListener(RawReceivePort((List<String> message) async {
    RemoteError error = RemoteError(message[0], message[1]);
    _reportError(error, error.stackTrace);
  }).sendPort);

  runZoned(
    () {
      runApp(App());
    },
    zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      // 全局控制台日志拦截
      parent.print(zone, 'xxx: $line');
      CollectConsoleLogs.get().print(zone, line);
    }),
    onError: (Object error, [StackTrace stackTrace]) {
      _reportError(error, stackTrace);
    },
  );

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
