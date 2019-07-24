import 'dart:async';

import 'package:example/router/navigator_route.dart';
import 'package:flutter/widgets.dart';
import 'package:router_api/router_api.dart';

class AppRouter {
  AppRouter._();

  static const List<String> _shouldLoginRoute = <String>[
    AppNavigator.payment,
  ];

  static FutureOr<dynamic> _routerLogger(
    Router router,
    String routeName,
    Object arguments,
    NextDispatcher next,
  ) {
    print('Router -> routeName: $routeName');
    return next(router, routeName, arguments);
  }

  static FutureOr<dynamic> _shouldLogin(
    Router router,
    String routeName,
    Object arguments,
    NextDispatcher next,
  ) async {
    if (_shouldLoginRoute.contains(routeName)) {
      dynamic resp = await router.pushNamed(AppNavigator.login);
      if (!(resp != null && resp is bool && resp)) {
        return '用户取消登录';
      }
      await Future<void>.delayed(Duration(milliseconds: 300));
    }
    return next(router, routeName, arguments);
  }

  static Router defaultRouter(BuildContext context) {
    return Router.of(context)
        .addInterceptor(_routerLogger)
        .addInterceptor(_shouldLogin)
        .build();
  }
}
