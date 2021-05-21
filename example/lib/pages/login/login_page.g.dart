// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class LoginPageProvider {
  const LoginPageProvider._();

  static const String name = '登录';

  static const String routeName = '/login';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return LoginPage(
      key: arguments['key'] as Key,
    );
  };
}

class LoginPageNavigator {
  const LoginPageNavigator._();

  static Map<String, dynamic> routeArgument({
    Key key,
  }) {
    return <String, dynamic>{
      'key': key,
    };
  }
}
