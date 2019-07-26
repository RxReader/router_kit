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
    this.encodeTo,
    this.decodeFrom,
    this.isNullable,
    this.dontEncode = false,
    this.dontDecode = false,
  });

  final String encodeTo;
  final String decodeFrom;
  final bool isNullable;
  final bool dontEncode;
  final bool dontDecode;

  const Field.encode({String alias, this.isNullable})
      : encodeTo = alias,
        dontEncode = false,
        decodeFrom = null,
        dontDecode = true;

  const Field.decode({String alias, this.isNullable})
      : decodeFrom = alias,
        dontEncode = true,
        encodeTo = null,
        dontDecode = false;

  const Field.ignore()
      : encodeTo = null,
        decodeFrom = null,
        isNullable = null,
        dontEncode = true,
        dontDecode = true;
}
