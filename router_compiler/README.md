# router_compiler

[![Pub Package](https://img.shields.io/pub/v/router_compiler.svg)](https://pub.dev/packages/router_compiler)

The builders generate code when they find members annotated with classes defined in [package:router_annotation](https://pub.dev/packages/router_annotation).

## Usage

See the [example](../example) to understand how to configure your package.

* (推荐) router_compiler cli

```shell
flutter pub run router_compiler:compiler build
```

* (不推荐) build_runner cli

```shell
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```
