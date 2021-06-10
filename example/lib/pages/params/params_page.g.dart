// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'params_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class ParamsPageController {
  String get name => ParamsPageProvider.name;

  String get routeName => ParamsPageProvider.routeName;

  WidgetBuilder get routeBuilder => ParamsPageProvider.routeBuilder;

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
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class ParamsPageProvider {
  const ParamsPageProvider._();

  static const String name = '参数';

  static const String routeName = '/params';

  static final WidgetBuilder routeBuilder = (BuildContext context) {
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

  static Future<T?> pushByNamed<T extends Object?>(
    BuildContext context,
    String paramA, {
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
        'paramA': paramA,
        'key': key,
        'paramB': paramB,
        'paramC': paramC,
        'paramF': paramF,
        'paramG': paramG,
        'callback': callback,
      },
    );
  }
}
