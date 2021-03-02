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
      arguments['paramA'] as String,
      key: arguments['key'] as Key,
      paramB: arguments['paramB'] as String,
      paramC: arguments['param_d'] as String,
      callback: arguments['callback'] as String Function(String),
    );
  };
}

class ParamsPageNavigator {
  const ParamsPageNavigator._();

  static Map<String, dynamic> routeArgument(String paramA,
      {Key key,
      String paramB,
      String paramC,
      String Function(String info) callback}) {
    return <String, dynamic>{
      'paramA': paramA,
      'key': key,
      'paramB': paramB,
      'param_d': paramC,
      'callback': callback,
    };
  }
}
