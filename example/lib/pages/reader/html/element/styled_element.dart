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
    @required this.parent,
  });

  final String name;
  final String elementId;
  final List<StyledElement> children;
  final Attributes attributes;
  final dom.Node node;
  final StyledElement parent;

  FutureOr<InlineSpan> apply({@required Size canvas, @required TextStyle style, String sourceUrl, TapCallbacks callbacks, bool reduce = false}) async {
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
              if (span is StyleWidgetSpan) {
                placeholderDimensions.add(PlaceholderDimensions(
                  size: Size(span.width, span.height),
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
          spans.add(SubWidgetSpan(
            textSpan: textSpan,
            width: textPainter.width,
            height: textPainter.height,
            style: mergeStyle,
          ));
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
              if (span is StyleWidgetSpan) {
                placeholderDimensions.add(PlaceholderDimensions(
                  size: Size(span.width, span.height),
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
          spans.add(SupWidgetSpan(
            textSpan: textSpan,
            width: textPainter.width,
            height: textPainter.height,
            style: mergeStyle,
          ));
          break;

        // BLOCK ELEMENTS
        case 'hr':
          spans.clear();
          spans.add(GenericStyleWidgetSpan(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
            ),
            placeholder: '',
            width: canvas.width,
            height: 1,
            style: mergeStyle,
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
    if (spans.isNotEmpty && (attributes?.display == Display.BLOCK || attributes?.display == Display.LIST_ITEM)) {
      // 换行
      if (parent != null) {
        bool isHtml = false;
        bool isBodyTag = false;
        if (node is dom.Element) {
          dom.Element element = node as dom.Element;
          if (element.localName == 'html') {
            isHtml = true;
          } else if (element.localName == 'body') {
            isBodyTag = true;
          }
        }
        if (isHtml) {
          // 忽略
        } else if (isBodyTag) {
          int index = parent.children.indexOf(this);
          StyledElement previous = index > 0 ? parent.children[index - 1] : null;
          if (previous != null) {
            InlineSpan previousSpan = await previous.apply(canvas: canvas, style: style, sourceUrl: sourceUrl, callbacks: callbacks, reduce: reduce);
            if (previousSpan != null) {
              spans.insert(0, TextSpan(text: '\n'));
            }
          }
        } else {
          int index = parent.children.indexOf(this);
          StyledElement previous = index > 0 ? parent.children[index - 1] : null;
          if (previous != null) {
            if (previous.attributes?.display != Display.BLOCK && previous.attributes?.display != Display.LIST_ITEM) {
              spans.insert(0, TextSpan(text: '\n'));
            }
          } else {
            if (parent.attributes?.display != Display.BLOCK) {
              spans.insert(0, TextSpan(text: '\n'));
            }
          }
//          StyledElement next = index < parent.children.length - 1 ? parent.children[index + 1] : null;
          spans.add(TextSpan(text: '\n'));
        }
      }
    }
    TextSpan result = TextSpan(
      children: spans,
      style: mergeStyle != style ? mergeStyle : null,
    );
    if (reduce) {
      // 削减嵌套
      if (result.style == null) {
        if (result.children.isEmpty) {
          return null;
        } else if (result.children.length == 1) {
          return result.children.first;
        }
      }
    }
    return result;
  }
}
