import 'dart:ui' as ui;

import 'package:example/pages/reader/html/span/style_span.dart';
import 'package:example/pages/reader/layout/text_block.dart';
import 'package:example/pages/reader/layout/typeset.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ReaderLayout {
  ReaderLayout._();

  static Future<List<PageBlock>> layout(
    Size window,
    EdgeInsets padding,
    Typeset typeset,
    InlineSpan article,
    Locale locale,
  ) async {
    assert(article != null);
    assert(locale != null);
    assert(!window.isEmpty);
    List<PageBlock> pages = <PageBlock>[];
    Size canvas = typeset.resolveCanvas(padding.deflateSize(window));
    assert(!canvas.isEmpty);
    final TextStyle textStyle = typeset.resolveTextStyle(locale);
    final TextPainter textPainter = typeset.resolveTextPainter(locale);
    InlineSpan text = TextSpan(
      children: <InlineSpan>[
        article,
      ],
      style: textStyle,
    );
    while (true) {
      textPainter.text = text;
      // TODO 等价替换 StyleSpan - StylePlaceholderSpan
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
      if (textPainter.height > canvas.height) {
        // 超过一页
        double calculateLineHeight = 0.0;
        List<ui.LineMetrics> lineMetrics = textPainter.computeLineMetrics();
        ui.LineMetrics latestLineMetrics;
        for (ui.LineMetrics lineMetric in lineMetrics) {
          if (lineMetric.hardBreak) {
            // '\n' 换行
          }
          calculateLineHeight += lineMetric.height;
          if (calculateLineHeight > canvas.height) {
            calculateLineHeight -= lineMetric.height;
            break;
          } else if (calculateLineHeight == canvas.height) {
            latestLineMetrics = lineMetric;
            break;
          }
          latestLineMetrics = lineMetric;
        }
        // 可见区域范围内的文字，可能文字只会显示半行，故而不能直接使用，需要借助 LineMetrics
        // WidgetSpan 不能参与计算，因为这会导致计算错误
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, calculateLineHeight - latestLineMetrics.height / 2));
        Offset offsetForCaret = textPainter.getOffsetForCaret(position, Rect.fromLTRB(0.0, 0.0, canvas.width, calculateLineHeight));
        textPainter.text.getSpanForPosition(position);
        break;
      } else {
        // 不足一页
        break;
      }
    }

    if (pages.isEmpty) {
      pages.addAll(<PageBlock>[
        PageBlock.dummy,
        PageBlock.dummy,
      ]);
    }
    return pages;
  }
}
