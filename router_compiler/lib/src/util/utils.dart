import 'package:analyzer/dart/constant/value.dart';

T enumValueForDartObject<T>(
  DartObject source,
  List<T> items,
  String Function(T) name,
) {
  return items.singleWhere((T element) => source.getField(name(element)) != null);
}
