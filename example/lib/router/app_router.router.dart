// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RouterCompilerGenerator
// **************************************************************************

import 'package:flutter/widgets.dart';
import 'package:example/components/home/home_component.dart';
import 'package:example/components/about/about_component.dart';
import 'package:example/components/banner/banner_component.dart';
import 'package:example/components/html/html_component.dart';
import 'package:example/components/login/login_component.dart';
import 'package:example/components/nested_scroll/nested_scroll_component.dart';
import 'package:example/components/not_found/not_found_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';
import 'package:example/components/reader/reader_component.dart';
import 'package:example/components/splash/splash_component.dart';
import 'package:example/components/yunyan/yunyan_component.dart';

class AppRouterProvider {
  const AppRouterProvider._();

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    HomeComponentProvider.routeName: HomeComponentProvider.routeBuilder,
    AboutComponentProvider.routeName: AboutComponentProvider.routeBuilder,
    BannerComponentProvider.routeName: BannerComponentProvider.routeBuilder,
    HtmlComponentProvider.routeName: HtmlComponentProvider.routeBuilder,
    LoginComponentProvider.routeName: LoginComponentProvider.routeBuilder,
    NestedScrollComponentProvider.routeName:
        NestedScrollComponentProvider.routeBuilder,
    NotFoundComponentProvider.routeName: NotFoundComponentProvider.routeBuilder,
    ParamsComponentProvider.routeName: ParamsComponentProvider.routeBuilder,
    PaymentComponentProvider.routeName: PaymentComponentProvider.routeBuilder,
    ReaderComponentProvider.routeName: ReaderComponentProvider.routeBuilder,
    SplashComponentProvider.routeName: SplashComponentProvider.routeBuilder,
    YunyanComponentProvider.routeName: YunyanComponentProvider.routeBuilder,
  };
}
