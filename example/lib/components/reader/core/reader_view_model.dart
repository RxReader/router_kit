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
//  static const bool textIndentEnable = false;
//  static const String textIndentPlaceholder = TextSymbol.sbcSpace;//'\uFFFC';

  List<TextPage> _textPages;

  List<TextPage> get textPages => _textPages;

  Future<void> typeset(ReaderSettings settings, Size canvas) async {
    print('开始 - ${canvas.toString()}');
    List<TextPage> textPages = <TextPage>[];
    Article article = await loadArticle();
    final String content = article.content;
    TextPainter textPainter = settings.textPainter;
    final double contentWidth = canvas.width;
    final double contentHeight = canvas.height -
        settings.style.fontSize *
            settings.style.height; // 屏幕可见区域，可能会半行字，故而 contentHeight 要预留一行空间
    final String textIndentPlaceholder = settings.locale.languageCode == 'zh'
        ? '${TextSymbol.sbcSpace}${TextSymbol.sbcSpace}'
        : '';
//    textIndentPlaceholder = '';// TEST
    final List<String> paragraphs = content.split('\n');
    int paragraphCursor = 0;
    int wordCursor = 0;
    while (paragraphCursor < paragraphs.length) {
      int startWordCursor = wordCursor;
      int endWordCursor;
      List<InlineSpan> children = <InlineSpan>[];
      int textIndentTotalSize = 0;
      while (paragraphCursor < paragraphs.length && endWordCursor == null) {
        int paragraphWordCursor = wordCursor -
            (paragraphCursor == 0
                ? 0
                : paragraphs.take(paragraphCursor).map((String paragraph) {
                    return paragraph.length +
                        (paragraph == paragraphs.first ? 0 : 1);
                  }).reduce((int value, int element) => value + element));
        if (paragraphWordCursor < 0) {
          print('error paragraphCursor $paragraphWordCursor');
        }
        if (paragraphCursor > 0 && paragraphWordCursor > 0) {
          // 拆段落或段落刚好结束，要多扣一个 \n
          paragraphWordCursor--;
        }
        final bool shouldAppendNewLine =
            children.length > 0 && paragraphWordCursor == 0;
        final bool shouldAppendTextIndent =
            textIndentPlaceholder.isNotEmpty && paragraphWordCursor == 0;
        textIndentTotalSize += shouldAppendTextIndent ? textIndentPlaceholder.length : 0;
        final String paragraph = paragraphs[paragraphCursor];
        final TextSpan paragraphTextSpan = TextSpan(
          children: <InlineSpan>[
            if (shouldAppendNewLine)
              TextSpan(
                text: '\n',
              ),
            if (shouldAppendTextIndent)
              TextSpan(
                text: textIndentPlaceholder,
              ),
            TextSpan(
              text: paragraph.substring(paragraphWordCursor),
            ),
          ],
        );
        textPainter.text = TextSpan(
          children: <InlineSpan>[
            ...children,
            paragraphTextSpan,
          ],
          style: settings.style,
        );
        textPainter.layout(maxWidth: contentWidth);
        if (textPainter.height >= contentHeight) {
          // 满一页
          final TextPosition position = textPainter.getPositionForOffset(Offset(
            contentWidth,
            contentHeight,
          )); // 屏幕可见区域，可能会是半行字，故而上文中 contentHeight 要预留一行空间
          final String textInPreview = textPainter.text.toPlainText(
            includeSemanticsLabels: false,
            includePlaceholders: true,
          );
          final int offset = position.offset - textIndentTotalSize;
          endWordCursor = startWordCursor + offset;
          wordCursor = endWordCursor;
          if (textInPreview.length == position.offset) {
            // 不用拆段落
            wordCursor++;// 跳过 \n
            children.add(paragraphTextSpan);
            paragraphCursor++;
          } else {
            List<InlineSpan> children = paragraphTextSpan.children;
            children.removeLast();
            final String paragraphTextDisplay = paragraph.substring(paragraphWordCursor, paragraph.length - (textInPreview.length - position.offset));
            print(
                'paragraphTextDisplay: ${paragraphTextDisplay.length > 30 ? '${paragraphTextDisplay.substring(0, 5)} - ${paragraphTextDisplay.substring(paragraphTextDisplay.length - 5, paragraphTextDisplay.length)}' : paragraphTextDisplay}');
            TextSpan paragraphTextSpanDisplay = TextSpan(children: <InlineSpan>[
              ...children,
//              TextSpan(
//                text: paragraphTextFixed,
//              ),
            ]);
            children.add(paragraphTextSpanDisplay);
          }
        } else {
          wordCursor += (shouldAppendNewLine ? 1 : 0) +
              paragraph.substring(paragraphWordCursor).length;
          children.add(paragraphTextSpan);
          paragraphCursor++;
          if (paragraphCursor >= paragraphs.length) {
            endWordCursor = wordCursor;
            break; // 也可以由 while 统一判断
          }
        }
      }
      textPages.add(TextPage(
        startWordCursor: startWordCursor,
        endWordCursor: endWordCursor,
        content: content,
      ));
    }
    textPages
        .map((TextPage textPage) =>
            content.substring(textPage.startWordCursor, textPage.endWordCursor))
        .forEach((String pair) => print(
            'pair: ${pair.length > 30 ? '${pair.substring(0, 5)} - ${pair.substring(pair.length - 5, pair.length)}' : pair}'));
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
