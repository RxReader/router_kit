// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class ParamsPageController {
  const ParamsPageController._();

  static const String name = '参数';

  static const String routeName = '/params';

  static WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return ParamsPage(
      arguments?['paramA'] as String,
      key: arguments?['key'] as Key?,
      paramB: arguments?['paramB'] as String,
      paramC: arguments?['paramC'] as String?,
      paramF: arguments?['paramF'] as String?,
      paramG: arguments?['paramG'] as String,
      callback: arguments?['callback'] as String? Function(String?)?,
    );
  };

  static Map<String, dynamic> routeArgument(
    String paramA, {
    Key? key,
    required String paramB,
    String? paramC,
    String? paramF = 'xyz',
    String paramG = 'xxx',
    String? Function(String? info)? callback,
  }) {
    return <String, dynamic>{
      'paramA': paramA,
      'key': key,
      'paramB': paramB,
      'paramC': paramC,
      'paramF': paramF,
      'paramG': paramG,
      'callback': callback,
    };
  }
}
