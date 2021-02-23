import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/manifest_parser.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/util/exceptions.dart';
import 'package:router_compiler/src/writer/manifest_writer.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:source_gen/source_gen.dart';

class PageCompilerGenerator extends GeneratorForAnnotation<Page> {
  PageCompilerGenerator(this.infoMap);

  final Map<String, PageInfo> infoMap;

  final Logger _log = Logger('PageCompiler');

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw RouterCompilerException(
          'Page annotation can only be defined on a class.');
    }

    try {
      PageInfo info =
          PageParser.parse(element as ClassElement, annotation, buildStep);
      infoMap[info.routeName] = info;
      _log.info(
          '${info.displayName}{name: ${info.name}, routeName: ${info.routeName}}');

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

class ManifestCompilerGenerator extends GeneratorForAnnotation<Manifest> {
  ManifestCompilerGenerator(this.infoMap);

  final Map<String, PageInfo> infoMap;

  final Logger _log = Logger('ManifestCompiler');

  int _count = 0;

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw RouterCompilerException(
          'Manifest annotation can only be defined on a class.');
    }

    if (_count > 0) {
      throw RouterCompilerException(
          'Manifest annotation can only be defined once.');
    }

    _count++;

    _log.info('\n'
        '******************** ${_log.name} ********************\n'
        'Manifest Compiler 暂不支持增量更新\n'
        '如果需要添加/删除/更新路由信息，请先执行清除命令：\n'
        'flutter pub run build_runner clean\n'
        '然后执行下列命令重新生成相应文件：\n'
        'flutter pub run build_runner build --delete-conflicting-outputs\n'
        '******************** ${_log.name} ********************');

    try {
      ManifestParser.parse(element as ClassElement, annotation, buildStep);

      ManifestWriter writer = ManifestWriter(element as ClassElement, infoMap);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

const Map<String, PageInfo> infoMap = <String, PageInfo>{};

Builder pageCompilerBuilder({Map<String, dynamic> config}) => SharedPartBuilder(
      <Generator>[
        PageCompilerGenerator(infoMap),
      ],
      'page_compiler',
    );

Builder manifestCompilerBuilder({Map<String, dynamic> config}) =>
    LibraryBuilder(
      ManifestCompilerGenerator(infoMap),
      generatedExtension: '.manifest.g.dart',
    );
