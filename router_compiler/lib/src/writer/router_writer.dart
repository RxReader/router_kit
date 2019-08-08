import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class RouterWriter {
  RouterWriter(this.element, this.infoMap);

  final ClassElement element;
  final Map<String, ComponentInfo> infoMap;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    List<ComponentInfo> infos = <ComponentInfo>[];
    infos.addAll(infoMap.values);
    infos.sort((ComponentInfo a, ComponentInfo b) {
      return a.routeName.compareTo(b.routeName);
    });

    // import
    _buffer.writeln('import \'package:flutter/widgets.dart\';');
    for (ComponentInfo info in infos) {
      _buffer.writeln('import \'${info.uri}\';');
    }

    // blank
    _buffer.writeln('');

    String providerDisplayName = '${element.displayName}Provider';
    // begin
    _buffer.writeln('class $providerDisplayName {');

    // constructor
    _buffer.writeln('const $providerDisplayName._();');

    // blank
    _buffer.writeln('');

    _buffer.writeln('static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{');
    for (ComponentInfo info in infos) {
      _buffer.writeln('${info.providerDisplayName}.routeName: ${info.providerDisplayName}.routeBuilder,');
    }
    _buffer.writeln('};');

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
