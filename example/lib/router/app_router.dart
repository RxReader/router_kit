//import 'dart:async';
//
//import 'package:flutter/widgets.dart';
//import 'package:router_annotation/router_annotation.dart';
//import 'package:router_api/router_api.dart';
//
//@Router()
//class AppRouter {
//  AppRouter._();
//
//  static const List<String> _shouldLoginRoute = <String>[
//    PaymentComponentProvider.routeName,
//  ];
//
//  static FutureOr<dynamic> _routerLogger(
//    CRouter router,
//    String routeName,
//    Object arguments,
//    NextDispatcher next,
//  ) {
//    print('Router -> routeName: $routeName');
//    return next(router, routeName, arguments);
//  }
//
//  static FutureOr<dynamic> _shouldLogin(
//    CRouter router,
//    String routeName,
//    Object arguments,
//    NextDispatcher next,
//  ) async {
//    if (_shouldLoginRoute.contains(routeName)) {
//      dynamic resp = await router.pushNamed(LoginComponentProvider.routeName);
//      if (!(resp != null && resp is bool && resp)) {
//        return '用户取消登录';
//      }
//      await Future<void>.delayed(Duration(milliseconds: 300));
//    }
//    return next(router, routeName, arguments);
//  }
//
//  static CRouter defaultRouter(BuildContext context) {
//    return CRouter.of(context)
//        .addInterceptor(_routerLogger)
//        .addInterceptor(_shouldLogin)
//        .build();
//  }
//}
