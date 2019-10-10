import 'package:flutter/painting.dart';
import 'package:html/dom.dart';

typedef CustomRender = InlineSpan Function(
  Node node,
  List<InlineSpan> children,
);

typedef TapLinkCallback = void Function(String url);

typedef TapImageCallback = void Function(String source);
