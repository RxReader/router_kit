import 'dart:io';

import 'package:example/logs/collect-console-logs.dart';
import 'package:example/router/navigator_route.dart';
import 'package:example/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            title: const Text('Payment'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(AppNavigator.payment)
                  .then((dynamic resp) => print('resp: $resp'));
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
//              AppRouter.defaultRouter(context).pushNamed(
//                AppNavigator.params,
//                arguments: ParamsRoute.arguments(paramA: 'aaa', paramC: 'ccc'),
//              );
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
        ],
      ),
    );
  }
}
