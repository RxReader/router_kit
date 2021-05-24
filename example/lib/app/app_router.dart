import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/home/home_page.dart';
import 'package:example/pages/login/login_page.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:router_api/router_api.dart' as ra;

mixin Manifest on ra.Router {
  @override
  @protected
  void registerBuiltIn() {
    useController(controller: HomePageProvider.controller);
    useController(controller: AboutPageProvider.controller);
    useController(controller: LoginPageProvider.controller);
    useController(controller: NotFoundPageProvider.controller);
    useController(controller: ParamsPageProvider.controller);
    useController(controller: PaymentPageProvider.controller);
  }
}

class AppRouter extends ra.Router with Manifest {
  AppRouter._() : super();

  static AppRouter get instance => _instance ??= AppRouter._();
  static AppRouter? _instance;

  Future<dynamic> pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    final List<ra.Interceptor> activeInterceptors = <ra.Interceptor>[
      ...interceptors,
      if (routeInterceptors.containsKey(routeName)) routeInterceptors[routeName]!,
    ];
    final List<ra.Next> nexts = <ra.Next>[
      () => Navigator.of(context).pushNamed(routeName, arguments: arguments),
    ];
    for (final ra.Interceptor interceptor in activeInterceptors.reversed) {
      final ra.Next next = nexts.last;
      nexts.add(() => interceptor.call(context, routeName, arguments: arguments, next: next));
    }
    return nexts.last.call();
  }

  Future<dynamic> pushReplacementNamed(BuildContext context, String routeName, {Object? result, Object? arguments}) {
    final List<ra.Interceptor> activeInterceptors = <ra.Interceptor>[
      ...interceptors,
      if (routeInterceptors.containsKey(routeName)) routeInterceptors[routeName]!,
    ];
    final List<ra.Next> nexts = <ra.Next>[
      () => Navigator.of(context).pushReplacementNamed(routeName, result: result, arguments: arguments),
    ];
    for (final ra.Interceptor interceptor in activeInterceptors.reversed) {
      final ra.Next next = nexts.last;
      nexts.add(() => interceptor.call(context, routeName, arguments: arguments, next: next));
    }
    return nexts.last.call();
  }
}
