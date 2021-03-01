import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:router_annotation/router_annotation.dart';

class ManifestInfo {
  const ManifestInfo({
    @required this.uri,
    @required this.displayName,
    @required this.interceptors,
  });

  final Uri uri;
  final String displayName;
  final List<ExecutableElement> interceptors;

  String get providerDisplayName => '${displayName}Provider';
}

class PageInfo {
  const PageInfo({
    @required this.uri,
    @required this.displayName,
    @required this.name,
    @required this.routeName,
    @required this.fieldInfos,
    @required this.ctorParameters,
    @required this.ctorNamedParameters,
    @required this.nameFormatter,
    @required this.interceptors,
  });

  final Uri uri;
  final String displayName;
  final String name;
  final String routeName;
  final Map<String, FieldInfo> fieldInfos;
  final List<ParameterElement> ctorParameters;
  final List<ParameterElement> ctorNamedParameters;
  final NameFormatter nameFormatter;
  final List<ExecutableElement> interceptors;

  String get providerDisplayName => '${displayName}Provider';
}

class FieldInfo {
  const FieldInfo({
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
