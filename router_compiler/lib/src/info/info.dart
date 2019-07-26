import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:router_annotation/router_annotation.dart';

class SerializerInfo {
  SerializerInfo({
    @required this.displayName,
    @required this.importUri,
    @required this.routeName,
    @required this.fieldInfos,
    @required this.ctorParameters,
    @required this.ctorNamedParameters,
    this.nameFormatter,
  });

  final String displayName;
  final Uri importUri;
  final String routeName;
  final Map<String, FieldInfo> fieldInfos;
  final List<ParameterElement> ctorParameters;
  final List<ParameterElement> ctorNamedParameters;
  final NameFormatter nameFormatter;

  String get clazzRouteName => '${displayName}Route';
}

class FieldInfo {
  FieldInfo({
    @required this.name,
    @required this.type,
    @required this.alias,
    @required this.nullable,
    @required this.ignore,
    this.isFinal = false,
  });

  final String name;
  final DartType type;
  final String alias;
  final bool nullable;
  final bool ignore;
  final bool isFinal;
}
