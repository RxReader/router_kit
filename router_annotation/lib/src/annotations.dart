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
  Field({
    this.isNullable,
    this.dontEncode = false,
    this.dontDecode = false,
  });

  final bool isNullable;
  final bool dontEncode;
  final bool dontDecode;
}

class Alias implements Field {
  const Alias({
    @required this.name,
    this.isNullable,
    this.dontEncode = false,
    this.dontDecode = false,
  }) : assert(name != null);

  final String name;
  final bool isNullable;
  final bool dontEncode;
  final bool dontDecode;
}

class Ignore implements Field {
  const Ignore()
      : isNullable = null,
        dontEncode = true,
        dontDecode = true;
  final bool isNullable;
  final bool dontEncode;
  final bool dontDecode;
}
