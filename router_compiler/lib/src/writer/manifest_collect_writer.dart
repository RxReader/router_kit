import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class ManifestCollectWriter {
  ManifestCollectWriter(this.element, this.manifestInfo, this.pageInfoMap);

  final ClassElement element;
  final ManifestInfo manifestInfo;
  final Map<String, PageInfo> pageInfoMap;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    List<PageInfo> pageInfos = <PageInfo>[];
    pageInfos.addAll(pageInfoMap.values);
    pageInfos.sort((PageInfo a, PageInfo b) {
      return a.routeName.compareTo(b.routeName);
    });
    _generateImport(pageInfos);
    // blank
    _buffer.writeln('');
    _generateManifest(pageInfos);
    // blank
    _buffer.writeln('');
    _generateRouter();
  }

  void _generateImport(List<PageInfo> pageInfos) {
    // import
    _buffer.writeln('import \'package:flutter/widgets.dart\';');
    for (PageInfo info in pageInfos) {
      _buffer.writeln('import \'${info.uri}\';');
    }
  }

  void _generateManifest(List<PageInfo> pageInfos) {
    String displayName = '${element.displayName}Manifest';
    // begin
    _buffer.writeln('class $displayName {');

    // constructor
    _buffer.writeln('const $displayName._();');

    // blank
    _buffer.writeln('');

    _buffer
        .writeln('static final Map<String, String> names = <String, String>{');
    for (PageInfo pageInfo in pageInfos) {
      _buffer.writeln(
          '${pageInfo.providerDisplayName}.routeName: ${pageInfo.providerDisplayName}.name,');
    }
    _buffer.writeln('};');

    // blank
    _buffer.writeln('');

    _buffer.writeln(
        'static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{');
    for (PageInfo pageInfo in pageInfos) {
      _buffer.writeln(
          '${pageInfo.providerDisplayName}.routeName: ${pageInfo.providerDisplayName}.routeBuilder,');
    }
    _buffer.writeln('};');

    // end
    _buffer.writeln('}');
  }

  void _generateRouter() {
    String displayName = '${element.displayName}Router';
    // begin
    _buffer.writeln('class $displayName {');

    // constructor
    _buffer.writeln('const $displayName._();');

    // blank
    _buffer.writeln('');

    //

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
