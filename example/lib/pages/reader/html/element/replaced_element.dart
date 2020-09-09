import 'package:example/pages/reader/html/element/styled_element.dart';
import 'package:example/pages/reader/html/style.dart';
import 'package:flutter/foundation.dart';

class ReplacedElement extends StyledElement {
  ReplacedElement({
    String name,
  }) : super(name: name);
}

class EmptyContentElement extends StyledElement {
  EmptyContentElement() : super(name: '[empty]');
}

class TextContentElement extends StyledElement {
  TextContentElement({
    @required this.text,
    Style style,
  }) : super(name: '[text]', style: style);

  final String text;

  @override
  String toString() {
    return text.replaceAll('\n', '\\n');
  }
}
