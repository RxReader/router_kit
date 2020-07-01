import 'dart:async';

import 'package:flutter/widgets.dart';

class CRouter {
  CRouter._(
    BuildContext context,
    List<Interceptor> interceptors,
  )   : _context = context,
        _interceptors = interceptors;

  final BuildContext _context;
  final List<Interceptor> _interceptors;

  Future<dynamic> navigate(Navigation navigation, String routeName,
      {Object arguments}) async {
    List<NextDispatcher> nextDispatchers = _createDispatchers((_, __, ___) {
      return navigation(_context, routeName, arguments);
    }, _interceptors);
    return await nextDispatchers[0](this, routeName, arguments);
  }

  Future<dynamic> pushNamed(String routeName, {Object arguments}) {
    return navigate((BuildContext context, String routeName, Object arguments) {
      return Navigator.of(_context).pushNamed(routeName, arguments: arguments);
    }, routeName, arguments: arguments);
  }

  List<NextDispatcher> _createDispatchers(
      NextDispatcher navigator, List<Interceptor> interceptors) {
    List<NextDispatcher> dispatchers = <NextDispatcher>[];
    dispatchers.add(navigator); // 倒序
    // 倒序
    for (Interceptor nextInterceptor in interceptors.reversed) {
      final NextDispatcher next = dispatchers.last;
      dispatchers.add((CRouter router, String routeName, Object arguments) {
        return nextInterceptor(router, routeName, arguments, next);
      });
    }
    return dispatchers.reversed.toList(); // 倒序
  }

  static CRouterBuilder of(BuildContext context) {
    return CRouterBuilder._(context);
  }
}

class CRouterBuilder {
  CRouterBuilder._(
    BuildContext context,
  ) : _context = context;

  final BuildContext _context;
  final List<Interceptor> _interceptors = <Interceptor>[];

  CRouterBuilder addInterceptor(Interceptor interceptor) {
    assert(interceptor != null);
    _interceptors.add(interceptor);
    return this;
  }

  CRouter build() {
    return CRouter._(
      _context,
      List<Interceptor>.unmodifiable(_interceptors),
    );
  }
}

typedef NextDispatcher = FutureOr<dynamic> Function(
  CRouter router,
  String routeName,
  Object arguments,
);

typedef Interceptor = FutureOr<dynamic> Function(
  CRouter router,
  String routeName,
  Object arguments,
  NextDispatcher next,
);

typedef Navigation = FutureOr<dynamic> Function(
  BuildContext context,
  String routeName,
  Object arguments,
);
