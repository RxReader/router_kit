import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder routerCompiler(BuilderOptions options) =>
    routerCompilerBuilder(header: options.config['header'] as String);
