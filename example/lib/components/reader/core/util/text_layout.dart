import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/util/text_symbol.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart' as strings;

class TextBlock {
  const TextBlock({
    @required this.startWordCursor,
    @required this.endWordCursor,
    @required this.paragraphCursor,
    @required this.paragraphWordCursor,
  });

  final int startWordCursor;
  final int endWordCursor;
  final int paragraphCursor;
  final int paragraphWordCursor;
}

class TextPage {
  const TextPage({
    @required this.startWordCursor,
    @required this.endWordCursor,
    @required this.textBlocks,
    @required this.inlineSpans,
    @required this.paragraphOffsetMap,
  });

  final int startWordCursor;
  final int endWordCursor;
  final List<TextBlock> textBlocks;
  final List<InlineSpan> inlineSpans;
  final Map<int, Offset> paragraphOffsetMap;
}

class TextLayout {
  const TextLayout._();

  static String _preferredText(Locale locale) {
    return locale.languageCode == 'zh' ? '一' : 'a';
  }

  static Future<List<TextPage>> layout({
    @required Size canvas,
    @required ReaderSettings settings,
    @required String content,
  }) async {
    assert(strings.isNotEmpty(content));
    assert(canvas != null && !canvas.isEmpty);
    assert(settings != null);
    List<TextPage> textPages = <TextPage>[];
    print('开始');
    final String textIndentPlaceholder = settings.textIndentPlaceholder();
    final TextPainter textPainter = settings.textPainter;
    final TextStyle textStyle = settings.style;
    textPainter.text = TextSpan(
      text: _preferredText(settings.locale),
      style: textStyle,
    );
    textPainter.layout();
    final double preferredLineHeight = textPainter.preferredLineHeight;
    final List<String> paragraphs = content.split(TextSymbol.newLine);
    int paragraphCursor = 0;
    int wordCursor = 0;
    while (paragraphCursor < paragraphs.length) {
      int startWordCursor = wordCursor;
      int endWordCursor;
      List<TextBlock> textBlocks = <TextBlock>[];
      List<InlineSpan> inlineSpans = <InlineSpan>[];
      Map<int, Offset> paragraphOffsetMap = <int, Offset>{};
      while (paragraphCursor < paragraphs.length && endWordCursor == null) {
        final int paragraphWordCursor = wordCursor -
            (paragraphCursor == 0
                ? 0
                : paragraphs
                    .take(paragraphCursor)
                    .map((String paragraph) => paragraph.length + 1)
                    .reduce((int value, int element) => value + element));
        if (paragraphWordCursor < 0) {
          throw StateError('paragraphCursor = $paragraphWordCursor');
        }
        final bool shouldAppendNewLine =
            inlineSpans.isNotEmpty && paragraphWordCursor == 0;
        final bool shouldAppendTextIndent =
            textIndentPlaceholder.isNotEmpty && paragraphWordCursor == 0;
        final String paragraph = paragraphs[paragraphCursor];
        final List<InlineSpan> paragraphSpans = <InlineSpan>[
          if (shouldAppendNewLine)
            TextSpan(
              text: TextSymbol.newLine,
            ),
          if (shouldAppendTextIndent)
            TextSpan(
              text: textIndentPlaceholder,
            ),
          TextSpan(
            text: paragraph.substring(paragraphWordCursor),
          ),
        ];
        textPainter.text = TextSpan(
          children: <InlineSpan>[
            ...inlineSpans,
            ...paragraphSpans,
          ],
          style: textStyle,
        );
        textPainter.layout(maxWidth: canvas.width);
        if (textPainter.height >= canvas.height) {
          // 排满一页
          TextPosition position = textPainter.getPositionForOffset(
              Offset(canvas.width, canvas.height)); // 可见区域范围内的文字，可能文字只会显示半行
          Offset offsetForCaret = textPainter.getOffsetForCaret(
              position, Rect.fromLTRB(0.0, 0.0, canvas.width, canvas.height));
          if (canvas.height - offsetForCaret.dy < preferredLineHeight) {
            // 半行文字
            position = textPainter.getPositionForOffset(
                Offset(canvas.width, canvas.height - preferredLineHeight));
            offsetForCaret = textPainter.getOffsetForCaret(
                position,
                Rect.fromLTRB(0.0, 0.0, canvas.width,
                    canvas.height - preferredLineHeight));
          }
          final String textInPreview = textPainter.text.toPlainText(
            includeSemanticsLabels: false,
            includePlaceholders: true,
          );
          final int textInPreviewBlockCursor =
              paragraph.length - (textInPreview.length - position.offset);
          if (textInPreviewBlockCursor < paragraphWordCursor) {
            // 最后一段还没开始就结束了，offset 定位换行符
            endWordCursor = wordCursor;
          } else if (position.offset == textInPreview.length) {
            // 最后一段刚好结束
            final int blockEndWordCursor = wordCursor +
                paragraph.length /*textInPreviewBlockCursor*/ -
                paragraphWordCursor;
            textBlocks.add(TextBlock(
              startWordCursor: wordCursor,
              endWordCursor: blockEndWordCursor,
              paragraphCursor: paragraphCursor,
              paragraphWordCursor: paragraphWordCursor,
            ));
            inlineSpans.addAll(paragraphSpans);
            paragraphOffsetMap[paragraphCursor] = offsetForCaret;
            wordCursor = blockEndWordCursor;
            endWordCursor = wordCursor;
            wordCursor += TextSymbol.newLine.length; // 跳过'\n'
            paragraphCursor++;
          } else {
            // 最后一段需要拆段
            paragraphSpans.removeLast();
            final String paragraphTextDisplay = paragraph.substring(
                paragraphWordCursor, textInPreviewBlockCursor);
            paragraphSpans.add(TextSpan(
              text: paragraphTextDisplay,
            ));
            final int blockEndWordCursor =
                wordCursor + textInPreviewBlockCursor - paragraphWordCursor;
            textBlocks.add(TextBlock(
              startWordCursor: wordCursor,
              endWordCursor: blockEndWordCursor,
              paragraphCursor: paragraphCursor,
              paragraphWordCursor: paragraphWordCursor,
            ));
            inlineSpans.addAll(paragraphSpans);
            paragraphOffsetMap[paragraphCursor] = offsetForCaret;
            wordCursor = blockEndWordCursor;
            endWordCursor = wordCursor;
          }
        } else {
          // 没有排满一页
          final int blockEndWordCursor =
              wordCursor + paragraph.length - paragraphWordCursor;
          textBlocks.add(TextBlock(
            startWordCursor: wordCursor,
            endWordCursor: blockEndWordCursor,
            paragraphCursor: paragraphCursor,
            paragraphWordCursor: paragraphWordCursor,
          ));
          inlineSpans.addAll(paragraphSpans);
          final TextPosition position = textPainter
              .getPositionForOffset(Offset(canvas.width, canvas.height));
          final Offset offsetForCaret = textPainter.getOffsetForCaret(
              position, Rect.fromLTRB(0.0, 0.0, canvas.width, canvas.height));
          paragraphOffsetMap[paragraphCursor] = offsetForCaret;
          wordCursor = blockEndWordCursor;
          if (paragraphCursor == paragraphs.length - 1) {
            // 最后一段
            endWordCursor = wordCursor;
          } else {
            wordCursor += TextSymbol.newLine.length; // 跳过'\n'
          }
          paragraphCursor++;
        }
      }
      textPages.add(TextPage(
        startWordCursor: startWordCursor,
        endWordCursor: endWordCursor,
        textBlocks: textBlocks,
        inlineSpans: inlineSpans,
        paragraphOffsetMap: paragraphOffsetMap,
      ));
    }
    print('结束');
    return textPages;
  }
}
