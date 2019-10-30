import 'package:example/components/yunyan/yunyan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'yunyan_component.component.dart';

@Component(
  routeName: '/yunyan',
)
class YunyanComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _YunyanComponentState();
  }
}

class _YunyanComponentState extends State<YunyanComponent> {
  static const List<String> _tabs = <String>[
    '推荐',
    '女生',
    '男生',
    '限免',
  ];

  ValueNotifier<double> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<double>(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            TabBarView(
              children:
                  _tabs.map((String tab) => YunyanView(title: tab)).toList(),
            ),
            SafeArea(
              top: false,
              left: false,
              right: false,
              child: ValueListenableBuilder<double>(
                valueListenable: _notifier,
                builder: (BuildContext context, double value, Widget child) {
                  final double appbarHeight =
                      MediaQuery.of(context).padding.top + kToolbarHeight;
                  return Container(
                    constraints: BoxConstraints.tightFor(
                      height: appbarHeight,
                    ),
                    color: value >= appbarHeight
                        ? Colors.white
                        : Colors.transparent,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TabBar(
                            tabs: _tabs
                                .map((String tab) => Tab(
                                      text: tab,
                                    ))
                                .toList(),
                            isScrollable: true,
                            indicatorPadding: EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                              bottom: 10.0,
                            ),
                            indicatorColor: value >= appbarHeight
                                ? Colors.green
                                : Colors.white,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelStyle: TextStyle(
                              color: value >= appbarHeight
                                  ? Colors.green
                                  : Colors.white,
                              fontSize: 18.0,
                            ),
                            unselectedLabelStyle: TextStyle(
                              color: value >= appbarHeight
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(
                            width: kToolbarHeight,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
