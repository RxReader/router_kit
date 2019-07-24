import 'package:example/components/about/about_component.dart';
import 'package:example/components/home/home_component.dart';
import 'package:example/components/login/login_component.dart';
import 'package:example/components/not_found/not_found_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';
import 'package:flutter/widgets.dart';

part 'params/params_route.dart';

/// TODO 注解自动生成

class AppNavigator {
  AppNavigator._();

  static const String login = '/login';
  static const String payment = '/payment';
  static const String params = '/params';
  static const String about = '/about';
  static const String notFound = '/not_found';

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    Navigator.defaultRouteName: (BuildContext context) => HomeComponent(),
    login: (BuildContext context) => LoginComponent(),
    payment: (BuildContext context) => PaymentComponent(),
    params: ParamsRoute.route,
    about: (BuildContext context) => AboutComponent(),
    notFound: (BuildContext context) => NotFoundComponent(),
  };
}