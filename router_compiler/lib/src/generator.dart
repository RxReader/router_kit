import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/util/exceptions.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:source_gen/source_gen.dart';

final Logger _log = Logger('RouterCompiler');

class RouterCompilerGenerator extends GeneratorForAnnotation<Page> {
  RouterCompilerGenerator();

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw RouterCompilerException('Page annotation can only be defined on a class.');
    }

    try {
      PageInfo info = PageParser.parse(element as ClassElement, annotation, buildStep);
      _log.info('${info.displayName}{name: ${info.name}, routeName: ${info.routeName}}');

      PageWriter writer = PageWriter(info);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

Builder routerCompilerBuilder({Map<String, dynamic> config}) => SharedPartBuilder(
      <Generator>[
        RouterCompilerGenerator(),
      ],
      'router_compiler',
    );
