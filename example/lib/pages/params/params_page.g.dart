// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class ParamsPageController {
  String get name => ParamsPageProvider.name;

  String get routeName => ParamsPageProvider.routeName;

  WidgetBuilder get routeBuilder => ParamsPageProvider.routeBuilder;

  String? get flavor => ParamsPageProvider.flavor;

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
        case #flavor:
          return flavor;
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class ParamsPageProvider {
  const ParamsPageProvider._();

  static const String name = '参数';

  static const String routeName = '/params';

  static const String? flavor = null;

  static final WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return ParamsPage(
      arguments?['param_a_1'] as String,
      key: arguments?['key'] as Key?,
      paramB: arguments?['param_b'] as String,
      paramC: arguments?['param_c'] as String?,
      paramF: arguments?['param_f'] as String?,
      paramG: arguments?['param_g'] as String,
      callback: arguments?['callback'] as String? Function(String?)?,
    );
  };

  static Map<String, dynamic> routeArgument(
    String paramA1, {
    Key? key,
    required String paramB,
    String? paramC,
    String? paramF = 'xyz',
    String paramG = 'xxx',
    String? Function(String? info)? callback,
  }) {
    return <String, dynamic>{
      'param_a_1': paramA1,
      'key': key,
      'param_b': paramB,
      'param_c': paramC,
      'param_f': paramF,
      'param_g': paramG,
      'callback': callback,
    };
  }

  static Future<T?> pushByNamed<T extends Object?>(
    BuildContext context,
    String paramA1, {
    Key? key,
    required String paramB,
    String? paramC,
    String? paramF = 'xyz',
    String paramG = 'xxx',
    String? Function(String? info)? callback,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: <String, dynamic>{
        'param_a_1': paramA1,
        'key': key,
        'param_b': paramB,
        'param_c': paramC,
        'param_f': paramF,
        'param_g': paramG,
        'callback': callback,
      },
    );
  }
}
