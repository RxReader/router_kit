import 'package:meta/meta.dart';

typedef String NameFormatter(String fieldName);

class Component {
  const Component({
    @required this.routeName,
    this.autowired = true,
    this.nullableFields = true,
    this.nameFormatter,
  }) : assert(routeName != null);

  final String routeName;
  final bool autowired;
  final bool nullableFields;
  final NameFormatter nameFormatter;
}

class Field {
  final bool isNullable;

  Field({
    this.isNullable,
  });
}

class Alias implements Field {
  const Alias({
    this.name,
    this.isNullable,
  });

  final String name;
  final bool isNullable;
}

class Ignore implements Field {
  const Ignore() : isNullable = null;
  final bool isNullable;
}
