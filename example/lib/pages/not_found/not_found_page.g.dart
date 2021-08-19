// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'not_found_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class NotFoundPageController {
  @override
  String get name => NotFoundPageProvider.name;

  @override
  String get routeName => NotFoundPageProvider.routeName;

  @override
  WidgetBuilder get routeBuilder => NotFoundPageProvider.routeBuilder;

  @override
  String? get flavorName => NotFoundPageProvider.flavorName;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      switch (invocation.memberName) {
        case #name:
          return name;
        case #routeName:
          return routeName;
        case #routeBuilder:
          return routeBuilder;
        case #flavorName:
          return flavorName;
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class NotFoundPageProvider {
  const NotFoundPageProvider._();

  static const String name = '404';

  static const String routeName = '/not_found';

  static const String? flavorName = null;

  static final WidgetBuilder routeBuilder = (BuildContext context) {
    return NotFoundPage();
  };

  static Future<T?> pushByNamed<T extends Object?>(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }
}
