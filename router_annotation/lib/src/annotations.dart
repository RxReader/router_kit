import 'dart:async';

enum FieldRename {
  none,
  kebab,
  snake,
  pascal,
}

typedef RouteInterceptor = Future<dynamic> Function(
    dynamic /* BuildContext */ context, String routeName,
    {Object? arguments, Future<dynamic> Function()? next});

class Manifest {
  const Manifest({
    this.interceptors,
  });

  final List<RouteInterceptor>? interceptors;
}

class Page {
  const Page({
    required this.name,
    required this.routeName,
    this.fieldRename = FieldRename.snake,
    this.interceptors,
  });

  final String name;
  final String routeName;
  final FieldRename fieldRename;
  final List<RouteInterceptor>? interceptors;
}
