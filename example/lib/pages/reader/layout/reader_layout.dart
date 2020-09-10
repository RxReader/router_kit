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
    // 分页
    List<TextRange> paragraphRanges = <TextRange>[];
    textPainter.text = text;
    textPainter.layout(maxWidth: canvas.width);
    int wordCursor = 0;
    int paragraphWordCursor = 0;
    double lineReferHeight = 0.0;
    double pageReferHeight = 0;
    List<ui.LineMetrics> computeLineMetrics = textPainter.computeLineMetrics();
    for (int i = 0; i < computeLineMetrics.length; i++) {
      // primiary
      ui.LineMetrics primiaryLineMetrics = computeLineMetrics[i];
      if (primiaryLineMetrics.hardBreak) {
        // '\n'换行
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight + primiaryLineMetrics.height / 2));
        paragraphRanges.add(TextRange(start: paragraphWordCursor, end: position.offset));
        paragraphWordCursor = textPainter.getOffsetAfter(position.offset);
      }
      lineReferHeight += primiaryLineMetrics.height;
      if (lineReferHeight >= pageReferHeight + canvas.height) {
        // 超/满一页
        pageReferHeight = lineReferHeight;
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight - primiaryLineMetrics.height / 2));
        wordCursor = textPainter.getOffsetAfter(position.offset);
      } else {
        i++;
        for (; i < computeLineMetrics.length; i++) {
          // secondary
          ui.LineMetrics secondaryLineMetrics = computeLineMetrics[i];
          if (lineReferHeight + secondaryLineMetrics.height > pageReferHeight + canvas.height) {
            // 超一页
            i--;
            break;
          } else {
            bool shouldBreak = lineReferHeight + secondaryLineMetrics.height == pageReferHeight + canvas.height;
            if (secondaryLineMetrics.hardBreak) {
              // '\n'换行
              TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight + secondaryLineMetrics.height / 2));
              paragraphRanges.add(TextRange(start: paragraphWordCursor, end: position.offset));
              paragraphWordCursor = textPainter.getOffsetAfter(position.offset);
            }
            lineReferHeight += secondaryLineMetrics.height;
            if (shouldBreak) {
              // 满一页
              break;
            }
          }
        }
        pageReferHeight = lineReferHeight;
        // tertiary -> primiary/latest secondary
        ui.LineMetrics tertiaryLineMetrics = computeLineMetrics[i];
        TextPosition position = textPainter.getPositionForOffset(Offset(canvas.width, lineReferHeight - tertiaryLineMetrics.height / 2));
        wordCursor = textPainter.getOffsetAfter(position.offset);
      }
      pages.add(PageBlock(
        startWordCursor: null,
        endWordCursor: null,
        paragraphBlocks: null,
        paragraphCaretOffsetMap: null,
      ));
    }

//    pages.clear();
//    pages.addAll(<PageBlock>[
//      PageBlock.dummy,
//      PageBlock.dummy,
//    ]);
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
