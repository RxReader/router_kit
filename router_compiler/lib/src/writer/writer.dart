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
    StringBuffer ctor1 = StringBuffer();
    for (ParameterElement ctorParameter in info.ctorParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorParameter.displayName];
      ctor1.writeln(
          '${!fieldInfo.ignore ? 'arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] as ${ctorParameter.type.displayName}' : 'null'},');
    }
    for (ParameterElement ctorNamedParameter in info.ctorNamedParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorNamedParameter.displayName];
      // ignore: deprecated_member_use
      if (ctorNamedParameter.isRequired || !fieldInfo.ignore) {
        ctor1.writeln(
            '${ctorNamedParameter.displayName}: ${!fieldInfo.ignore ? 'arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] as ${ctorNamedParameter.type.displayName}' : 'null'},');
      }
    }
    _buffer.writeln('return ${info.displayName}(\n${ctor1.toString()});');
    _buffer.writeln('};');

    // blank
    _buffer.writeln('');

    // arguments
    StringBuffer ctor2 = StringBuffer();
    for (ParameterElement ctorParameter in info.ctorParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorParameter.displayName];
      if (!fieldInfo.ignore) {
        ctor2.writeln('${ctorParameter.type.displayName} ${ctorParameter.displayName},');
      }
    }
    bool hasOptionalParameters = false;
    for (ParameterElement ctorNamedParameter in info.ctorNamedParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorNamedParameter.displayName];
      if (!fieldInfo.ignore) {
        if (!hasOptionalParameters) {
          hasOptionalParameters = true;
          ctor2.writeln('{');
        }
        ctor2.writeln('${ctorNamedParameter.type.displayName} ${ctorNamedParameter.displayName},');
      }
    }
    if (hasOptionalParameters) {
      ctor2.writeln('}');
    }
    _buffer.writeln(
        'static Map<dynamic, dynamic> arguments(\n${ctor2.toString()}){');
    _buffer.writeln('Map<dynamic, dynamic> arguments = <dynamic, dynamic>{};');
    for (ParameterElement ctorParameter in info.ctorParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorParameter.displayName];
      if (!fieldInfo.ignore) {
        _buffer.write('arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] = ${ctorParameter.displayName};');
      }
    }
    for (ParameterElement ctorNamedParameter in info.ctorNamedParameters) {
      FieldInfo fieldInfo = info.fieldInfos[ctorNamedParameter.displayName];
      if (!fieldInfo.ignore) {
        _buffer.write('arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] = ${ctorNamedParameter.displayName};');
      }
    }
    _buffer.writeln('return arguments;');
    _buffer.writeln('}');

    // end
    _buffer.writeln('}');
  }

  String toString() => _buffer.toString();
}
