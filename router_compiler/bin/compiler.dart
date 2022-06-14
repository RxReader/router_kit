import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

typedef Log = void Function(Object? object);

const Log log = print;

class BuildCommand extends Command<void> {
  @override
  String get description => 'Builds the wrapper binaries. Requires cmake.';

  @override
  String get name => 'build';

  @override
  FutureOr<void> run() async {
    log('${runner?.executableName} $name');
    log('clean \u2026');
    final ProcessResult clean = await Process.run(
      'flutter',
      <String>['pub', 'run', 'build_runner', 'clean'],
    );
    if (clean.exitCode != 0) {
      throw ProcessException(
        'flutter',
        <String>['pub', 'run', 'build_runner', 'clean'],
        clean.stderr as String? ?? '',
        clean.exitCode,
      );
    }
    log('build provider && manifest \u2026');
    final ProcessResult build = await Process.run(
      'flutter',
      <String>[
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs'
      ],
    );
    if (build.exitCode != 0) {
      throw ProcessException(
        'flutter',
        <String>[
          'pub',
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs'
        ],
        build.stderr as String? ?? '',
        build.exitCode,
      );
    }
  }
}

/// flutter pub run router_compiler:compiler build
Future<void> main(List<String> args) async {
  final CommandRunner<void> runner = CommandRunner<void>('compiler', '路由编译');
  runner.addCommand(BuildCommand());
  await runner.run(args);
}
