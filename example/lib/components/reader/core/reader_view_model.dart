import 'dart:ui' as ui;

import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/util/text_symbol.dart';
import 'package:example/components/reader/core/view/text_page.dart';
import 'package:example/components/reader/model/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class ReaderViewModel extends Model {
  List<TextPage> _textPages;

  List<TextPage> get textPages => _textPages;

  Future<void> typeset(ReaderSettings settings, Size canvas) async {
    List<TextPage> textPages = <TextPage>[];
    print('开始');
    final Article article = await loadArticle();
    final String content = article.content;
    final String textIndentPlaceholder = settings.locale.languageCode == 'zh'
        ? '${TextSymbol.sbcSpace}${TextSymbol.sbcSpace}'
        : '';
    final String paragraphSpacingPlaceholder = '\uFFFC\n';
    final List<String> paragraphs = content.split(TextSymbol.newLine);
    int paragraphCursor = 0;
    int wordCursor = 0;
    while (paragraphCursor < paragraphs.length) {
      int startWordCursor = wordCursor;
      int endWordCursor;
      List<InlineSpan> spansInPage = <InlineSpan>[];
      while (paragraphCursor < paragraphs.length && endWordCursor == null) {
        int paragraphWordCursor = wordCursor -
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
            spansInPage.length > 0 && paragraphWordCursor == 0;
        final bool shouldAppendParagraphSpacing =
            paragraphSpacingPlaceholder.isNotEmpty &&
                spansInPage.length > 0 &&
                paragraphWordCursor == 0;
        final bool shouldAppendTextIndent =
            textIndentPlaceholder.isNotEmpty && paragraphWordCursor == 0;
        final String paragraph = paragraphs[paragraphCursor];
        final List<InlineSpan> paragraphSpans = <InlineSpan>[
          if (shouldAppendNewLine)
            TextSpan(
              text: TextSymbol.newLine,
            ),
          if (shouldAppendParagraphSpacing)
            TextSpan(
              text: paragraphSpacingPlaceholder,
              style: TextStyle(fontSize: 7.0),
            ),
          if (shouldAppendTextIndent)
            TextSpan(
              text: textIndentPlaceholder,
            ),
          TextSpan(
            text: paragraph.substring(paragraphWordCursor),
          ),
        ];
        final TextPainter textPainter = settings.textPainter;
        textPainter.text = TextSpan(
          children: <InlineSpan>[
            ...spansInPage,
            ...paragraphSpans,
          ],
          style: settings.style,
        );
        textPainter.layout(maxWidth: canvas.width);
        if (textPainter.height >= canvas.height) {
          // 排满一页
          TextPosition position = textPainter.getPositionForOffset(
              Offset(canvas.width, canvas.height)); // 可见区域范围内的文字，可能文字只会显示半行
          InlineSpan spanForPosition =
              textPainter.text.getSpanForPosition(position);
          String textForPosition = spanForPosition.toPlainText(
              includeSemanticsLabels: false, includePlaceholders: true);
          if (textForPosition == paragraphSpacingPlaceholder) {
            // 最后一段还没开始就结束了
            endWordCursor = wordCursor;
          } else {
            Offset offsetForCaret = textPainter.getOffsetForCaret(
                position, Rect.fromLTRB(0.0, 0.0, canvas.width, canvas.height));
            final double fullHeightForCaret = textPainter.getFullHeightForCaret(
              position,
              Rect.fromLTRB(0.0, 0.0, canvas.width, canvas.height),
            ); // 偏大
            final double fontHeight =
                settings.style.fontSize * settings.style.height; // 偏小
            final double averageHeight =
                (fullHeightForCaret + fontHeight) / 2.0; // 取平均值
            if (canvas.height - offsetForCaret.dy < averageHeight) {
              // 半行文字
              position = textPainter.getPositionForOffset(
                  Offset(canvas.width, canvas.height - averageHeight));
            }
            spanForPosition = textPainter.text.getSpanForPosition(position);
            textForPosition = spanForPosition.toPlainText(
                includeSemanticsLabels: false, includePlaceholders: true);
            if (textForPosition == paragraphSpacingPlaceholder) {
              // 只显示一半文字的最后一行是段落的第一行
              endWordCursor = wordCursor;
            } else {
              final String textInPreview = textPainter.text.toPlainText(
                includeSemanticsLabels: false,
                includePlaceholders: true,
              );
              final int paragraphWordBlockCursor =
                  paragraph.length - (textInPreview.length - position.offset);
              if (paragraphWordBlockCursor < paragraphWordCursor) {
                // 最后一段还没开始就结束了，offset 定位换行符
                endWordCursor = wordCursor;
              } else if (position.offset == textInPreview.length) {
                // 最后一段刚好结束
                spansInPage.addAll(paragraphSpans);
                wordCursor += paragraph.length /*paragraphWordBlockCursor*/ -
                    paragraphWordCursor;
                endWordCursor = wordCursor;
                wordCursor++; // 跳过'\n'
                paragraphCursor++;
              } else {
                // 最后一段需要拆段
                paragraphSpans.removeLast();
                final String paragraphTextDisplay = paragraph.substring(
                    paragraphWordCursor, paragraphWordBlockCursor);
                paragraphSpans.add(TextSpan(
                  text: paragraphTextDisplay,
                ));
                spansInPage.addAll(paragraphSpans);
                wordCursor += paragraphWordBlockCursor - paragraphWordCursor;
                endWordCursor = wordCursor;
              }
            }
          }
        } else {
          // 没有排满一页
          spansInPage.addAll(paragraphSpans);
          wordCursor += paragraph.length - paragraphWordCursor;
          if (paragraphCursor == paragraphs.length - 1) {
            endWordCursor = wordCursor;
          } else {
            wordCursor++; // 跳过'\n'
          }
          paragraphCursor++;
        }
      }
      textPages.add(TextPage(
        startWordCursor: startWordCursor,
        endWordCursor: endWordCursor,
        spansInPage: spansInPage,
      ));
    }
//    textPages
//        .map((TextPage textPage) =>
//            content.substring(textPage.startWordCursor, textPage.endWordCursor))
//        .forEach((String pair) => print(
//            'pair: ${pair.length > 30 ? '${pair.substring(0, 5)} - ${pair.substring(pair.length - 5, pair.length)}' : pair}'));
    print('结束');
    _textPages = textPages;
    notifyListeners();
  }

  Future<Article> loadArticle() async {
    String title = '章节排版测试';
    String content = await rootBundle.loadString('assets/novel/article.txt');
    content = content
        .split('\n')
        .map((String pair) => pair.trimLeft().trimRight())
        .join('\n');
    return Article(
      title: title,
      content: content,
    );
  }
}
