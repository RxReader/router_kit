import 'package:example/pages/reader/after_layout.dart';
import 'package:example/pages/reader/layout/typeset.dart';
import 'package:example/pages/reader/locales.dart';
import 'package:example/pages/reader/reader_model.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:router_annotation/router_annotation.dart' as router;

part 'reader_page.g.dart';

@router.Page(
  routeName: '/reader',
)
class ReaderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReaderPageState();
  }
}

class _ReaderPageState extends State<ReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
      ),
      body: ChangeNotifierProvider<ReaderModel>(
        create: (BuildContext context) => ReaderModel(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AfterLayout(
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (SizeChangedLayoutNotification notification) {
                  ReaderModel.of(context).constraints = constraints;
                  ReaderModel.of(context).relayout();
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: Consumer<ReaderModel>(
                    builder: (BuildContext context, ReaderModel model, Widget child) {
                      return PageView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          Typeset typeset = Typeset.defaultTypeset;
                          return Container(
                            alignment: Alignment.center,
                            padding: typeset.padding,
                            color: index % 2 == 0 ? Colors.red : Colors.green,
                            child: Theme(
                              data: Theme.of(context).copyWith(platform: TargetPlatform.android),
                              child: Directionality(
                                textDirection: typeset.textDirection,
                                child: DefaultTextStyle.merge(
                                  textAlign: typeset.textAlign,
                                  child: ExtendedText.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        TextSpan(text: model.article?.title ?? ''),
                                        WidgetSpan(
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.blue,
                                            child: Text('$index'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: typeset.resolveTextStyle(zhHansCN),
                                    strutStyle: typeset.strutStyle,
                                    textAlign: typeset.textAlign,
                                    textDirection: typeset.textDirection,
                                    textScaleFactor: 1.0,
                                    locale: zhHansCN,
                                    selectionEnabled: true,
                                    textSelectionControls: extendedCupertinoTextSelectionControls,
//                                textSelectionControls: extendedMaterialTextSelectionControls,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: model.pages?.length ?? 0,
                      );
                    },
                  ),
                ),
              ),
              onAfterFirstLayout: (BuildContext context, int times) {
                ReaderModel.of(context).constraints = constraints;
                ReaderModel.of(context).fetchArticle();
              },
            );
          },
        ),
      ),
    );
  }
}
