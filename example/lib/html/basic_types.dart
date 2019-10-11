import 'package:example/html/html.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;

typedef CustomRender = InlineSpan Function(
  dom.Node node,
  HtmlParseContext context,
  ChildrenRender childrenRender,
);

typedef ChildrenRender = List<InlineSpan> Function(
  List<dom.Node> nodes,
  HtmlParseContext context,
);

typedef TapLinkCallback = void Function(
  String target,
  String media,
  String mimeType,
  String url,
);

typedef TapImageCallback = void Function(String source);
