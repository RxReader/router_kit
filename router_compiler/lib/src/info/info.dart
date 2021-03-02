import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:router_annotation/router_annotation.dart';

class ManifestInfo {
  const ManifestInfo({
    @required this.displayName,
    @required this.interceptors,
  });

  final String displayName;
  final List<ExecutableElement> interceptors;

  String get manifestDisplayName => '${displayName}Manifest';

  String get providerDisplayName => '${displayName}Provider';

  String get routerDisplayName => '${displayName}Router';
}

class PageInfo {
  const PageInfo({
    @required this.uri,
    @required this.displayName,
    @required this.name,
    @required this.routeName,
    @required this.nullable,
    @required this.fieldRename,
    @required this.interceptors,
  });

  final Uri uri;
  final String displayName;
  final String name;
  final String routeName;
  final bool nullable;
  final FieldRename fieldRename;
  final List<ExecutableElement> interceptors;

  String get providerDisplayName => '${displayName}Provider';

  String get routerDisplayName => '${displayName}Router';
}
