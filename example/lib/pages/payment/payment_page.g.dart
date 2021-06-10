// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class PaymentPageController {
  String get name => PaymentPageProvider.name;

  String get routeName => PaymentPageProvider.routeName;

  WidgetBuilder get routeBuilder => PaymentPageProvider.routeBuilder;

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

class PaymentPageProvider {
  const PaymentPageProvider._();

  static const String name = '购买';

  static const String routeName = '/payment';

  static final WidgetBuilder routeBuilder = (BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return PaymentPage(
      arguments?['paramA'] as String,
      arguments?['paramAA'] as String?,
      arguments?['key'] as Key?,
      arguments?['paramB'] as String?,
      arguments?['paramC'] as String,
      arguments?['paramD'] as String?,
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
      'paramA': paramA,
      'paramAA': paramAA,
      'key': key,
      'paramB': paramB,
      'paramC': paramC,
      'paramD': paramD,
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
        'paramA': paramA,
        'paramAA': paramAA,
        'key': key,
        'paramB': paramB,
        'paramC': paramC,
        'paramD': paramD,
      },
    );
  }
}
