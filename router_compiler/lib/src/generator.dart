import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/component_parser.dart';
import 'package:router_compiler/src/util/exceptions.dart';
import 'package:router_compiler/src/writer/component_writer.dart';
import 'package:router_compiler/src/writer/router_writer.dart';
import 'package:source_gen/source_gen.dart';

final Logger _log = Logger("RouterCompiler");

class ComponentCompilerGenerator extends GeneratorForAnnotation<Component> {
  ComponentCompilerGenerator(this.infoMap);

  final Map<String, ComponentInfo> infoMap;

  static const String _onlyClassMsg =
      "Component annotation can only be defined on a class.";

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) throw RouterCompilerException(_onlyClassMsg);

    try {
      ComponentInfo info =
          ComponentParser.parse(element as ClassElement, annotation, buildStep);
      infoMap[info.routeName] = info;

      ComponentWriter writer = ComponentWriter(info);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return "// $e \n\n";
    }
  }
}

class RouterCompilerGenerator extends GeneratorForAnnotation<Router> {
  RouterCompilerGenerator(this.infoMap);

  final Map<String, ComponentInfo> infoMap;

  static const String _onlyClassMsg =
      "Router annotation can only be defined on a class.";

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) throw RouterCompilerException(_onlyClassMsg);

    try {
      RouterWriter writer = RouterWriter(element, infoMap);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return "// $e \n\n";
    }
  }
}

final Map<String, ComponentInfo> infoMap = <String, ComponentInfo>{};

Builder componentCompilerBuilder({String header}) => PartBuilder(
      <Generator>[
        ComponentCompilerGenerator(infoMap),
      ],
      '.component.dart',
      header: header,
    );

Builder routerCompilerBuilder({String header}) => LibraryBuilder(
      RouterCompilerGenerator(infoMap),
      generatedExtension: '.router.dart',
      header: header,
    );
