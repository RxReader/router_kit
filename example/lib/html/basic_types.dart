import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;

typedef CustomRender = InlineSpan Function(
  dom.Node node,
  List<InlineSpan> children,
);

typedef TapLinkCallback = void Function(
  String target,
  String media,
  String mimeType,
  String url,
);

typedef TapImageCallback = void Function(String source);
