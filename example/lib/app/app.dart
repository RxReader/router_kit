import 'package:example/router/navigator_route.dart';
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
    if (AppNavigator.routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: AppNavigator.routes[settings.name],
        settings: settings,
      );
    }
    return null;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: AppNavigator.routes[AppNavigator.notFound],
      settings: settings,
    );
  }
}
