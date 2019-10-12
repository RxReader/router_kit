import 'dart:ui' as ui;

import 'package:example/html/html.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;

typedef CustomRender = InlineSpan Function(
  dom.Node node,
  Size window,
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
  String href,
);

typedef TapImageCallback = void Function(String src, double width, double height);

typedef TapVideoCallback = void Function(String poster, String src, double width, double height);
