import 'package:example/components/reader/core/reader_settings.dart';
import 'package:example/components/reader/core/reader_view_model.dart';
import 'package:example/components/reader/core/util/reader_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';
import 'package:scoped_model/scoped_model.dart';

part 'reader_component.component.dart';

@Component(
  routeName: '/reader',
)
class ReaderComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReaderComponentState();
  }
}

class _ReaderComponentState extends State<ReaderComponent> {
  ReaderViewModel _model;
  ReaderSettings _settings;

  @override
  void initState() {
    super.initState();
    _model = ReaderViewModel();
    _settings = ReaderSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
      ),
      body: ScopedModel<ReaderViewModel>(
        model: _model,
        child: ScopedModelDescendant<ReaderViewModel>(
          builder: (BuildContext context, Widget child, ReaderViewModel model) {
            if (model.textPages == null || model.textPages.isEmpty) {
              return Center(
                child: GestureDetector(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: Text('waiting'),
                  ),
                  onTap: () {
                    _model.typeset(
                      Size(
                        MediaQuery.of(context).size.width / 2,
                        240,
                      ),
                      _settings,
                    );
                  },
                ),
              );
            }
            return Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.red,
                    height: 240,
                    child: PageView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        ReaderPage textPage = model.textPages[index];
                        return Stack(
                          children: <Widget>[
                            Text.rich(
                              TextSpan(
                                text: model.article.content.substring(
                                    textPage.startWordCursor,
                                    textPage.endWordCursor),
                                style: _settings.style,
                              ),
                              style: _settings.style,
                              strutStyle: _settings.strutStyle,
                              textAlign: _settings.textAlign,
                              textDirection: _settings.textDirection,
                              textScaleFactor: _settings.textScaleFactor,
                              locale: _settings.locale,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'index - $index',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: model.textPages.length,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    height: 240,
                    child: PageView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        ReaderPage textPage = model.textPages[index];
                        return Stack(
                          children: <Widget>[
                            Text.rich(
                              TextSpan(
                                children: textPage.inlineSpans,
                                style: _settings.style,
                              ),
                              style: _settings.style,
                              strutStyle: _settings.strutStyle,
                              textAlign: _settings.textAlign,
                              textDirection: _settings.textDirection,
                              textScaleFactor: _settings.textScaleFactor,
                              locale: _settings.locale,
                            ),
                            ...textPage.paragraphOffsetMap.entries
                                .map((MapEntry<int, Offset> entry) {
                              print(
                                  'entry: ${entry.value.dx} ${entry.value.dy}');
                              return Positioned(
                                left: entry.value.dx,
                                top: entry.value.dy,
                                child: Container(
                                  color: Colors.amber,
                                  width: 5,
                                  height: 5,
                                ),
                              );
                            }).toList(),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'index - $index',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: model.textPages.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
