import 'dart:ui' as ui;

import 'package:example/html/html.dart';
import 'package:flutter/cupertino.dart';
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

class CenterSpan extends WidgetSpan {
  CenterSpan({
    @required this.children,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline baseline,
    TextStyle style,
  }) : super(
          child: Center(
            child: Text.rich(TextSpan(
              children: children,
            )),
          ),
          alignment: alignment,
          baseline: baseline,
          style: style,
        );

  final List<InlineSpan> children;

  @override
  void computeToPlainText(StringBuffer buffer,
      {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
    super.computeToPlainText(buffer,
        includeSemanticsLabels: includeSemanticsLabels,
        includePlaceholders: includePlaceholders);
    if (children != null) {
      for (InlineSpan child in children) {
        child.computeToPlainText(buffer,
          includeSemanticsLabels: includeSemanticsLabels,
          includePlaceholders: includePlaceholders,
        );
      }
    }
  }
}
