import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class RouterWriter {
  RouterWriter(this.element, this.infos);

  final ClassElement element;
  final Map<String, ComponentInfo> infos;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
//    // import
//    for (ComponentInfo info in infos.values) {
//      _buffer.writeln(info.importUri);
//    }

    String providerDisplayName = '${element.displayName}Provider';
    // begin
    _buffer.writeln('class $providerDisplayName {');

    // constructor
    _buffer.writeln('const $providerDisplayName._();');

    // blank
    _buffer.writeln('');

    _buffer.writeln('static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{');
    for (ComponentInfo info in infos.values) {
      _buffer.writeln('${info.providerDisplayName}.routeName: ${info.providerDisplayName}.routeBuilder,');
    }
    _buffer.writeln('};');

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
