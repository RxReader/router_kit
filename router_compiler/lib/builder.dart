import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder pageCompiler(BuilderOptions options) => pageCompilerBuilder(config: options.config);

Builder manifestCompiler(BuilderOptions options) => manifestCompilerBuilder(config: options.config);