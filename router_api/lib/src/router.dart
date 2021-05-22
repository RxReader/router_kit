import 'dart:async';

import 'package:flutter/widgets.dart' hide Router;

typedef Next = Future<dynamic?> Function();
typedef Interceptor = Future<dynamic?> Function(BuildContext context, String routeName, {Object? arguments, Next? next});

abstract class Controller {
  String get name;

  String get routeName;

  WidgetBuilder get routeBuilder;
}

class Router {
  Router() {
    registerBuiltIn();
  }

  final List<Interceptor> _interceptors = <Interceptor>[];
  final Map<String, String> _names = <String, String>{};
  final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{};
  final Map<String, Interceptor> _routeInterceptors = <String, Interceptor>{};

  List<Interceptor> get interceptors => List<Interceptor>.unmodifiable(_interceptors);

  Map<String, String> get names => Map<String, String>.unmodifiable(_names);

  Map<String, WidgetBuilder> get routes => Map<String, WidgetBuilder>.unmodifiable(_routes);

  Map<String, Interceptor> get routeInterceptors => Map<String, Interceptor>.unmodifiable(_routeInterceptors);

  @protected
  void registerBuiltIn() {}

  void use({required Interceptor interceptor}) {
    assert(!_interceptors.contains(interceptor));
    _interceptors.add(interceptor);
  }

  void useRoute({required String name, required String routeName, required WidgetBuilder routeBuilder, Interceptor? interceptor}) {
    assert(!_names.containsKey(routeName) && !_routes.containsKey(routeName) && !_routeInterceptors.containsKey(routeName));
    _names[routeName] = name;
    _routes[routeName] = routeBuilder;
    if (interceptor != null) {
      _routeInterceptors[routeName] = interceptor;
    }
  }

  void useController({required Map<String, dynamic> controller, Interceptor? interceptor}) {
    useRoute(name: controller['name'] as String, routeName: controller['routeName'] as String, routeBuilder: controller['routeBuilder'] as WidgetBuilder, interceptor: interceptor);
  }
}
