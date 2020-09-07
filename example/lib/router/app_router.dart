import 'dart:async';

import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/home/home_page.dart';
import 'package:example/pages/login/login_page.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:example/pages/reader/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_api/router_api.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{
    HomePageProvider.routeName: HomePageProvider.routeBuilder,
    NotFoundPageProvider.routeName: NotFoundPageProvider.routeBuilder,
    ParamsPageProvider.routeName: ParamsPageProvider.routeBuilder,
    LoginPageProvider.routeName: LoginPageProvider.routeBuilder,
    PaymentPageProvider.routeName: PaymentPageProvider.routeBuilder,
    ReaderPageProvider.routeName: ReaderPageProvider.routeBuilder,
    AboutPageProvider.routeName: AboutPageProvider.routeBuilder,
  };

  static const List<String> _shouldLoginRoute = <String>[
    PaymentPageProvider.routeName,
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
      dynamic resp = await router.pushNamed(LoginPageProvider.routeName);
      if (!(resp != null && resp is bool && resp)) {
        return '用户取消登录';
      }
      await Future<void>.delayed(Duration(milliseconds: 300));
    }
    return next(router, routeName, arguments);
  }

  static Router defaultRouter(BuildContext context) {
    return Router(
      context,
      interceptors: <Interceptor>[
        _routerLogger,
        _shouldLogin,
      ],
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (_routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: _routes[settings.name],
        settings: settings,
      );
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: _routes[NotFoundPageProvider.routeName],
      settings: settings,
    );
  }
}
