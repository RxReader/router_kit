import 'package:analyzer/dart/element/element.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:source_gen/source_gen.dart';

class PageInfo {
  const PageInfo({
    required this.displayName,
    required this.name,
    required this.routeName,
    required this.fieldRename,
    required this.constructor,
  });

  final String displayName;
  final String name;
  final String routeName;
  final FieldRename fieldRename;
  final ConstructorElement constructor;

  String get controllerDisplayName => '${displayName}Controller';

  String get providerDisplayName => '${displayName}Provider';

  String convertField(String name) {
    switch (fieldRename) {
      case FieldRename.none:
        return name;
      case FieldRename.kebab:
        return _kebabCase(name);
      case FieldRename.snake:
        return _snakeCase(name);
      case FieldRename.pascal:
        return _pascalCase(name);
      default:
        throw InvalidGenerationSourceError('The provided `fieldRename` ($fieldRename) is not supported.');
    }
  }

  String _kebabCase(String input) => _fixCase(input, '-');

  String _snakeCase(String input) => _fixCase(input, '_');

  String _pascalCase(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  String _fixCase(String input, String separator) {
    return input.replaceAllMapped(RegExp('[A-Z]|[0-9]+'), (Match match) {
      String lower = match.group(0)!.toLowerCase();
      if (match.start > 0) {
        lower = '$separator$lower';
      }
      return lower;
    });
  }
}
