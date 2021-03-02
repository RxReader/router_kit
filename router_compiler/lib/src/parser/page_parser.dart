import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/utils.dart';
import 'package:source_gen/source_gen.dart';

class PageParser {
  const PageParser._();

  static PageInfo parse(ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    if (!element.allSupertypes.map((InterfaceType supertype) => supertype.getDisplayString(withNullability: false)).contains('Widget')) {
      throw InvalidGenerationSourceError('`@$Page` can only be used on Widget classes.', element: element);
    }

    String name = annotation.peek('name').stringValue;
    if (name?.isEmpty ?? true) {
      throw InvalidGenerationSourceError('`@$Page` name can not be null or empty.', element: element);
    }
    String routeName = annotation.peek('routeName').stringValue;
    if (routeName?.isEmpty ?? true) {
      throw InvalidGenerationSourceError('`@$Page` routeName can not be null or empty.', element: element);
    }
    Map<String, String> fieldMap = annotation.peek('fieldMap')?.mapValue?.map<String, String>((DartObject key, DartObject value) {
      return MapEntry<String, String>(key.toStringValue(), value.toStringValue());
    });
    FieldRename _fromDartObject(ConstantReader reader) {
      return reader.isNull
          ? null
          : enumValueForDartObject(
              reader.objectValue,
              FieldRename.values,
              (FieldRename element) => element.toString().split('.')[1],
            );
    }

    FieldRename fieldRename = _fromDartObject(annotation.read('fieldRename')) ?? FieldRename.snake;
    ConstantReader interceptors = annotation.peek('interceptors');

    ConstructorElement constructor = element.unnamedConstructor;
    if (constructor == null) {
      throw InvalidGenerationSourceError('`@$Page` does not have a default constructor!', element: element);
    }

    return PageInfo(
      uri: buildStep.inputId.uri,
      displayName: element.displayName,
      name: name,
      routeName: routeName,
      fieldMap: fieldMap,
      fieldRename: fieldRename,
      interceptors: interceptors?.listValue?.map((DartObject element) {
        return element.toFunctionValue();
      })?.toList(),
      constructor: constructor,
    );
  }
}
