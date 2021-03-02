import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:source_gen/source_gen.dart';

class ManifestParser {
  const ManifestParser._();

  static ManifestInfo parse(ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    ConstantReader interceptors = annotation.peek('interceptors');
    return ManifestInfo(
      displayName: element.displayName,
      interceptors: interceptors?.listValue?.map((DartObject element) {
        return element.toFunctionValue();
      })?.toList(),
    );
  }
}
