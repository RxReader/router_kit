import 'package:meta/meta.dart';

typedef NameFormatter = String Function(String fieldName);

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

abstract class Field {
  const Field({
    this.alias,
    this.nullable,
    this.ignore,
  });

  final String alias;
  final bool nullable;
  final bool ignore;
}

class Alias extends Field {
  const Alias(
    String alias, {
    bool nullable,
  }) : super(alias: alias, nullable: nullable, ignore: false);
}

class Ignore extends Field {
  const Ignore() : super(alias: null, nullable: null, ignore: true);
}
