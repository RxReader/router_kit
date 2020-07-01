import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder pageCompiler(BuilderOptions options) =>
    pageCompilerBuilder(header: options.config['header'] as String);

//Builder routerCompiler(BuilderOptions options) =>
//    routerCompilerBuilder(header: options.config['header'] as String);
