import 'dart:async';

import 'package:example/app/app.manifest.g.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'app.g.dart';

FutureOr<void> _globalA(dynamic context, String routeName, VoidCallback next) {
  assert(context is BuildContext);
  next?.call();
}

@rca.Manifest(
  interceptors: <rca.RouteInterceptor>[
    _globalA,
    App._globalB,
  ],
)
class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  static FutureOr<void> _globalB(dynamic context, String routeName, VoidCallback next) {
    assert(context is BuildContext);
    next?.call();
  }

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onUnknownRoute,
      builder: (BuildContext context, Widget child) {
        /// 禁用系统字体控制
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            boldText: false,
          ),
          child: child,
        );
      },
      onGenerateTitle: (BuildContext context) {
        return 'RouterKit';
      },
      theme: ThemeData.light().copyWith(
        platform: TargetPlatform.iOS,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    if (AppManifest.routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: AppManifest.routes[settings.name],
        settings: settings,
      );
    }
    return null;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: AppManifest.routes[NotFoundPageProvider.routeName],
      settings: settings,
    );
  }
}
