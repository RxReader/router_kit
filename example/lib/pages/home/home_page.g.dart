// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class HomePageProvider {
  const HomePageProvider._();

  static const String name = '首页';

  static const String routeName = '/';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return HomePage(
      key: arguments?['key'] as Key?,
    );
  };
}

class HomePageNavigator {
  const HomePageNavigator._();

  static Map<String, dynamic> routeArgument({
    Key? key,
  }) {
    return <String, dynamic>{
      'key': key,
    };
  }
}
