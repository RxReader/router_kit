import 'dart:async';

import 'package:meta/meta.dart';

enum FieldRename {
  none,
  kebab,
  snake,
  pascal,
}

typedef RouteInterceptor = Future<dynamic> Function(
    dynamic /* BuildContext */ context, String routeName,
    {Object arguments, Future<dynamic> Function() next});

class Manifest {
  const Manifest({
    this.interceptors,
  });

  final List<RouteInterceptor> interceptors;
}

class Page {
  const Page({
    @required this.name,
    @required this.routeName,
    this.fieldMap,
    this.fieldRename = FieldRename.snake,
    this.interceptors,
  })  : assert(name != null),
        assert(routeName != null);

  final String name;
  final String routeName;
  final Map<String, String> fieldMap;
  final FieldRename fieldRename;
  final List<RouteInterceptor> interceptors;
}
