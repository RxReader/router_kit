import 'package:example/app/app_router.manifest.g.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart' as rca;
import 'package:router_api/router_api.dart' as ra;

typedef Next = Future<dynamic> Function();
typedef Interceptor = Future<dynamic> Function(
  BuildContext context,
  String routeName, {
  Object? arguments,
  Next? next,
});

mixin InterceptableRouter on ra.Router {
  final List<Interceptor> _interceptors = <Interceptor>[];
  final Map<String, Interceptor> _routeInterceptors = <String, Interceptor>{};

  void use({required Interceptor interceptor}) {
    assert(!_interceptors.contains(interceptor));
    _interceptors.add(interceptor);
  }

  @override
  void useRoute({required String name, required String routeName, required WidgetBuilder routeBuilder, Interceptor? interceptor}) {
    assert(!_routeInterceptors.containsKey(routeName));
    super.useRoute(name: name, routeName: routeName, routeBuilder: routeBuilder);
    if (interceptor != null) {
      _routeInterceptors[routeName] = interceptor;
    }
  }

  @override
  void useController({required dynamic controller, Interceptor? interceptor}) {
    final ra.Controller wrapper = ra.Controller.from(controller);
    useRoute(
      name: wrapper.name,
      routeName: wrapper.routeName,
      routeBuilder: wrapper.routeBuilder,
      interceptor: interceptor,
    );
  }

  Future<Object?> pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    final List<Interceptor> activeInterceptors = <Interceptor>[
      ..._interceptors,
      if (_routeInterceptors.containsKey(routeName)) _routeInterceptors[routeName]!,
    ];
    final List<Next> nexts = <Next>[
      () => Navigator.of(context).pushNamed(routeName, arguments: arguments),
    ];
    for (final Interceptor interceptor in activeInterceptors.reversed) {
      final Next next = nexts.last;
      nexts.add(() => interceptor.call(context, routeName, arguments: arguments, next: next));
    }
    return nexts.last.call();
  }

  Future<Object?> pushReplacementNamed(BuildContext context, String routeName, {Object? result, Object? arguments}) {
    final List<Interceptor> activeInterceptors = <Interceptor>[
      ..._interceptors,
      if (_routeInterceptors.containsKey(routeName)) _routeInterceptors[routeName]!,
    ];
    final List<Next> nexts = <Next>[
      () => Navigator.of(context).pushReplacementNamed(routeName, result: result, arguments: arguments),
    ];
    for (final Interceptor interceptor in activeInterceptors.reversed) {
      final Next next = nexts.last;
      nexts.add(() => interceptor.call(context, routeName, arguments: arguments, next: next));
    }
    return nexts.last.call();
  }
}

@rca.Manifest()
mixin Manifest on ra.Router, InterceptableRouter {
  @mustCallSuper
  @protected
  @override
  void registerBuiltIn() {
    super.registerBuiltIn();
    // use(interceptor: _globalAuth);
    for (final dynamic controller in ManifestProvider.controllers) {
      final ra.Controller ctrl = ra.Controller.from(controller);
      if (ctrl.flavor == null) {
        useController(controller: ctrl);
      }
    }
  }

  // static Future<dynamic> _globalAuth(
  //   BuildContext context,
  //   String routeName, {
  //   Object? arguments,
  //   Next? next,
  // }) async {
  //   assert(context is BuildContext);
  //   const dynamic isLoggedin = false;
  //   if (isLoggedin != null && isLoggedin is bool && isLoggedin) {
  //     return next?.call();
  //   }
  //   return null;
  // }
}

class AppRouter extends ra.Router with InterceptableRouter, Manifest {
  AppRouter._() : super();

  static AppRouter get instance => _instance ??= AppRouter._();
  static AppRouter? _instance;

  @protected
  @override
  void registerBuiltIn() {
    super.registerBuiltIn();
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute<dynamic>(
        builder: routes[settings.name]!,
        settings: settings,
      );
    }
    return null;
  }

  Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: routes[NotFoundPageProvider.routeName]!,
      settings: settings,
    );
  }
}
