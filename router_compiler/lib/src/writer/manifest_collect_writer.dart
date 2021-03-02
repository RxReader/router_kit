import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class ManifestCollectWriter {
  ManifestCollectWriter(this.manifestInfo, this.pageInfoMap);

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
    _buffer.writeln();
    _generateManifest(pageInfos);
    // blank
    _buffer.writeln();
    _generateAppRouter(pageInfos);
    // blank
    _buffer.writeln();
    _generatePageRouters(pageInfos);
  }

  void _generateImport(List<PageInfo> pageInfos) {
    // import
    _buffer.writeln('import \'package:flutter/widgets.dart\';');
    for (PageInfo info in pageInfos) {
      _buffer.writeln('import \'${info.uri}\';');
    }
  }

  void _generateManifest(List<PageInfo> pageInfos) {
    // begin
    _buffer.writeln('class ${manifestInfo.manifestDisplayName} {');

    // constructor
    _buffer.writeln('const ${manifestInfo.manifestDisplayName}._();');

    // blank
    _buffer.writeln();

    _buffer.writeln('static final Map<String, String> names = <String, String>{');
    for (PageInfo pageInfo in pageInfos) {
      _buffer.writeln('${pageInfo.providerDisplayName}.routeName: ${pageInfo.providerDisplayName}.name,');
    }
    _buffer.writeln('};');

    // blank
    _buffer.writeln();

    _buffer.writeln('static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{');
    for (PageInfo pageInfo in pageInfos) {
      _buffer.writeln('${pageInfo.providerDisplayName}.routeName: ${pageInfo.providerDisplayName}.routeBuilder,');
    }
    _buffer.writeln('};');

    // end
    _buffer.writeln('}');
  }

  void _generateAppRouter(List<PageInfo> pageInfos) {
    // begin
    _buffer.writeln('class ${manifestInfo.routerDisplayName} {');

    // constructor
    _buffer.writeln('const ${manifestInfo.routerDisplayName}._();');

    // blank
    _buffer.writeln();

    List<ExecutableElement> interceptors = <ExecutableElement>[
      if (manifestInfo.interceptors?.isNotEmpty ?? false) ...manifestInfo.interceptors,
      ...pageInfos.map((PageInfo element) {
        return element.interceptors;
      }).reduce((List<ExecutableElement> value, List<ExecutableElement> element) {
        return <ExecutableElement>[
          if (value?.isNotEmpty ?? false) ...value,
          if (element?.isNotEmpty ?? false) ...element,
        ];
      }),
    ];
    List<String> params = <String>[
      'BuildContext context',
      'String routeName',
    ];
    List<String> optionParams = <String>[
      'Object arguments',
      if (interceptors?.isNotEmpty ?? false) 'List<${interceptors.first.type.getDisplayString(withNullability: false)}> interceptors',
    ];
    _buffer.writeln('static Future<T> pushNamed<T extends Object>(${params.join(', ')}, {${optionParams.join(', ')}}) {');
    if (interceptors?.isNotEmpty ?? false) {
      _buffer
        ..writeln('List<${interceptors.first.type.getDisplayString(withNullability: false)}> allInterceptors = <${interceptors.first.type.getDisplayString(withNullability: false)}>[')
        ..writeln('if (interceptors?.isNotEmpty ?? false) ...interceptors,')
        ..writeln('if (${manifestInfo.providerDisplayName}.interceptors?.isNotEmpty ?? false) ...${manifestInfo.providerDisplayName}.interceptors,')
        ..writeln('];');

      _buffer
        ..writeln('List<Future<dynamic> Function()> dispatchers = <Future<dynamic> Function()>[')
        ..writeln('() => Navigator.of(context).pushNamed(routeName, arguments: arguments),')
        ..writeln('];');

      _buffer
        ..writeln('for (Future<dynamic> Function(dynamic, String, {Object arguments, Future<dynamic> Function() next}) interceptor in allInterceptors.reversed) {')
        ..writeln('Future<dynamic> Function() next = dispatchers.last;')
        ..writeln('dispatchers.add(() => interceptor.call(${<String>[
          ...interceptors.first.type.parameters.where((ParameterElement element) => !element.isNamed).map((ParameterElement element) => element.name),
          ...interceptors.first.type.parameters.where((ParameterElement element) => element.isNamed).map((ParameterElement element) => '${element.name}: ${element.name}'),
        ].join(', ')}));')
        ..writeln('}');

      _buffer.writeln('return dispatchers.last.call();');
    } else {
      _buffer.writeln('return Navigator.of(context).pushNamed(routeName, arguments: arguments);');
    }
    _buffer.writeln('}');

    // end
    _buffer.writeln('}');
  }

  void _generatePageRouters(List<PageInfo> pageInfos) {
    //
  }

  @override
  String toString() => _buffer.toString();
}
