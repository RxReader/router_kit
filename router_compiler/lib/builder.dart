import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder routerCompiler(BuilderOptions options) => routerCompilerBuilder(config: options.config);

PostProcessBuilder routerCleanup(BuilderOptions options) => routerCleanupBuilder(config: options.config);
