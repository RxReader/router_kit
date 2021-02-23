import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class ManifestParser {
  const ManifestParser._();

  static void parse(ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    ConstantReader interceptors = annotation.peek('interceptors');
    print('interceptors: $interceptors');
  }
}
