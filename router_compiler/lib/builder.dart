import 'package:build/build.dart';
import 'package:router_compiler/src/generator.dart';

Builder manifestCompiler(BuilderOptions options) => manifestCompilerBuilder(config: options.config);

Builder pageCompiler(BuilderOptions options) => pageCompilerBuilder(config: options.config);

Builder manifestCollectCompiler(BuilderOptions options) => manifestCollectCompilerBuilder(config: options.config);
