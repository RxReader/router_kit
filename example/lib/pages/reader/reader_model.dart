import 'package:example/pages/reader/article.dart';
import 'package:example/pages/reader/html/converter.dart';
import 'package:example/pages/reader/layout/reader_layout.dart';
import 'package:example/pages/reader/layout/text_block.dart';
import 'package:example/pages/reader/layout/typeset.dart';
import 'package:example/pages/reader/locales.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ReaderModel extends ChangeNotifier {
  BoxConstraints _constraints;
  Article _article;
  List<PageBlock> _pages;

  set constraints(BoxConstraints value) {
    _constraints = value;
  }

  Article get article => _article;

  List<PageBlock> get pages => _pages;

  Future<void> fetchArticle() async {
    print('fetchArticle');
    String title = '序章 第十九层地狱';
    String content = await rootBundle.loadString('assets/$title.txt');
    _article = Article(title, content);
    await relayout();
  }

  Future<void> relayout() async {
    assert(_constraints != null);
    await Future<void>.delayed(Duration(milliseconds: 10)); // 让 async 真正生效
    print('constraints: $_constraints');
    String source = '<h1>${_article.title}</h1><br/><hr/><br/>${_article.content}';
    Typeset typeset = Typeset.defaultTypeset;
    InlineSpan article = await HtmlToSpannedConverter(source).convert(canvas: _constraints.smallest, style: typeset.resolveTextStyle(zhHansCN));
    _pages = await ReaderLayout.layout(_constraints.biggest, EdgeInsets.zero, typeset, article, zhHansCN);
    notifyListeners();
  }

  static ReaderModel of(BuildContext context) {
    return Provider.of<ReaderModel>(context, listen: false);
  }
}
