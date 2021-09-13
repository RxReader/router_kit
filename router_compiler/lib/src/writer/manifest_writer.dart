import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class ManifestWriter {
  ManifestWriter(this.element, this.infoMap);

  final ClassElement element;
  final Map<String, PageInfo> infoMap;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    final List<PageInfo> infos = <PageInfo>[];
    infos.addAll(infoMap.values);
    infos.sort((PageInfo a, PageInfo b) {
      return a.routeName.compareTo(b.routeName);
    });

    _buffer.writeln();

    // import
    for (final PageInfo info in infos) {
      _buffer.writeln("import '${info.uri}';");
    }

    // blank
    _buffer.writeln();

    final String providerDisplayName = '${element.displayName}Manifest';
    // begin
    _buffer.writeln('class $providerDisplayName {');

    // constructor
    _buffer.writeln('const $providerDisplayName._();');

    // blank
    _buffer.writeln();

    _buffer.writeln('static final List<dynamic> controllers = <dynamic>[');
    for (final PageInfo info in infos) {
      _buffer.writeln('${info.controllerDisplayName}(),');
    }
    _buffer.writeln('];');

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
