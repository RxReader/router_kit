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
    String routeName = annotation.peek('routeName').stringValue;
    bool nullable = annotation.peek('nullable')?.boolValue ?? true;
    FieldRename _fromDartObject(ConstantReader reader) {
      return reader.isNull
          ? null
          : enumValueForDartObject(
              reader.objectValue,
              FieldRename.values,
              (FieldRename element) => element.toString().split('.')[1],
            );
    }

    FieldRename fieldRename = _fromDartObject(annotation.read('fieldRename'));
    ConstantReader interceptors = annotation.peek('interceptors');

    return PageInfo(
      uri: buildStep.inputId.uri,
      displayName: element.displayName,
      name: name,
      routeName: routeName,
      nullable: nullable,
      fieldRename: fieldRename,
      interceptors: interceptors?.listValue?.map((DartObject element) {
        return element.toFunctionValue();
      })?.toList(),
    );
  }

// static void _parseModelType(
//   ClassElement element,
//   bool ignoreKey,
//   bool autowired,
//   bool nullableFields,
//   Map<String, FieldInfo> fieldInfos,
// ) {
//   bool isNotStaticOrPrivate(FieldElement e) => !e.isStatic && !e.isPrivate;
//   List<FieldElement> fields = <FieldElement>[];
//   fields.addAll(element.fields.where(isNotStaticOrPrivate));
//   for (InterfaceType supertype in element.allSupertypes) {
//     fields.addAll(supertype.element.fields.where(isNotStaticOrPrivate));
//   }
//   for (FieldElement field in fields) {
//     String name = field.displayName;
//     if (name == 'hashCode') {
//       continue;
//     }
//     if (name == 'runtimeType') {
//       continue;
//     }
//     if (fieldInfos.containsKey(name)) {
//       continue;
//     }
//
//     DartType type = field.type;
//     String alias = name;
//     bool nullable = nullableFields;
//     bool ignore = ignoreKey && name == 'key';
//     bool isFinal = field.isFinal;
//
//     DartObject annotation = field.metadata
//         .firstWhere(
//           (ElementAnnotation annotation) => const TypeChecker.fromRuntime(Field).isAssignableFromType(annotation.computeConstantValue().type),
//           orElse: () => null,
//         )
//         ?.computeConstantValue();
//
//     if (annotation != null) {
//       alias = annotation.getField('alias')?.toStringValue() ?? alias;
//       nullable = annotation.getField('nullable')?.toBoolValue() ?? nullable;
//       ignore = annotation.getField('ignore')?.toBoolValue() ?? ignore;
//     }
//
//     if (autowired || annotation != null) {
//       fieldInfos[name] = FieldInfo(
//         name: name,
//         type: type,
//         alias: alias,
//         nullable: nullable,
//         ignore: ignore,
//         isFinal: isFinal,
//       );
//     }
//   }
// }
}
