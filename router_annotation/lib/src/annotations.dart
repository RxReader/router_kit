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

abstract class Field {}

class Alias implements Field {
  const Alias({this.name});

  final String name;
}

class Ignore implements Field {
  const Ignore();
}
