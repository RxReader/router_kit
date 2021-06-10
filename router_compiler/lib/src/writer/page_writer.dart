import 'package:analyzer/dart/element/element.dart';
import 'package:router_compiler/src/info/info.dart';
import 'package:router_compiler/src/util/utils.dart';

class PageWriter {
  PageWriter(this.info);

  final PageInfo info;

  final StringBuffer _buffer = StringBuffer();

  void generate() {
    _generateController();
    _generateProvider();
  }

  void _generateController() {
    // begin
    _buffer.writeln('class ${info.controllerDisplayName} {');

    // blank
    _buffer.writeln();

    _buffer.writeln('String get name => ${info.providerDisplayName}.name;');

    // blank
    _buffer.writeln();

    _buffer.writeln('String get routeName => ${info.providerDisplayName}.routeName;');

    // blank
    _buffer.writeln();

    _buffer.writeln('WidgetBuilder get routeBuilder => ${info.providerDisplayName}.routeBuilder;');

    // blank
    _buffer.writeln();
    _buffer.writeln('@override');
    _buffer.writeln('dynamic noSuchMethod(Invocation invocation) {');
    _buffer.writeln('if (invocation.isGetter) {');
    _buffer.writeln('switch (invocation.memberName) {');
    _buffer.writeln('case #name:');
    _buffer.writeln('return name;');
    _buffer.writeln('case #routeName:');
    _buffer.writeln('return routeName;');
    _buffer.writeln('case #routeBuilder:');
    _buffer.writeln('return routeBuilder;');
    _buffer.writeln('}');
    _buffer.writeln('}');
    _buffer.writeln('return super.noSuchMethod(invocation);');
    _buffer.writeln('}');

    // end
    _buffer.writeln('}');
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

    //
    _buffer.writeln('static final WidgetBuilder routeBuilder = (BuildContext context) {');
    if (info.constructor.parameters.isNotEmpty) {
      _buffer.writeln('Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;');
      final StringBuffer arguments = StringBuffer()
        ..writeln(<String>[
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed))
            info.constructor.parameters
                .where((ParameterElement element) => !element.isNamed)
                .map((ParameterElement element) => 'arguments?[\'${info.convertField(element.name)}\'] as ${element.type.getDisplayString(withNullability: true)},')
                .join('\n'),
          if (info.constructor.parameters.any((ParameterElement element) => element.isNamed))
            info.constructor.parameters
                .where((ParameterElement element) => element.isNamed)
                .map((ParameterElement element) => '${element.name}: arguments?[\'${info.convertField(element.name)}\'] as ${element.type.getDisplayString(withNullability: true)},')
                .join('\n'),
        ].join('\n'));
      _buffer.writeln('return ${info.displayName}($arguments);');
    } else {
      _buffer.writeln('return ${info.displayName}();');
    }
    _buffer.writeln('};');

    if (info.constructor.parameters.isNotEmpty) {
      // blank
      _buffer.writeln();

      _buffer
        ..writeln('static Map<String, dynamic> routeArgument(${<String>[
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed && !element.isOptional))
            info.constructor.parameters
                .where((ParameterElement element) => !element.isNamed && !element.isOptional)
                .map((ParameterElement element) => '${formatPrettyDisplay(element.type, withNullability: true)} ${element.name}')
                .join(', '),
          if (info.constructor.parameters.any((ParameterElement element) => !element.isNamed && element.isOptional))
            '[${info.constructor.parameters.where((ParameterElement element) => !element.isNamed && element.isOptional).map((ParameterElement element) => '${formatPrettyDisplay(element.type, withNullability: true)} ${element.name}${element.hasDefaultValue ? ' = ${element.defaultValueCode}' : ''}').join(', ')},]',
          if (info.constructor.parameters.any((ParameterElement element) => element.isNamed))
            '{${info.constructor.parameters.where((ParameterElement element) => element.isNamed).map((ParameterElement element) => '${element.isRequiredNamed ? 'required ' : ''}${formatPrettyDisplay(element.type, withNullability: true)} ${element.name}${element.hasDefaultValue ? ' = ${element.defaultValueCode}' : ''}').join(', ')},}',
        ].join(', ')}) {')
        ..writeln('return <String, dynamic>{${info.constructor.parameters.map((ParameterElement element) => '\'${info.convertField(element.name)}\': ${element.name},').join('\n')}};')
        ..writeln('}');
    }

    // end
    _buffer.writeln('}');
  }

  @override
  String toString() => _buffer.toString();
}
