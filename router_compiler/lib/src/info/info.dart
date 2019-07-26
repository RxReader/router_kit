import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:router_annotation/router_annotation.dart';

class SerializerInfo {
  SerializerInfo({
    this.name,
    this.fieldInfos,
    this.ctorParameters,
    this.ctorNamedParameters,
    this.nameFormatter,
  });

  final String name;
  final Map<String, FieldInfo> fieldInfos;
  final List<ParameterElement> ctorParameters;
  final List<ParameterElement> ctorNamedParameters;
  final NameFormatter nameFormatter;
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
