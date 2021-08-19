import 'package:flutter/widgets.dart' hide Router;

class Router {
  Router() {
    registerBuiltIn();
  }

  final Map<String, String> _names = <String, String>{};
  final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{};

  Map<String, String> get names => Map<String, String>.unmodifiable(_names);

  Map<String, WidgetBuilder> get routes => Map<String, WidgetBuilder>.unmodifiable(_routes);

  @protected
  void registerBuiltIn() {}

  void useRoute({
    required String name,
    required String routeName,
    required WidgetBuilder routeBuilder,
  }) {
    assert(!_names.containsKey(routeName) && !_routes.containsKey(routeName));
    _names[routeName] = name;
    _routes[routeName] = routeBuilder;
  }

  void useController({
    required dynamic controller,
  }) {
    final Controller wrapper = Controller.from(controller);
    useRoute(
      name: wrapper.name,
      routeName: wrapper.routeName,
      routeBuilder: wrapper.routeBuilder,
    );
  }
}

class Controller {
  Controller.from(this.delegated);
  final dynamic delegated;

  String get name => delegated.noSuchMethod(Invocation.getter(#name)) as String;
  String get routeName => delegated.noSuchMethod(Invocation.getter(#routeName)) as String;
  WidgetBuilder get routeBuilder => delegated.noSuchMethod(Invocation.getter(#routeBuilder)) as WidgetBuilder;
  String? get flavorName => delegated.noSuchMethod(Invocation.getter(#flavorName)) as String?;
}
