import 'dart:async';

import 'package:example/app/app.manifest.g.dart';
import 'package:example/pages/login/login_page.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_api/router_api.dart' as ra;

class AppRouter {
  AppRouter._();

  static const List<String> _shouldLoginRoute = <String>[
    PaymentPageProvider.routeName,
  ];

  static FutureOr<dynamic> _routerLogger(
    ra.Router router,
    String routeName,
    Object arguments,
    ra.NextDispatcher next,
  ) {
    print('Router -> routeName: $routeName');
    return next(router, routeName, arguments);
  }

  static FutureOr<dynamic> _shouldLogin(
    ra.Router router,
    String routeName,
    Object arguments,
    ra.NextDispatcher next,
  ) async {
    if (_shouldLoginRoute.contains(routeName)) {
      dynamic resp = await router.pushNamed(LoginPageProvider.routeName);
      if (!(resp != null && resp is bool && resp)) {
        return '用户取消登录';
      }
      await Future<void>.delayed(Duration(milliseconds: 300));
    }
    return next(router, routeName, arguments);
  }

  static ra.Router defaultRouter(BuildContext context) {
    return ra.Router(
      context,
      interceptors: <ra.Interceptor>[
        _routerLogger,
        _shouldLogin,
      ],
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (AppManifest.routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: AppManifest.routes[settings.name],
        settings: settings,
      );
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: AppManifest.routes[NotFoundPageProvider.routeName],
      settings: settings,
    );
  }
}
