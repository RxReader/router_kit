import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:router_annotation/router_annotation.dart';

class PageInfo {
  PageInfo({
    @required this.uri,
    @required this.displayName,
    @required this.routeName,
    @required this.fieldInfos,
    @required this.ctorParameters,
    @required this.ctorNamedParameters,
    @required this.nameFormatter,
  });

  final Uri uri;
  final String displayName;
  final String routeName;
  final Map<String, FieldInfo> fieldInfos;
  final List<ParameterElement> ctorParameters;
  final List<ParameterElement> ctorNamedParameters;
  final NameFormatter nameFormatter;

  String get providerDisplayName => '${displayName}Provider';
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
