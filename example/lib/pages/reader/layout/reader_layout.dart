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
    // WidgetSpan 不能参与计算，因为这会导致计算错误
    // 等价替换 StyleWidgetSpan -> StyleSwapperTextSpan
    InlineSpan text = TextSpan(
      children: <InlineSpan>[
        _swapSpan(article),
      ],
      style: textStyle,
    );

    // 测量段落
    List<TextRange> paragraphRanges = <TextRange>[];
    {
      textPainter.text = text;
      textPainter.layout(maxWidth: canvas.width);
      List<ui.LineMetrics> lineMetrics = textPainter.computeLineMetrics();
      double calculateLineHeight = 0.0;
      int paragraphWordCursor = 0;
      for (ui.LineMetrics lineMetric in lineMetrics) {
        calculateLineHeight += lineMetric.height;
        if (lineMetric.hardBreak) {
          // '\n'换行
          TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, calculateLineHeight - lineMetric.height / 2));
          paragraphRanges.add(TextRange(start: paragraphWordCursor, end: position.offset));
          paragraphWordCursor = textPainter.getOffsetAfter(position.offset);
        }
      }
    }

    // 分页
    int wordCursor = 0;
    while (true) {
      textPainter.text = text;
      textPainter.layout(maxWidth: canvas.width);
      if (textPainter.height >= canvas.height) {
        // 超过一页
        double calculateLineHeight = 0.0;
        List<ui.LineMetrics> lineMetrics = textPainter.computeLineMetrics();
        ui.LineMetrics latestLineMetrics;
        for (ui.LineMetrics lineMetric in lineMetrics) {
          calculateLineHeight += lineMetric.height;
          if (calculateLineHeight > canvas.height) {
            calculateLineHeight -= lineMetric.height;
            break;
          } else {
            latestLineMetrics = lineMetric;
            if (lineMetric.hardBreak) {
              // '\n'换行
              TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, calculateLineHeight - latestLineMetrics.height / 2));
              Offset offsetForCaret = textPainter.getOffsetForCaret(position, Rect.fromLTRB(0.0, 0.0, canvas.width, calculateLineHeight));
            }
            if (calculateLineHeight == canvas.height) {
              break;
            }
          }
        }
        // 可见区域范围内的文字，可能文字只会显示半行，故而不能直接使用，需要借助 LineMetrics
        // 不能直接用最后一行的高度，这可能会导致定位到后面显示的半行
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, calculateLineHeight - latestLineMetrics.height / 2));
        textPainter.text.getSpanForPosition(position);
        wordCursor = textPainter.getOffsetAfter(position.offset);
        break;
      } else {
        // 不足或刚好一页
        List<ui.LineMetrics> lineMetrics = textPainter.computeLineMetrics();
        double calculateLineHeight = 0.0;
        for (ui.LineMetrics lineMetric in lineMetrics) {
          calculateLineHeight += lineMetric.height;
          if (lineMetric.hardBreak) {
            // '\n'换行
            TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, calculateLineHeight - lineMetric.height / 2));
            Offset offsetForCaret = textPainter.getOffsetForCaret(position, Rect.fromLTRB(0.0, 0.0, canvas.width, calculateLineHeight));

          }
        }
        break;
      }
    }

    pages.clear();
    pages.addAll(<PageBlock>[
      PageBlock.dummy,
      PageBlock.dummy,
    ]);
    return pages;
  }

  static InlineSpan _subSpan(InlineSpan span, TextPosition position) {
    return span;
  }

  static InlineSpan _reverseSwapSpan(InlineSpan span) {
    if (span is StyleSwapperTextSpan) {
      return span.wrapped;
    }
    if (span is TextSpan) {
      return TextSpan(
        text: span.text,
        children: span.children?.map((InlineSpan child) => _reverseSwapSpan(child))?.toList(),
        style: span.style,
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    }
    return span;
  }

  static InlineSpan _swapSpan(InlineSpan span) {
    if (span is StyleWidgetSpan) {
      return StyleSwapperTextSpan(wrapped: span);
    }
    if (span is TextSpan) {
      return TextSpan(
        text: span.text,
        children: span.children?.map((InlineSpan child) => _swapSpan(child))?.toList(),
        style: span.style,
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    }
    return span;
  }
}
