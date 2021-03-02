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
    this.nullable = true,
    this.fieldRename,
    this.interceptors,
  })  : assert(name != null),
        assert(routeName != null);

  final String name;
  final String routeName;
  final bool nullable;
  final FieldRename fieldRename;
  final List<RouteInterceptor> interceptors;
}

class Field {
  const Field({
    this.name,
    this.nullable,
    this.ignore,
  });

  final String name;
  final bool nullable;
  final bool ignore;
}
