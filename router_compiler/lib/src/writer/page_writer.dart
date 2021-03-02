import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/utils.dart';

class PageWriter {
  PageWriter(this.info);

  final PageInfo info;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    _generateProvider();
    _generateNavigator();
  }

  void _generateProvider() {
    // begin
    _buffer.writeln('class ${info.providerDisplayName} {');

    // constructor
    _buffer.writeln('const ${info.providerDisplayName}._();');

    // blank
    _buffer.writeln();

    _buffer.writeln('static const String name = \'${info.name}\';');

    // blank
    _buffer.writeln();

    _buffer.writeln('static const String routeName = \'${info.routeName}\';');

    // blank
    _buffer.writeln();

    if (info.interceptors?.isNotEmpty ?? false) {
      String routeInterceptorType = info.interceptors.first.type.getDisplayString(withNullability: false);
      _buffer.writeln('static const List<$routeInterceptorType> interceptors = <$routeInterceptorType>[${info.interceptors.map((ExecutableElement element) {
        return <String>[
          element.enclosingElement.displayName,
          element.displayName,
        ].where((String element) => element?.isNotEmpty ?? false).join('.');
      }).join(',')}];');
    }

    // blank
    _buffer.writeln();

    //
    _buffer.writeln('static WidgetBuilder routeBuilder = (BuildContext context) {');
    if (info.constructor.parameters.isNotEmpty) {
      _buffer.writeln('Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;');
      StringBuffer arguments = StringBuffer()
        ..writeln(<String>[
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed))
            info.constructor.parameters
                .where((ParameterElement element) => !element.isNamed)
                .map((ParameterElement element) => 'arguments[\'${info.convertField(element.name)}\'] as ${element.type.getDisplayString(withNullability: false)},')
                .join('\n'),
          if (info.constructor.parameters.any((ParameterElement element) => element.isNamed))
            info.constructor.parameters
                .where((ParameterElement element) => element.isNamed)
                .map((ParameterElement element) => '${element.name}: arguments[\'${info.convertField(element.name)}\'] as ${element.type.getDisplayString(withNullability: false)},')
                .join('\n'),
        ].join('\n'));
      _buffer.writeln('return ${info.displayName}($arguments);');
    } else {
      _buffer.writeln('return ${info.displayName}();');
    }
    _buffer.writeln('};');

    // end
    _buffer.writeln('}');
  }

  void _generateNavigator() {
    // begin
    _buffer.writeln('class ${info.navigatorDisplayName} {');

    // constructor
    _buffer.writeln('const ${info.navigatorDisplayName}._();');

    // blank
    _buffer.writeln();

    if (info.constructor.parameters.isNotEmpty) {
      _buffer
        ..writeln('static Map<String, dynamic> routeArgument(${<String>[
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed && !element.isOptional))
            info.constructor.parameters
                .where((ParameterElement element) => !element.isNamed && !element.isOptional)
                .map((ParameterElement element) => '${formatPrettyDisplay(element.type)} ${element.name}')
                .join(', '),
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed && element.isOptional))
            '[${info.constructor.parameters.where((ParameterElement element) => !element.isNamed && element.isOptional).map((ParameterElement element) => '${formatPrettyDisplay(element.type)} ${element.name}').join(', ')}]',
          if (info.constructor.parameters.any((ParameterElement element) => element.isNamed))
            '{${info.constructor.parameters.where((ParameterElement element) => element.isNamed).map((ParameterElement element) => '${formatPrettyDisplay(element.type)} ${element.name}').join(', ')}}',
        ].join(', ')}) {')
        ..writeln('return <String, dynamic>{${info.constructor.parameters.map((ParameterElement element) => '\'${info.convertField(element.name)}\': ${element.name},').join('\n')}};')
        ..writeln('}');

      // blank
      _buffer.writeln();
    }

    // end
    _buffer.writeln('}');

    // // blank
    // _buffer.writeln();
    //
    // _buffer.writeln(
    //     'static Future<T> pushByNamed<T extends Object>(\nBuildContext context,\n$ctor2){');
    // _buffer.writeln('Map<String, dynamic> arguments = <String, dynamic>{};');
    // for (ParameterElement ctorParameter in info.ctorParameters) {
    //   FieldInfo fieldInfo = info.fieldInfos[ctorParameter.displayName];
    //   if (!fieldInfo.ignore) {
    //     _buffer.write(
    //         'arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] = ${ctorParameter.displayName};');
    //   }
    // }
    // for (ParameterElement ctorNamedParameter in info.ctorNamedParameters) {
    //   FieldInfo fieldInfo = info.fieldInfos[ctorNamedParameter.displayName];
    //   if (!fieldInfo.ignore) {
    //     _buffer.write(
    //         'arguments[\'${info.nameFormatter(fieldInfo.alias)}\'] = ${ctorNamedParameter.displayName};');
    //   }
    // }
    // _buffer.writeln(
    //     'return Navigator.of(context).pushNamed(routeName, arguments: arguments,);');
    // _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
