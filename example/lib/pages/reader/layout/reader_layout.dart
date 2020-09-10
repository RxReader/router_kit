import 'dart:ui' as ui;

import 'package:example/pages/reader/html/span/style_span.dart';
import 'package:example/pages/reader/layout/text_block.dart';
import 'package:example/pages/reader/layout/typeset.dart';
import 'package:flutter/material.dart';
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
    InlineSpan swap = _swapSpan(article);
    InlineSpan text = TextSpan(
      children: <InlineSpan>[
        swap,
      ],
      style: textStyle,
    );
    // 分页
    textPainter.text = text;
    textPainter.layout(maxWidth: canvas.width);
    int wordCursor = 0;
    int paragraphCursor = 0;
    int paragraphWordCursor = 0;
    double lineReferHeight = 0.0;
    double pageReferHeight = 0;
    List<ui.LineMetrics> computeLineMetrics = textPainter.computeLineMetrics();
    for (int i = 0; i < computeLineMetrics.length; i++) {
      final int startWordCursor = wordCursor;
      int endWordCursor = wordCursor;
      Map<int, TextRange> paragraphTextRangeMap = <int, TextRange>{};
      Map<int, Offset> paragraphCaretOffsetMap = <int, Offset>{};
      // primiary
      ui.LineMetrics primiaryLineMetrics = computeLineMetrics[i];
      if (primiaryLineMetrics.hardBreak) {
        // '\n'换行
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight + primiaryLineMetrics.height / 2));
        Offset offset = textPainter.getOffsetForCaret(position, Rect.fromLTRB(0, 0, canvas.width, lineReferHeight + primiaryLineMetrics.height));
        paragraphTextRangeMap[paragraphCursor] = TextRange(start: wordCursor, end: position.offset);
        paragraphCaretOffsetMap[paragraphCursor] = offset.translate(0, -pageReferHeight);
        paragraphWordCursor = textPainter.getOffsetAfter(position.offset);
        wordCursor = paragraphWordCursor;
        paragraphCursor ++;
      }
      lineReferHeight += primiaryLineMetrics.height;
      if (lineReferHeight >= pageReferHeight + canvas.height) {
        // 超/满一页
        pageReferHeight = lineReferHeight;
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight - primiaryLineMetrics.height / 2));
        if (!primiaryLineMetrics.hardBreak) {
          paragraphTextRangeMap[paragraphCursor] = TextRange(start: wordCursor, end: position.offset);
          wordCursor = textPainter.getOffsetAfter(position.offset);
        }
        endWordCursor = position.offset;
      } else {
        i++;
        for (; i < computeLineMetrics.length; i++) {
          // secondary
          ui.LineMetrics secondaryLineMetrics = computeLineMetrics[i];
          if (lineReferHeight + secondaryLineMetrics.height > pageReferHeight + canvas.height) {
            // 超一页
            i--;
            // tertiary -> primiary/latest secondary
            ui.LineMetrics tertiaryLineMetrics = computeLineMetrics[i];
            TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight - tertiaryLineMetrics.height / 2));
            if (!tertiaryLineMetrics.hardBreak) {
              paragraphTextRangeMap[paragraphCursor] = TextRange(start: wordCursor, end: position.offset);
              wordCursor = textPainter.getOffsetAfter(position.offset);
            }
            endWordCursor = position.offset;
            break;
          } else {
            bool shouldBreak = lineReferHeight + secondaryLineMetrics.height == pageReferHeight + canvas.height;
            if (secondaryLineMetrics.hardBreak) {
              // '\n'换行
              TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight + secondaryLineMetrics.height / 2));
              Offset offset = textPainter.getOffsetForCaret(position, Rect.fromLTRB(0, 0, canvas.width, lineReferHeight + secondaryLineMetrics.height));
              paragraphTextRangeMap[paragraphCursor] = TextRange(start: wordCursor, end: position.offset);
              paragraphCaretOffsetMap[paragraphCursor] = offset.translate(0, -pageReferHeight);
              paragraphWordCursor = textPainter.getOffsetAfter(position.offset);
              wordCursor = paragraphWordCursor;
              paragraphCursor ++;
            }
            lineReferHeight += secondaryLineMetrics.height;
            if (shouldBreak) {
              // 满一页
              TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight - secondaryLineMetrics.height / 2));
              if (!secondaryLineMetrics.hardBreak) {
                paragraphTextRangeMap[paragraphCursor] = TextRange(start: wordCursor, end: position.offset);
                wordCursor = textPainter.getOffsetAfter(position.offset);
              }
              endWordCursor = position.offset;
              break;
            }
          }
        }
        pageReferHeight = lineReferHeight;
      }
      pages.add(PageBlock(
        composing: TextRange(start: startWordCursor, end: endWordCursor),
        paragraphTextRangeMap: paragraphTextRangeMap,
        paragraphCaretOffsetMap: paragraphCaretOffsetMap,
      ));
    }
    return pages;
  }

  static InlineSpan _subSpan(InlineSpan span, TextRange composing) {
    assert(span.visitChildren((InlineSpan span) => span is TextSpan));
    final Accumulator offset = Accumulator();
    span.visitChildren((InlineSpan span) => false);
    return span;
  }

  static InlineSpan _reverseSwapSpan(InlineSpan span) {
    if (span is StylePlaceholderTextSpan) {
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
      return StylePlaceholderTextSpan(wrapped: span);
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
