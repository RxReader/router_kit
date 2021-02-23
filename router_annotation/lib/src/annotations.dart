import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef NameFormatter = String Function(String fieldName);
typedef RouteInterceptor = FutureOr<void> Function(
    BuildContext context, String routeName, VoidCallback next);

class Field {
  const Field({
    this.alias,
    this.nullable,
    this.ignore,
  });

  final String alias;
  final bool nullable;
  final bool ignore;
}

class Page {
  const Page({
    @required this.name,
    @required this.routeName,
    this.ignoreKey = true,
    this.autowired = true,
    this.nullableFields = true,
    this.nameFormatter,
    this.interceptors,
  })  : assert(name != null),
        assert(routeName != null);

  final String name;
  final String routeName;
  final bool ignoreKey;
  final bool autowired;
  final bool nullableFields;
  final NameFormatter nameFormatter;
  final List<RouteInterceptor> interceptors;
}

class Manifest {
  const Manifest({
    this.interceptors,
  });

  final List<RouteInterceptor> interceptors;
}
