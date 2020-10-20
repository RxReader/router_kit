// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// RouterCompilerGenerator
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
      paramC: arguments['param_c'] as String,
      paramE: arguments['param_e'] as String,
      callback: arguments['callback'] as String Function(String),
    );
  };

  static Map<String, dynamic> routeArgument(
    String paramA, {
    @required String paramB,
    String paramC,
    String paramE,
    String Function(String) callback,
  }) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments['param_a'] = paramA;
    arguments['param_b'] = paramB;
    arguments['param_c'] = paramC;
    arguments['param_e'] = paramE;
    arguments['callback'] = callback;
    return arguments;
  }
}
