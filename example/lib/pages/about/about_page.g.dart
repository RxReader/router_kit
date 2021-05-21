// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class AboutPageProvider {
  const AboutPageProvider._();

  static const String name = '关于';

  static const String routeName = '/about';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return AboutPage(
      key: arguments['key'] as Key,
    );
  };
}

class AboutPageNavigator {
  const AboutPageNavigator._();

  static Map<String, dynamic> routeArgument({
    Key key,
  }) {
    return <String, dynamic>{
      'key': key,
    };
  }
}
