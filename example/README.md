# example

A Flutter Demo project.

## Usage

```shell
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

```shell
find . -path "./.dart_tool" -prune -o -name "*.dart" -not -name "*.g.dart" -exec flutter format --line-length 200 {} +
```
