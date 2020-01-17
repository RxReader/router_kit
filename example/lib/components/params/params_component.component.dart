// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_component.dart';

// **************************************************************************
// ComponentCompilerGenerator
// **************************************************************************

class ParamsComponentProvider {
  const ParamsComponentProvider._();

  static const String routeName = '/params';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<dynamic, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;
    return ParamsComponent(
      arguments['param_a'] as String,
      paramB: arguments['param_b'] as String,
      paramC: arguments['param_d'] as String,
      callback: arguments['callback'] as String Function(String),
    );
  };

  static Map<dynamic, dynamic> routeArgument(
    String paramA, {
    @required String paramB,
    String paramC,
    String Function(String) callback,
  }) {
    Map<dynamic, dynamic> arguments = <dynamic, dynamic>{};
    arguments['param_a'] = paramA;
    arguments['param_b'] = paramB;
    arguments['param_d'] = paramC;
    arguments['callback'] = callback;
    return arguments;
  }
}
