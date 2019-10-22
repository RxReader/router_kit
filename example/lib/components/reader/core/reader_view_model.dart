import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/view/text_page.dart';
import 'package:example/components/reader/model/article.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class RenderViewModel extends Model {
  List<TextPage> _textPages;

  List<TextPage> get textPages => _textPages;

  Future<void> typeset(
    ReaderSettings settings,
    Size canvas, [
    bool debug = true,
  ]) async {
    print('开始');
    List<TextPage> textPages = <TextPage>[];
    Article article = await loadArticle();
    String content = article.content;
    List<String> paragraphs = content.split('\n');
    int paragraphCursor = 0;
    int wordCursor = 0;
    bool skipNewLineAtFirst = false;
    TextPainter textPainter = settings.textPainter;
    while (paragraphCursor < paragraphs.length) {
      int startWordCursor = skipNewLineAtFirst ? wordCursor + 1 : wordCursor;
      skipNewLineAtFirst = false;
      int endWordCursor;
      List<InlineSpan> children = <InlineSpan>[];
      while (paragraphCursor < paragraphs.length && endWordCursor == null) {
        int paragraphWordCursor = wordCursor -
            (paragraphCursor == 0
                ? 0
                : paragraphs
                .take(paragraphCursor)
                .map((String paragraph) => paragraph.length + (paragraph == paragraphs.first ? 0 : 1))
                .reduce((int value, int element) => value + element));
        if (paragraphWordCursor > 0) {
          // 拆段落，要多扣一个 \n
          paragraphWordCursor --;
        }
        TextSpan paragraphTextSpan = TextSpan(
          text:
              '${children.length > 0 && paragraphWordCursor == 0 ? '\n' : ''}${paragraphWordCursor == 0 ? '\uFFFC\uFFFC' : ''}${paragraphs[paragraphCursor].substring(paragraphWordCursor)}',
        );
        textPainter.text = TextSpan(
          children: <InlineSpan>[
            ...children,
            paragraphTextSpan,
          ],
          style: settings.style,
        );
        textPainter.layout(maxWidth: canvas.height);
        if (textPainter.height >= canvas.height) {
          // 满一页
          TextPosition position = textPainter
              .getPositionForOffset(Offset(canvas.width, canvas.height));
          String textInPage = textPainter.text.toPlainText(
            includeSemanticsLabels: false,
            includePlaceholders: true,
          );

          String textInPageClear = textInPage.replaceAll('\uFFFC', '');
          int offset = position.offset -
              (textInPage.length -
                  textInPageClear.length); // (paragraphCursor + 1) * 2;
          endWordCursor = startWordCursor + offset;
          if (debug ?? false) {
            print('--- page: ${textPages.length} ---');
            content
                .substring(startWordCursor, endWordCursor)
                .split('\n')
                .forEach((String pair) => print('pair: $pair'));
          }
          wordCursor = endWordCursor;
          if (textInPage.length == position.offset) {
            // 不用拆段落
            skipNewLineAtFirst = true;// 跳过 \n
            paragraphCursor++;
          }
        } else {
          children.add(paragraphTextSpan);
          wordCursor += (paragraphCursor > 0 && paragraphWordCursor == 0
                  ? 1
                  : 0) +
              paragraphs[paragraphCursor].substring(paragraphWordCursor).length;
          paragraphCursor++;
          if (paragraphCursor >= paragraphs.length) {
            endWordCursor = wordCursor;
            if (debug ?? false) {
              print('--- page: ${textPages.length} ---');
              content
                  .substring(startWordCursor, endWordCursor)
                  .split('\n')
                  .forEach((String pair) => print('pair: $pair'));
            }
            break;// 也可以由 while 统一判断
          }
        }
      }
      textPages.add(TextPage(
        startWordCursor: startWordCursor,
        endWordCursor: endWordCursor,
      ));
    }
//    if (debug ?? false) {
//      print('page size: ${textPages.length}');
//    }
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
