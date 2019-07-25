import 'dart:async';

import 'package:flutter/widgets.dart';

class Router {
  Router._(
    BuildContext context,
    List<Interceptor> interceptors,
  )   : _context = context,
        _interceptors = interceptors;

  final BuildContext _context;
  final List<Interceptor> _interceptors;

  Future<dynamic> pushNamed(String routeName, {Object arguments}) {
    return navigate((BuildContext context, String routeName, Object arguments) {
      return Navigator.of(_context).pushNamed(routeName, arguments: arguments);
    }, routeName, arguments: arguments);
  }

  Future<dynamic> navigate(Navigation navigation, String routeName,
      {Object arguments}) async {
    List<NextDispatcher> nextDispatchers = _createDispatchers((_, __, ___) {
      return navigation(_context, routeName, arguments);
    }, _interceptors);
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

  static RouterBuilder of(BuildContext context) {
    return RouterBuilder._(context);
  }
}

class RouterBuilder {
  RouterBuilder._(
    BuildContext context,
  ) : _context = context;

  final BuildContext _context;
  final List<Interceptor> _interceptors = <Interceptor>[];

  RouterBuilder addInterceptor(Interceptor interceptor) {
    assert(interceptor != null);
    _interceptors.add(interceptor);
    return this;
  }

  Router build() {
    return Router._(
      _context,
      List.unmodifiable(_interceptors),
    );
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

typedef FutureOr<dynamic> Navigation(
  BuildContext context,
  String routeName,
  Object arguments,
);
