import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder componentCompiler(BuilderOptions options) =>
    componentCompilerBuilder(header: options.config['header'] as String);

Builder routerCompiler(BuilderOptions options) =>
    routerCompilerBuilder(header: options.config['header'] as String);
