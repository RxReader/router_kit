import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/parser/manifest_parser.dart';
import 'package:router_compiler/src/parser/page_parser.dart';
import 'package:router_compiler/src/writer/manifest_collect_writer.dart';
import 'package:router_compiler/src/writer/manifest_writer.dart';
import 'package:router_compiler/src/writer/page_writer.dart';
import 'package:source_gen/source_gen.dart';

class ManifestCompilerGenerator extends GeneratorForAnnotation<Manifest> {
  final Logger _log = Logger('ManifestCompiler');

  int _count = 0;

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('`@$Manifest` can only be used on classes.', element: element);
    }

    if (_count > 0) {
      throw InvalidGenerationSourceError('`@$Manifest` can only be defined once.', element: element);
    }

    _count++;

    try {
      ManifestInfo info = ManifestParser.parse(element as ClassElement, annotation, buildStep);

      ManifestWriter writer = ManifestWriter(info);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

class PageCompilerGenerator extends GeneratorForAnnotation<Page> {
  PageCompilerGenerator(this.pageInfoMap);

  final Map<String, PageInfo> pageInfoMap;

  final Logger _log = Logger('PageCompiler');

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('`@$Page` can only be used on classes.', element: element);
    }

    try {
      PageInfo info = PageParser.parse(element as ClassElement, annotation, buildStep);
      if (pageInfoMap.containsKey(info.routeName)) {
        throw InvalidGenerationSourceError('`@$Page` routeName(${info.routeName}) is exists', element: element);
      }
      pageInfoMap[info.routeName] = info;
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

class ManifestCollectCompilerGenerator extends GeneratorForAnnotation<Manifest> {
  ManifestCollectCompilerGenerator(this.pageInfoMap);

  final Map<String, PageInfo> pageInfoMap;

  final Logger _log = Logger('ManifestCollectCompiler');

  int _count = 0;

  @override
  dynamic generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('`@$Manifest` can only be used on classes.', element: element);
    }

    if (_count > 0) {
      throw InvalidGenerationSourceError('`@$Manifest` can only be defined once.', element: element);
    }

    _count++;

    _log.info('\n'
        '******************** ${_log.name} ********************\n'
        'ManifestCollectCompiler 暂不支持增量更新\n'
        '如果需要添加/删除/更新路由信息，请先执行清除命令：\n'
        'flutter pub run build_runner clean\n'
        '然后执行下列命令重新生成相应文件：\n'
        'flutter pub run build_runner build --delete-conflicting-outputs\n'
        '******************** ${_log.name} ********************');

    try {
      ManifestInfo manifestInfo = ManifestParser.parse(element as ClassElement, annotation, buildStep);
      ManifestCollectWriter writer = ManifestCollectWriter(manifestInfo, pageInfoMap);

      writer.generate();
      return writer.toString();
    } on Exception catch (e, s) {
      _log.severe(e);
      _log.severe(s);
      return '// $e \n\n';
    }
  }
}

final Map<String, PageInfo> pageInfoMap = <String, PageInfo>{};

Builder manifestCompilerBuilder({Map<String, dynamic> config}) => SharedPartBuilder(
      <Generator>[
        ManifestCompilerGenerator(),
      ],
      'manifest_compiler',
    );

Builder pageCompilerBuilder({Map<String, dynamic> config}) => SharedPartBuilder(
      <Generator>[
        PageCompilerGenerator(pageInfoMap),
      ],
      'page_compiler',
    );

Builder manifestCollectCompilerBuilder({Map<String, dynamic> config}) => LibraryBuilder(
      ManifestCollectCompilerGenerator(pageInfoMap),
      generatedExtension: '.manifest.g.dart',
    );
