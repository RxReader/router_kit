// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RouterCompilerGenerator
// **************************************************************************

import 'package:flutter/widgets.dart';
import 'package:example/components/home/home_component.dart';
import 'package:example/components/about/about_component.dart';
import 'package:example/components/login/login_component.dart';
import 'package:example/components/not_found/not_found_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';

class AppRouterProvider {
  const AppRouterProvider._();

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    HomeComponentProvider.routeName: HomeComponentProvider.routeBuilder,
    AboutComponentProvider.routeName: AboutComponentProvider.routeBuilder,
    LoginComponentProvider.routeName: LoginComponentProvider.routeBuilder,
    NotFoundComponentProvider.routeName: NotFoundComponentProvider.routeBuilder,
    ParamsComponentProvider.routeName: ParamsComponentProvider.routeBuilder,
    PaymentComponentProvider.routeName: PaymentComponentProvider.routeBuilder,
  };
}
