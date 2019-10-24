import 'dart:math' as math;

import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/util/text_symbol.dart';
import 'package:example/components/reader/core/view/text_page.dart';
import 'package:example/components/reader/model/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class ReaderViewModel extends Model {
  List<TextPage> _textPages;

  List<TextPage> get textPages => _textPages;

  // TODO 空行测试
  Future<void> typeset(ReaderSettings settings, Size canvas) async {
    List<TextPage> textPages = <TextPage>[];
    print('开始');
    final Article article = await loadArticle();
    final String content = article.content;
    final int maxLines =
        canvas.height ~/ (settings.style.fontSize * settings.style.height);
    final String textIndentPlaceholder = settings.locale.languageCode == 'zh'
        ? '${TextSymbol.sbcSpace}${TextSymbol.sbcSpace}'
        : '';
    final List<String> paragraphs = content.split('\n');
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
        final bool shouldAppendTextIndent =
            textIndentPlaceholder.isNotEmpty && paragraphWordCursor == 0;
        final String paragraph = paragraphs[paragraphCursor];
        final String paragraphInPreview = paragraph.substring(paragraphWordCursor);
        final List<InlineSpan> paragraphSpans = <InlineSpan>[
          if (shouldAppendNewLine)
            TextSpan(
              text: '\n',
            ),
          if (shouldAppendTextIndent)
            TextSpan(
              text: textIndentPlaceholder,
            ),
          TextSpan(
            text: paragraphInPreview,
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
          textPainter.maxLines = maxLines;
          textPainter.layout(maxWidth: canvas.width);
          final String textInPreview = textPainter.text.toPlainText(
            includeSemanticsLabels: false,
            includePlaceholders: true,
          );
          final TextPosition position = textPainter
              .getPositionForOffset(Offset(canvas.width, canvas.height));
          final int paragraphWordBlockCursor =
              paragraph.length - (textInPreview.length - position.offset);
          if (paragraphWordBlockCursor < paragraphWordCursor) {
            // 最后一段还没开始就结束了
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
        content: content,
        textSpan: TextSpan(
          children: spansInPage,
          style: settings.style,
        ),
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
