import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/util/reader_layout.dart';
import 'package:example/components/reader/model/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class ReaderViewModel extends Model {
  Article _article;
  List<ReaderPage> _textPages;

  Article get article => _article;
  List<ReaderPage> get textPages => _textPages;

  Future<void> typeset(Size canvas, ReaderSettings settings) async {
    print('开始');
    _article = await loadArticle();
    _textPages = await ReaderLayout.layout(
        canvas: canvas, settings: settings, content: article.content);
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
