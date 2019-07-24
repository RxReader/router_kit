import 'package:meta/meta.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

class Component {
  const Component({
    @required this.routeName,
    this.autowired = true,
    this.nullableFields = true,
    this.fields = const <String, Field>{},
    this.ignore = const <String>[],
    this.nameFormatter,
  }) : assert(routeName != null);

  final String routeName;
  final bool autowired;
  final bool nullableFields;
  final Map<String, Field> fields;
  final List<String> ignore;
  final NameFormatter nameFormatter;
}
