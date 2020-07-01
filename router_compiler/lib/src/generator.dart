import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/util/exceptions.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:router_compiler/src/writer/router_writer.dart';
import 'package:source_gen/source_gen.dart';

final Logger _log = Logger('RouterCompiler');

class PageCompilerGenerator extends GeneratorForAnnotation<Page> {
  PageCompilerGenerator(this.infoMap);

  final Map<String, PageInfo> infoMap;

  static const String _onlyClassMsg = 'Page annotation can only be defined on a class.';

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw RouterCompilerException(_onlyClassMsg);
    }

    try {
      PageInfo info = PageParser.parse(element as ClassElement, annotation, buildStep);
      infoMap[info.routeName] = info;
      _log.info('${info.routeName}-${info.displayName};');

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

class RouterCompilerGenerator extends GeneratorForAnnotation<Router> {
  RouterCompilerGenerator(this.infoMap);

  final Map<String, PageInfo> infoMap;

  static const String _onlyClassMsg = 'Router annotation can only be defined on a class.';

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw RouterCompilerException(_onlyClassMsg);
    }
    _log.info(infoMap.values.map((PageInfo e) => '${e.routeName}-${e.displayName}').join('; '));

    try {
      RouterWriter writer = RouterWriter(element as ClassElement, infoMap);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

final Map<String, PageInfo> infoMap = <String, PageInfo>{};

Builder pageCompilerBuilder({String header}) => PartBuilder(
  <Generator>[
    PageCompilerGenerator(infoMap),
  ],
  '.g.dart',
  header: header,
);

Builder routerCompilerBuilder({String header}) => LibraryBuilder(
  RouterCompilerGenerator(infoMap),
  generatedExtension: '.r.g.dart',
  header: header,
);
