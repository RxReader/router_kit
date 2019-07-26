import 'package:example/components/not_found/not_found_component.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class App extends StatefulWidget {
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
        return 'Router';
      },
      theme: ThemeData.light().copyWith(
        platform: TargetPlatform.iOS,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    if (AppRouterProvider.routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: AppRouterProvider.routes[settings.name],
        settings: settings,
      );
    }
    return null;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: AppRouterProvider.routes[NotFoundComponentProvider.routeName],
      settings: settings,
    );
  }
}
