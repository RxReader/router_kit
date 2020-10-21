import 'package:meta/meta.dart';

typedef NameFormatter = String Function(String fieldName);

class Manifest {
  const Manifest();
}

class Page {
  const Page({
    @required this.name,
    @required this.routeName,
    this.ignoreKey = true,
    this.autowired = true,
    this.nullableFields = true,
    this.nameFormatter,
  }) : assert(routeName != null);

  final String name;
  final String routeName;
  final bool ignoreKey;
  final bool autowired;
  final bool nullableFields;
  final NameFormatter nameFormatter;
}

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
