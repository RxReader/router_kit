// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// RouterCompilerGenerator
// **************************************************************************

class ParamsPageProvider {
  const ParamsPageProvider._();

  static const String routeName = '/params';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<dynamic, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;
    return ParamsPage(
      arguments['param_a'] as String,
      paramB: arguments['param_b'] as String,
      paramC: arguments['param_c'] as String,
      paramE: arguments['param_e'] as String,
      callback: arguments['callback'] as String Function(String),
    );
  };

  static Map<dynamic, dynamic> routeArgument(
    String paramA, {
    @required String paramB,
    String paramC,
    String paramE,
    String Function(String) callback,
  }) {
    Map<dynamic, dynamic> arguments = <dynamic, dynamic>{};
    arguments['param_a'] = paramA;
    arguments['param_b'] = paramB;
    arguments['param_c'] = paramC;
    arguments['param_e'] = paramE;
    arguments['callback'] = callback;
    return arguments;
  }
}
