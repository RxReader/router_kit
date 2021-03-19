import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class ManifestWriter {
  ManifestWriter(this.info);

  final ManifestInfo info;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    // begin
    _buffer.writeln('class ${info.providerDisplayName} {');

    // constructor
    _buffer.writeln('const ${info.providerDisplayName}._();');

    // blank
    _buffer.writeln('');

    if (info.interceptors?.isNotEmpty ?? false) {
      final String routeInterceptorType = info.interceptors.first.type.getDisplayString(withNullability: false);
      _buffer.writeln('static const List<$routeInterceptorType> interceptors = <$routeInterceptorType>[${info.interceptors.map((ExecutableElement element) {
        return <String>[
          element.enclosingElement.displayName,
          element.displayName,
        ].where((String element) => element?.isNotEmpty ?? false).join('.');
      }).join(',')}];');
    }

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
