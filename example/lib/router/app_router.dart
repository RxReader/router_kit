import 'dart:async';

import 'package:example/components/about/about_component.dart';
import 'package:example/components/home/home_component.dart';
import 'package:example/components/login/login_component.dart';
import 'package:example/components/not_found/not_found_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';
import 'package:example/components/splash/splash_component.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart' as annot;
import 'package:router_api/router_api.dart';

part 'app_router.router.dart';

@annot.Router()
class AppRouter {
  AppRouter._();

  static const List<String> _shouldLoginRoute = <String>[
    PaymentComponentProvider.routeName,
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
      dynamic resp = await router.pushNamed(LoginComponentProvider.routeName);
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
