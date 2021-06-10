import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:source_gen/source_gen.dart';

class PageCompilerGenerator extends GeneratorForAnnotation<Page> {
  PageCompilerGenerator();

  final Logger _log = Logger('PageCompiler');

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '`@$Page` can only be used on classes.',
          element: element);
    }

    try {
      final bool withNullability = element.library.isNonNullableByDefault;
      final PageInfo info = PageParser.parse(typeChecker, element, annotation,
          withNullability: withNullability);
      _log.info(
          '${info.displayName}{name: ${info.name}, routeName: ${info.routeName}}');
      final PageWriter writer = PageWriter(info);
      writer.generate(withNullability: withNullability);
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

Builder routerCompilerBuilder({required Map<String, dynamic> config}) =>
    SharedPartBuilder(
      <Generator>[
        PageCompilerGenerator(),
      ],
      'router_compiler',
    );
