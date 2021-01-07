// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class ParamsPageProvider {
  const ParamsPageProvider._();

  static const String name = '参数';
  static const String routeName = '/params';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return ParamsPage(
      arguments['param_a'] as String,
      paramB: arguments['param_b'] as String,
      paramC: arguments['param_d'] as String,
      callback: arguments['callback'] as String Function(String),
    );
  };

  static Map<String, dynamic> routeArgument(
    String paramA, {
    @required String paramB,
    String paramC,
    String Function(String) callback,
  }) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments['param_a'] = paramA;
    arguments['param_b'] = paramB;
    arguments['param_d'] = paramC;
    arguments['callback'] = callback;
    return arguments;
  }

  static Future<T> pushByNamed<T extends Object>(
    BuildContext context,
    String paramA, {
    @required String paramB,
    String paramC,
    String Function(String) callback,
  }) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments['param_a'] = paramA;
    arguments['param_b'] = paramB;
    arguments['param_d'] = paramC;
    arguments['callback'] = callback;
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  }
}
