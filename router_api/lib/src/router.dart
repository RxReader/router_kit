import 'dart:async';

import 'package:flutter/widgets.dart' hide Router;

typedef Interceptor = FutureOr<void> Function(BuildContext context, String routeName, {Object? arguments, Future<dynamic> Function()? next});

abstract class Controller {
  String get name;
  String get routeName;
  WidgetBuilder get routeBuilder;
}

class Router {
  Router() {
    registerBuiltIn();
  }

  final List<Interceptor> interceptors = <Interceptor>[];
  final Map<String, String> names = <String, String>{};
  final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{};
  final Map<String, Interceptor> routeInterceptors = <String, Interceptor>{};

  @protected
  void registerBuiltIn() {}

  void use({required Interceptor interceptor}) {
    assert(!interceptors.contains(interceptor));
    interceptors.add(interceptor);
  }

  void useRoute({required String name, required String routeName, required WidgetBuilder routeBuilder, Interceptor? interceptor}) {
    assert(!names.containsKey(routeName) && !routes.containsKey(routeName) && !routeInterceptors.containsKey(routeName));
    names[routeName] = name;
    routes[routeName] = routeBuilder;
    if (interceptor != null) {
      routeInterceptors[routeName] = interceptor;
    }
  }

  void useController({required Controller controller, Interceptor? interceptor}) {
    useRoute(name: controller.name, routeName: controller.routeName, routeBuilder: controller.routeBuilder, interceptor: interceptor);
  }
}
