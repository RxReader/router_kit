import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/writer/manifest_writer.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:source_gen/source_gen.dart';

class PageCompilerGenerator extends GeneratorForAnnotation<Page> {
  PageCompilerGenerator(this.infos);

  final List<PageInfo> infos;

  final Logger _log = Logger('PageCompiler');

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (!element.library!.isNonNullableByDefault) {
      throw InvalidGenerationSourceError(
        '$PageCompilerGenerator cannot target libraries that have not been migrated to '
        'null-safety.',
        element: element,
      );
    }

    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '`@$Page` can only be used on classes.',
          element: element);
    }

    try {
      final PageInfo info = PageParser.parse(element, annotation, buildStep);
      _log.info(
          '${info.displayName}{name: ${info.name}, routeName: ${info.routeName}}');
      infos.add(info);
      final PageWriter writer = PageWriter(info);
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
  ManifestCompilerGenerator(this.infos);

  final List<PageInfo> infos;

  final Logger _log = Logger('ManifestCompiler');

  int _count = 0;

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          'Manifest annotation can only be defined on a class.');
    }

    if (_count > 0) {
      throw InvalidGenerationSourceError(
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
      final ManifestWriter writer = ManifestWriter(element, infos);
      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

final List<PageInfo> infos = <PageInfo>[];

Builder pageCompilerBuilder({
  String Function(String code)? formatOutput,
  required Map<String, dynamic> config,
}) =>
    SharedPartBuilder(
      <Generator>[
        PageCompilerGenerator(infos),
      ],
      'page_compiler',
      formatOutput: formatOutput,
    );

Builder manifestCompilerBuilder({
  String Function(String code)? formatOutput,
  required Map<String, dynamic> config,
}) =>
    LibraryBuilder(
      ManifestCompilerGenerator(infos),
      generatedExtension: '.manifest.g.dart',
      formatOutput: formatOutput,
    );
