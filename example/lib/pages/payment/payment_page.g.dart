// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class PaymentPageController {
  @override
  String get name => PaymentPageProvider.name;

  @override
  String get routeName => PaymentPageProvider.routeName;

  @override
  WidgetBuilder get routeBuilder => PaymentPageProvider.routeBuilder;

  @override
  String? get flavorName => PaymentPageProvider.flavorName;

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
        case #flavorName:
          return flavorName;
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class PaymentPageProvider {
  const PaymentPageProvider._();

  static const String name = '购买';

  static const String routeName = '/payment';

  static const String? flavorName = null;

  static final WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return PaymentPage(
      arguments?['param_a'] as String,
      arguments?['param_a_a'] as String?,
      arguments?['key'] as Key?,
      arguments?['param_b'] as String?,
      arguments?['param_c'] as String,
      arguments?['param_d'] as String?,
    );
  };

  static Map<String, dynamic> routeArgument(
    String paramA,
    String? paramAA, [
    Key? key,
    String? paramB,
    String paramC = 'abc',
    String? paramD = 'asd',
  ]) {
    return <String, dynamic>{
      'param_a': paramA,
      'param_a_a': paramAA,
      'key': key,
      'param_b': paramB,
      'param_c': paramC,
      'param_d': paramD,
    };
  }

  static Future<T?> pushByNamed<T extends Object?>(
    BuildContext context,
    String paramA,
    String? paramAA, [
    Key? key,
    String? paramB,
    String paramC = 'abc',
    String? paramD = 'asd',
  ]) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: <String, dynamic>{
        'param_a': paramA,
        'param_a_a': paramAA,
        'key': key,
        'param_b': paramB,
        'param_c': paramC,
        'param_d': paramD,
      },
    );
  }
}
