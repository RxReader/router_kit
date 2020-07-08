import 'dart:async';

import 'package:flutter/widgets.dart';

class Router {
  Router(
    this.context, {
    List<Interceptor> interceptors,
  }) : interceptors = interceptors ?? const <Interceptor>[];

  @protected
  final BuildContext context;
  @protected
  final List<Interceptor> interceptors;

  Future<dynamic> navigate(
    Navigation navigation,
    String routeName, {
    Object arguments,
  }) async {
    List<NextDispatcher> nextDispatchers = _createDispatchers(
      (_, __, ___) {
        return navigation(context, routeName, arguments);
      },
      interceptors,
    );
    return await nextDispatchers[0](this, routeName, arguments);
  }

  Future<dynamic> pushNamed(
    String routeName, {
    Object arguments,
  }) {
    return navigate(
      (BuildContext context, String routeName, Object arguments) {
        return Navigator.of(context).pushNamed(routeName, arguments: arguments);
      },
      routeName,
      arguments: arguments,
    );
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

  Router copyWith({
    List<Interceptor> interceptors,
  }) {
    return Router(
      context,
      interceptors: interceptors ?? this.interceptors,
    );
  }
}

typedef NextDispatcher = FutureOr<dynamic> Function(
  Router router,
  String routeName,
  Object arguments,
);

typedef Interceptor = FutureOr<dynamic> Function(
  Router router,
  String routeName,
  Object arguments,
  NextDispatcher next,
);

typedef Navigation = FutureOr<dynamic> Function(
  BuildContext context,
  String routeName,
  Object arguments,
);
