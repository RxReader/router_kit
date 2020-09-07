import 'package:example/pages/reader/article.dart';
import 'package:example/pages/reader/layout/reader_layout.dart';
import 'package:example/pages/reader/layout/text_block.dart';
import 'package:example/pages/reader/layout/typeset.dart';
import 'package:example/pages/reader/locales.dart';
import 'package:flutter/foundation.dart';
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
    await Future<void>.delayed(Duration(milliseconds: 10));// 让 async 真正生效
    print('constraints: $_constraints');
    String data = '<h4>${_article.title}</h4><br/>${_article.content.split('\n').map((String paragraph) => '<p>$paragraph</p>').join('<br/>')}';
    InlineSpan article;
    _pages = await ReaderLayout.layout(_constraints.biggest, EdgeInsets.zero, Typeset.defaultTypeset, article, zhHansCN);
    notifyListeners();
  }

  static ReaderModel of(BuildContext context) {
    return Provider.of<ReaderModel>(context, listen: false);
  }
}