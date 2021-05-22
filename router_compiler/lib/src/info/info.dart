import 'package:analyzer/dart/element/element.dart';
import 'package:router_annotation/router_annotation.dart';

class PageInfo {
  const PageInfo({
    required this.uri,
    required this.displayName,
    required this.name,
    required this.routeName,
    required this.fieldRename,
    required this.constructor,
  });

  final Uri uri;
  final String displayName;
  final String name;
  final String routeName;
  final FieldRename fieldRename;
  final ConstructorElement constructor;

  String get controllerDisplayName => '${displayName}Controller';

  String convertField(String name) {
    // TODO
    return name;
  }
}
