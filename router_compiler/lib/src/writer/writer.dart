import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';

class Writer {
  SerializerInfo info;

  final StringBuffer _buffer = StringBuffer();

  Writer(this.info);

  void generate() {
    // begin
    _buffer.writeln('class ${info.clazzRouteName} {');

    // constructor
    _buffer.writeln('const ${info.clazzRouteName}._();');

    // blank
    _buffer.writeln('');

    // route
    _buffer.writeln('static WidgetBuilder route = (BuildContext context) {');
    _buffer.writeln(
        'Map<dynamic, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;');
    StringBuffer _ctor = StringBuffer();
    for (ParameterElement ctorParameter in info.ctorParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorParameter.name];
      _ctor.writeln(
          '${!fieldInfo.ignore ? 'arguments[\'${info.nameFormatter(fieldInfo.alias)}\']' : 'null'},');
    }
    for (ParameterElement ctorNamedParameter in info.ctorNamedParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorNamedParameter.name];
      // ignore: deprecated_member_use
      if (ctorNamedParameter.isRequired || !fieldInfo.ignore) {
        _ctor.writeln(
            '${ctorNamedParameter.name}: ${!fieldInfo.ignore
                ? 'arguments[\'${info.nameFormatter(fieldInfo.alias)}\']'
                : 'null'},');
      }
    }
    _buffer.writeln('return ${info.name}(\n${_ctor.toString()});');
    _buffer.writeln('};');

    // blank
    _buffer.writeln('');

    // arguments
    _buffer.writeln('static Map<dynamic, dynamic> arguments(){');
    _buffer.writeln('return null;');
    _buffer.writeln('}');

    // end
    _buffer.writeln('}');
  }

  String toString() => _buffer.toString();
}
