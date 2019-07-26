import 'package:meta/meta.dart';

typedef String NameFormatter(String fieldName);

class Router {
  const Router();
}

class Component {
  const Component({
    @required this.routeName,
    this.ignoreKey = true,
    this.autowired = true,
    this.nullableFields = true,
    this.nameFormatter,
  }) : assert(routeName != null);

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

class Alias implements Field {
  const Alias(
    this.alias, {
    this.nullable,
  }) : ignore = false;

  final String alias;
  final bool nullable;
  final bool ignore;
}

class Ignore implements Field {
  const Ignore()
      : alias = null,
        nullable = null,
        ignore = true;

  final String alias;
  final bool nullable;
  final bool ignore;
}
