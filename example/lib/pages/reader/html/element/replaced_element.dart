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
    @required StyledElement parent,
  }) : super(name: name, elementId: elementId, node: node, parent: parent);
}

class EmptyContentElement extends ReplacedElement {
  EmptyContentElement({
    @required String name,
    @required String elementId,
    @required dom.Node node,
    @required StyledElement parent,
  }) : super(name: name, elementId: elementId, node: node, parent: parent);

  @override
  FutureOr<InlineSpan> apply({@required Size canvas, @required TextStyle style, String sourceUrl, TapCallbacks callbacks, bool reduce = false}) {
    return null;
  }
}

class TextContentElement extends ReplacedElement {
  TextContentElement({
    @required this.text,
    @required dom.Node node,
    @required StyledElement parent,
  }) : super(name: '[text]', elementId: null, node: node, parent: parent);

  final String text;

  @override
  FutureOr<InlineSpan> apply({@required Size canvas, @required TextStyle style, String sourceUrl, TapCallbacks callbacks, bool reduce = false}) async {
    return TextSpan(text: text);
  }
}
