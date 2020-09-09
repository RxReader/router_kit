import 'dart:async';

import 'package:example/pages/reader/html/converter.dart';
import 'package:example/pages/reader/html/element/styled_element.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

abstract class ReplacedElement extends StyledElement {
  ReplacedElement({
    @required String name,
    @required String elementId,
    @required dom.Node node,
  }) : super(name: name, elementId: elementId, node: node);
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({
    @required String name,
    @required String elementId,
    @required dom.Node node,
  }) : super(name: name, elementId: elementId, node: node);

  @override
  FutureOr<InlineSpan> apply({Size canvas, TextStyle style, String sourceUrl, TapCallbacks callbacks}) {
    return null;
  }
}

class TextContentElement extends ReplacedElement {
  TextContentElement({
    @required this.text,
    @required dom.Node node,
  }) : super(name: '[text]', elementId: null, node: node);

  final String text;

  @override
  FutureOr<InlineSpan> apply({Size canvas, TextStyle style, String sourceUrl, TapCallbacks callbacks}) async {
    return TextSpan(text: text);
  }
}
