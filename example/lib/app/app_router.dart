import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/home/home_page.dart';
import 'package:example/pages/login/login_page.dart';
import 'package:example/pages/not_found/not_found_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:flutter/foundation.dart';
import 'package:router_api/router_api.dart' as ra;

mixin Manifest on ra.Router {
  @override
  @protected
  void registerBuiltIn() {
    useRoute(name: HomePageController.name, routeName: HomePageController.routeName, routeBuilder: HomePageController.routeBuilder);
    useRoute(name: AboutPageController.name, routeName: AboutPageController.routeName, routeBuilder: AboutPageController.routeBuilder);
    useRoute(name: LoginPageController.name, routeName: LoginPageController.routeName, routeBuilder: LoginPageController.routeBuilder);
    useRoute(name: NotFoundPageController.name, routeName: NotFoundPageController.routeName, routeBuilder: NotFoundPageController.routeBuilder);
    useRoute(name: ParamsPageController.name, routeName: ParamsPageController.routeName, routeBuilder: ParamsPageController.routeBuilder);
    useRoute(name: PaymentPageController.name, routeName: PaymentPageController.routeName, routeBuilder: PaymentPageController.routeBuilder);
  }
}

class AppRouter extends ra.Router with Manifest {
  AppRouter._() : super();

  static AppRouter get instance => _instance ??= AppRouter._();
  static AppRouter? _instance;
}
