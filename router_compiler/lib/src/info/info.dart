import 'package:analyzer/dart/element/element.dart';
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

  String get manifestDisplayName => '${displayName}Manifest';

  String get providerDisplayName => '${displayName}Provider';

  String get navigatorDisplayName => '${displayName}Navigator';
}

class PageInfo {
  const PageInfo({
    @required this.uri,
    @required this.displayName,
    @required this.name,
    @required this.routeName,
    @required this.fieldMap,
    @required this.fieldRename,
    @required this.interceptors,
    @required this.constructor,
  });

  final Uri uri;
  final String displayName;
  final String name;
  final String routeName;
  final Map<String, String> fieldMap;
  final FieldRename fieldRename;
  final List<ExecutableElement> interceptors;
  final ConstructorElement constructor;

  String get providerDisplayName => '${displayName}Provider';

  String get navigatorDisplayName => '${displayName}Navigator';

  String convertField(String name) {
    if (fieldMap?.containsKey(name) ?? false) {
      return fieldMap[name];
    }
    // TODO
    return name;
  }
}
