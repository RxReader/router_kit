import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/utils.dart';
import 'package:source_gen/source_gen.dart';

class PageParser {
  const PageParser._();

  static PageInfo parse(TypeChecker typeChecker, ClassElement element, ConstantReader annotation) {
    if (!element.allSupertypes.map((InterfaceType supertype) => supertype.getDisplayString(withNullability: true)).contains('Widget')) {
      throw InvalidGenerationSourceError('`@$Page` can only be used on Widget classes.', element: element);
    }

    // // 替换其他获取前缀方式
    // final ElementAnnotation ea = element.metadata.firstWhere((ElementAnnotation element) => typeChecker.isAssignableFromType(element.computeConstantValue()!.type!));
    // final ElementAnnotationImpl eai = ea as ElementAnnotationImpl;
    // final String? prefix = eai.annotationAst.atSign.next?.toString();

    final String? name = annotation.peek('name')?.stringValue;
    if (name?.isEmpty ?? true) {
      throw InvalidGenerationSourceError('`@$Page` name can not be null or empty.', element: element);
    }
    final String? routeName = annotation.peek('routeName')?.stringValue;
    if (routeName?.isEmpty ?? true) {
      throw InvalidGenerationSourceError('`@$Page` routeName can not be null or empty.', element: element);
    }
    FieldRename? _fromDartObject(ConstantReader reader) {
      return reader.isNull ? null : enumValueForDartObject(reader.objectValue, FieldRename.values);
    }

    final FieldRename fieldRename = _fromDartObject(annotation.read('fieldRename')) ?? FieldRename.snake;

    final ConstructorElement? constructor = element.unnamedConstructor;
    if (constructor == null) {
      throw InvalidGenerationSourceError('`@$Page` does not have a default constructor!', element: element);
    }

    return PageInfo(
      displayName: element.displayName,
      name: name!,
      routeName: routeName!,
      fieldRename: fieldRename,
      constructor: constructor,
    );
  }
}
