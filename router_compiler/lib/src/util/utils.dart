import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

T enumValueForDartObject<T>(
  DartObject source,
  List<T> items,
  String Function(T) name,
) {
  return items.singleWhere((T element) => source.getField(name(element)) != null);
}

String formatPrettyDisplay(DartType type) {
  if (type is FunctionType) {
    final StringBuffer display = StringBuffer()
      ..write(type.returnType.getDisplayString(withNullability: false))..write(' Function(')..write(<String>[
        if (type.parameters.any((ParameterElement element) => !element.isNamed && !element.isOptional))
          type.parameters
              .where((ParameterElement element) => !element.isNamed && !element.isOptional)
              .map((ParameterElement element) => '${element.type.getDisplayString(withNullability: false)} ${element.name}').join(', '),
        if (type.parameters.any((ParameterElement element) => !element.isNamed && element.isOptional))
          '[${type.parameters
              .where((ParameterElement element) => !element.isNamed && element.isOptional)
              .map((ParameterElement element) => '${element.type.getDisplayString(withNullability: false)} ${element.name}').join(', ')}]',
        if (type.parameters.any((ParameterElement element) => element.isNamed))
          '{${type.parameters
              .where((ParameterElement element) => element.isNamed)
              .map((ParameterElement element) => '${element.type.getDisplayString(withNullability: false)} ${element.name}').join(', ')}}',
      ].join(', '))..write(')');
    return display.toString();
  }
  return type.getDisplayString(withNullability: false);
}
