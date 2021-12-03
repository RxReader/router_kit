import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class ManifestWriter {
  ManifestWriter(this.element, this.infos);

  final ClassElement element;
  final List<PageInfo> infos;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    final List<PageInfo> sortInfos = <PageInfo>[];
    sortInfos.addAll(infos);
    sortInfos.sort((PageInfo a, PageInfo b) {
      return a.routeName.compareTo(b.routeName);
    });

    _buffer.writeln();

    // import
    for (final PageInfo info in sortInfos) {
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
    for (final PageInfo info in sortInfos) {
      _buffer.writeln('${info.controllerDisplayName}(),');
    }
    _buffer.writeln('];');

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
