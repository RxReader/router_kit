import 'dart:async';

import 'package:example/pages/reader/html/attributes.dart';
import 'package:example/pages/reader/html/converter.dart';
import 'package:example/pages/reader/html/element/styled_element.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class InteractableElement extends StyledElement {
  InteractableElement({
    @required String name,
    @required String elementId,
    @required List<StyledElement> children,
    @required Attributes attributes,
    @required this.target,
    @required this.media,
    @required this.mimeType,
    @required this.href,
    @required dom.Node node,
    @required StyledElement parent,
  }) : super(name: name, elementId: elementId, children: children, attributes: attributes, node: node, parent: parent);

  final String target;
  final String media;
  final String mimeType;
  final String href;

  @override
  FutureOr<InlineSpan> apply({@required Size canvas, @required TextStyle style, String sourceUrl, TapCallbacks callbacks, bool reduce = false}) async {
    InlineSpan inner = await super.apply(canvas: canvas, style: style, sourceUrl: sourceUrl, callbacks: callbacks);
    TapGestureRecognizer recognizer;
    recognizer.dispose();
    return TextSpan(
      children: <InlineSpan>[
        inner,
      ],
      recognizer: TapGestureRecognizer()..onTap = () {
        callbacks.onTapLink?.call(target, media, mimeType, href);
      },
    );
  }
}
