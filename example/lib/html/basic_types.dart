import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
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

class RelativeSizeTextSpan extends TextSpan {
  const RelativeSizeTextSpan({
    String text,
    List<InlineSpan> children,
    TextStyle style,
    this.proportion,
    GestureRecognizer recognizer,
    String semanticsLabel,
  }) : super(
          text: text,
          children: children,
          style: style,
          recognizer: recognizer,
          semanticsLabel: semanticsLabel,
        );

  final double proportion;

  void build(ui.ParagraphBuilder builder, { double textScaleFactor = 1.0, List<PlaceholderDimensions> dimensions }) {
    super.build(builder, textScaleFactor: textScaleFactor * (proportion ?? 1.0), dimensions: dimensions);
  }

  @override
  bool operator ==(dynamic other) {
    if (super != other) {
      return false;
    }
    final RelativeSizeTextSpan typedOther = other;
    return typedOther.proportion == proportion;
  }

  @override
  int get hashCode => super.hashCode;
}
