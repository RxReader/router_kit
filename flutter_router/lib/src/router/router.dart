import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class Router {
  void interceptor(Interceptor interceptor);

  Future<dynamic> pushNamed(String routeName, {Object arguments});

  Future<dynamic> pushReplacementNamed(String routeName,
      {Object result, Object arguments});

  static Router of(BuildContext context) {
    return _Router._(context);
  }
}

typedef FutureOr<dynamic> NextDispatcher(
  Router router,
  String routeName,
  Object arguments,
);

typedef FutureOr<dynamic> Interceptor(
  Router router,
  String routeName,
  Object arguments,
  NextDispatcher next,
);

class _Router implements Router {
  _Router._(
    this.context,
  );

  final BuildContext context;
  final List<Interceptor> interceptors = <Interceptor>[];

  @override
  void interceptor(Interceptor interceptor) {
    interceptors.add(interceptor);
  }

  @override
  Future<dynamic> pushNamed(String routeName, {Object arguments}) async {
    List<NextDispatcher> nextDispatchers = _createDispatchers((_, __, ___) {
      return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }, interceptors);
    return await nextDispatchers[0](this, routeName, arguments);
  }

  @override
  Future<dynamic> pushReplacementNamed(String routeName,
      {Object result, Object arguments}) async {
    List<NextDispatcher> nextDispatchers = _createDispatchers((_, __, ___) {
      return Navigator.of(context).pushReplacementNamed(routeName,
          result: result, arguments: arguments);
    }, interceptors);
    return await nextDispatchers[0](this, routeName, arguments);
  }

  List<NextDispatcher> _createDispatchers(
      NextDispatcher navigator, List<Interceptor> interceptors) {
    List<NextDispatcher> dispatchers = <NextDispatcher>[];
    dispatchers.add(navigator); // 倒序
    // 倒序
    for (Interceptor nextInterceptor in interceptors.reversed) {
      final NextDispatcher next = dispatchers.last;
      dispatchers.add((Router router, String routeName, Object arguments) {
        return nextInterceptor(router, routeName, arguments, next);
      });
    }
    return dispatchers.reversed.toList(); // 倒序
  }
}
