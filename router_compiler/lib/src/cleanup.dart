import 'dart:io';

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

final Logger _log = Logger('RouterCleanup');

class RouterCleanupBuilder implements PostProcessBuilder {
  const RouterCleanupBuilder();

  @override
  void build(PostProcessBuildStep buildStep) {
    File partFile = File(path.join('.dart_tool/build/generated/${buildStep.inputId.package}', buildStep.inputId.path));
    _log.info('clean part file: ${partFile.path}');
    partFile.deleteSync();
  }

  @override
  Iterable<String> get inputExtensions => <String>[
        '.router_compiler.g.part',
      ];
}

PostProcessBuilder routerCleanupBuilder({Map<String, dynamic> config}) => const RouterCleanupBuilder();
