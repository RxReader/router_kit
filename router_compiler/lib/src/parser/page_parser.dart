import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/utils.dart';
import 'package:source_gen/source_gen.dart';

class PageParser {
  const PageParser._();

  static PageInfo parse(TypeChecker typeChecker, ClassElement element,
      ConstantReader annotation, BuildStep buildStep,
      {required bool withNullability}) {
    if (!element.allSupertypes
        .map((InterfaceType supertype) =>
            supertype.getDisplayString(withNullability: withNullability))
        .contains('Widget')) {
      throw InvalidGenerationSourceError(
          '`@$Page` can only be used on Widget classes.',
          element: element);
    }

    final String? name = annotation.peek('name')?.stringValue;
    if (name?.isEmpty ?? true) {
      throw InvalidGenerationSourceError(
          '`@$Page` name can not be null or empty.',
          element: element);
    }
    final String? routeName = annotation.peek('routeName')?.stringValue;
    if (routeName?.isEmpty ?? true) {
      throw InvalidGenerationSourceError(
          '`@$Page` routeName can not be null or empty.',
          element: element);
    }
    FieldRename? _fromDartObject(ConstantReader reader) {
      return reader.isNull
          ? null
          : enumValueForDartObject(reader.objectValue, FieldRename.values);
    }

    final FieldRename fieldRename =
        _fromDartObject(annotation.read('fieldRename')) ?? FieldRename.snake;

    final ConstructorElement? constructor = element.unnamedConstructor;
    if (constructor == null) {
      throw InvalidGenerationSourceError(
          '`@$Page` does not have a default constructor!',
          element: element);
    }

    final String? flavor = annotation.peek('flavor')?.stringValue;

    return PageInfo(
      uri: buildStep.inputId.uri,
      displayName: element.displayName,
      name: name!,
      routeName: routeName!,
      fieldRename: fieldRename,
      constructor: constructor,
      flavor: flavor,
    );
  }
}
