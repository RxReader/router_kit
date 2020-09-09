import 'dart:async';

import 'package:example/pages/reader/html/attributes.dart';
import 'package:example/pages/reader/html/converter.dart';
import 'package:example/pages/reader/html/span/style_span.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class StyledElement {
  StyledElement({
    @required this.name,
    this.elementId,
    this.children,
    this.attributes,
    @required this.node,
  });

  final String name;
  final String elementId;
  final List<StyledElement> children;
  final Attributes attributes;
  final dom.Node node;

  FutureOr<InlineSpan> apply({Size canvas, TextStyle style, String sourceUrl, TapCallbacks callbacks}) async {
    TextStyle mergeStyle = style.merge(attributes?.textStyle).apply(fontSizeFactor: attributes?.fontSizeFactor ?? 1.0);
    List<InlineSpan> spans = <InlineSpan>[];
    for (StyledElement child in children) {
      InlineSpan span = await child.apply(canvas: canvas, style: mergeStyle, sourceUrl: sourceUrl, callbacks: callbacks);
      if (span != null) {
        spans.add(span);
      }
    }
    if (node is dom.Element) {
      dom.Element element = node as dom.Element;
      switch (element.localName) {
        case 'q':
          spans.insert(0, TextSpan(text: '\"'));
          spans.add(TextSpan(text: '\"'));
          break;
        case 'sub':
          TextSpan textSpan = TextSpan(
            children: List<InlineSpan>.of(spans),
            style: mergeStyle,
          );
          TextPainter textPainter = TextPainter(
            text: textSpan,
          );
          List<PlaceholderDimensions> placeholderDimensions = <PlaceholderDimensions>[];
          textPainter.text.visitChildren((InlineSpan span) {
            if (span is PlaceholderSpan) {
              if (span is StyleSpan) {
                StyleSpan styleSpan = span as StyleSpan;
                placeholderDimensions.add(PlaceholderDimensions(
                  size: Size(styleSpan.width, styleSpan.height),
                  alignment: span.alignment,
                  baseline: span.baseline,
                  baselineOffset: null,
                ));
              } else {
                throw UnsupportedError('${span.runtimeType} is unsupported.');
              }
            }
            return true;
          });
          textPainter.setPlaceholderDimensions(placeholderDimensions);
          textPainter.layout(maxWidth: canvas.width);
          spans.clear();
          spans.add(SubWidgetSpan(textSpan: textSpan, width: textPainter.width, height: textPainter.height));
          break;
        case 'sup':
          TextSpan textSpan = TextSpan(
            children: List<InlineSpan>.of(spans),
            style: mergeStyle,
          );
          TextPainter textPainter = TextPainter(
            text: textSpan,
          );
          List<PlaceholderDimensions> placeholderDimensions = <PlaceholderDimensions>[];
          textPainter.text.visitChildren((InlineSpan span) {
            if (span is PlaceholderSpan) {
              if (span is StyleSpan) {
                StyleSpan styleSpan = span as StyleSpan;
                placeholderDimensions.add(PlaceholderDimensions(
                  size: Size(styleSpan.width, styleSpan.height),
                  alignment: span.alignment,
                  baseline: span.baseline,
                  baselineOffset: null,
                ));
              } else {
                throw UnsupportedError('${span.runtimeType} is unsupported.');
              }
            }
            return true;
          });
          textPainter.setPlaceholderDimensions(placeholderDimensions);
          textPainter.layout(maxWidth: canvas.width);
          spans.clear();
          spans.add(SupWidgetSpan(textSpan: textSpan, width: textPainter.width, height: textPainter.height));
          break;

        // BLOCK ELEMENTS
        case 'hr':
          spans.add(StyleWidgetSpan(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 1))
              ),
            ),
            placeholder: '',
            width: canvas.width,
            height: 1,
          ));
          break;
        case 'li':
          String markerContent;
          if (element.parent.localName == 'ul') {
            markerContent = '${element.parent.children.where((dom.Element childElement) => childElement.localName == element.localName).toList().indexOf(element) + 1}.';
          } else {
            markerContent = '•';
          }
          spans.insert(0, TextSpan(text: markerContent));
          break;
      }
    }
    return TextSpan(
      children: spans,
      style: mergeStyle,
    );
  }
}
