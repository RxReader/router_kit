// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_page.dart';

// **************************************************************************
// PageCompilerGenerator
// **************************************************************************

class PaymentPageProvider {
  const PaymentPageProvider._();

  static const String name = '购买';

  static const String routeName = '/payment';

  static WidgetBuilder routeBuilder = (BuildContext context) {
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
}

class PaymentPageNavigator {
  const PaymentPageNavigator._();

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
}
