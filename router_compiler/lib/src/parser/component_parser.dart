import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/exceptions.dart';
import 'package:source_gen/source_gen.dart';

class ComponentParser {
  ComponentParser._();

  static ComponentInfo parse(ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    if (!element.allSupertypes
        .map((InterfaceType supertype) => supertype.displayName)
        .contains('Widget')) {
      throw RouterCompilerException(
          'Component annotation can only be defined on a Widget class.');
    }

    String routeName = annotation.peek('routeName').stringValue;
    bool ignoreKey = annotation.peek('ignoreKey').boolValue;
    bool autowired = annotation.peek('autowired').boolValue;
    bool nullableFields = annotation.peek('nullableFields').boolValue;

    final Map<String, FieldInfo> fieldInfos = <String, FieldInfo>{};
    _parseModelType(element, ignoreKey, autowired, nullableFields, fieldInfos);
//    for (FieldInfo fieldInfo in fieldInfos.values) {
//      print('${fieldInfo.name} - ${fieldInfo.alias} - ${fieldInfo.ignore}');
//    }

    final List<ParameterElement> ctorParameters = <ParameterElement>[];
    final List<ParameterElement> ctorNamedParameters = <ParameterElement>[];
    _makeCtor(element, ctorParameters, ctorNamedParameters);

    NameFormatter nameFormatter =
        _parseFieldFormatter(annotation.peek('nameFormatter')) ?? toSnakeCase;

    return ComponentInfo(
      displayName: element.displayName,
      routeName: routeName,
      fieldInfos: fieldInfos,
      ctorParameters: ctorParameters,
      ctorNamedParameters: ctorNamedParameters,
      nameFormatter: nameFormatter,
    );
  }

  static void _parseModelType(
    ClassElement element,
    bool ignoreKey,
    bool autowired,
    bool nullableFields,
    Map<String, FieldInfo> fieldInfos,
  ) {
    bool isNotStaticOrPrivate(FieldElement e) => !e.isStatic && !e.isPrivate;
    List<FieldElement> fields = <FieldElement>[];
    fields.addAll(element.fields.where(isNotStaticOrPrivate));
    for (InterfaceType supertype in element.allSupertypes) {
      fields.addAll(supertype.element.fields.where(isNotStaticOrPrivate));
    }
    for (FieldElement field in fields) {
      String name = field.displayName;
      if (name == 'hashCode') {
        continue;
      }
      if (name == 'runtimeType') {
        continue;
      }
      if (fieldInfos.containsKey(name)) {
        continue;
      }

      DartType type = field.type;
      String alias = name;
      bool nullable = nullableFields;
      bool ignore = ignoreKey && name == 'key';
      bool isFinal = field.isFinal;

      DartObject annotation = field.metadata
          .firstWhere(
            (ElementAnnotation annotation) => TypeChecker.fromRuntime(Field)
                .isAssignableFromType(annotation.computeConstantValue().type),
            orElse: () => null,
          )
          ?.constantValue;

      if (annotation != null) {
        alias = annotation.getField('alias')?.toStringValue() ?? alias;
        nullable = annotation.getField('nullable').toBoolValue() ?? nullable;
        ignore = annotation.getField('ignore').toBoolValue() ?? ignore;
      }

      if (autowired || annotation != null) {
        fieldInfos[name] = FieldInfo(
          name: name,
          type: type,
          alias: alias,
          nullable: nullable,
          ignore: ignore,
          isFinal: isFinal,
        );
      }
    }
  }

  static void _makeCtor(
    ClassElement element,
    List<ParameterElement> ctorArguments,
    List<ParameterElement> ctorNamedArguments,
  ) {
    ConstructorElement ctor = element.unnamedConstructor;
    if (ctor == null) {
      throw RouterCompilerException(
          'Model does not have a default constructor!');
    }
    for (ParameterElement parameter in ctor.parameters) {
      if (parameter.isNotOptional) {
        ctorArguments.add(parameter);
      } else if (parameter.isNamed) {
        ctorNamedArguments.add(parameter);
      }
    }
  }

  static NameFormatter _parseFieldFormatter(ConstantReader annotation) {
    if (annotation == null || annotation.isNull) {
      return null;
    }
    NameFormatter nameFormatter;
    Uri uri = annotation.revive().source;
    String accessor = annotation.revive().accessor;
    if (uri.pathSegments.isNotEmpty ||
        uri.pathSegments.first == 'router_annotation') {
      switch (accessor) {
        case 'toCamelCase':
          nameFormatter = toCamelCase;
          break;
        case 'toSnakeCase':
          nameFormatter = toSnakeCase;
          break;
        case 'toKebabCase':
          nameFormatter = toKebabCase;
          break;
        case 'onlyFirstChar':
          nameFormatter = onlyFirstChar;
          break;
        case 'onlyFirstCharInCaps':
          nameFormatter = onlyFirstCharInCaps;
          break;
        case 'onlyFirstCharInLower':
          nameFormatter = onlyFirstCharInLower;
          break;
        case 'withFirstCharInCaps':
          nameFormatter = withFirstCharInCaps;
          break;
        case 'withFirstCharInLower':
          nameFormatter = withFirstCharInLower;
          break;
      }
    }
    return nameFormatter;
  }
}
