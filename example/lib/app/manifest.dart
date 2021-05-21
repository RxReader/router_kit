import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/home/home_page.dart';
import 'package:example/pages/login/login_page.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:flutter/cupertino.dart';

class Manifest {
  Manifest._();

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    HomePageProvider.routeName : HomePageProvider.routeBuilder,
    AboutPageProvider.routeName : AboutPageProvider.routeBuilder,
    LoginPageProvider.routeName : LoginPageProvider.routeBuilder,
    NotFoundPageProvider.routeName : NotFoundPageProvider.routeBuilder,
    ParamsPageProvider.routeName : ParamsPageProvider.routeBuilder,
    PaymentPageProvider.routeName : PaymentPageProvider.routeBuilder,
  };
}