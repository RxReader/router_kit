// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class AboutPageController {
  @override
  String get name => AboutPageProvider.name;

  @override
  String get routeName => AboutPageProvider.routeName;

  @override
  WidgetBuilder get routeBuilder => AboutPageProvider.routeBuilder;

  @override
  String? get flavorName => AboutPageProvider.flavorName;

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

class AboutPageProvider {
  const AboutPageProvider._();

  static const String name = '关于';

  static const String routeName = '/about';

  static const String? flavorName = 'target';

  static final WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return AboutPage(
      key: arguments?['key'] as Key?,
    );
  };

  static Map<String, dynamic> routeArgument({
    Key? key,
  }) {
    return <String, dynamic>{
      'key': key,
    };
  }

  static Future<T?> pushByNamed<T extends Object?>(
    BuildContext context, {
    Key? key,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: <String, dynamic>{
        'key': key,
      },
    );
  }
}
