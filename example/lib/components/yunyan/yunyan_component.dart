import 'package:example/components/yunyan/yunyan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  GlobalKey _tabBarViewKey;
  List<ValueNotifier<double>> _notifiers;

  @override
  void initState() {
    super.initState();
    _tabBarViewKey = GlobalKey();
    _notifiers = _tabs.map((_) => ValueNotifier<double>(0.0)).toList();
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
              key: _tabBarViewKey,
              children: _tabs.map((String tab) {
                return YunyanView(
                  title: tab,
                  notifier: _notifiers[_tabs.indexOf(tab)],
                );
              }).toList(),
            ),
            CustomAppBar(
              tabs: _tabs,
              notifiers: _notifiers,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    Key key,
    this.tabs,
    this.notifiers,
  }) : super(key: key);

  final List<String> tabs;
  final List<ValueNotifier<double>> notifiers;

  @override
  State<StatefulWidget> createState() {
    return _CustomAppBarState();
  }
}

class _CustomAppBarState extends State<CustomAppBar> {
  TabController _controller;
  int _currentIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  void _updateTabController() {
    final TabController newController = DefaultTabController.of(context);
    if (newController == _controller) {
      return;
    }
    if (_controller?.animation != null) {
      _controller.removeListener(_handleTabControllerTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller.addListener(_handleTabControllerTick);
      _currentIndex = _controller.index;
    }
  }
  void _handleTabControllerTick() {
    if (_controller.index != _currentIndex) {
      _currentIndex = _controller.index;
    }
    setState(() {
      // Rebuild the tabs after a (potentially animated) index change
      // has completed.
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Builder(
        builder: (BuildContext context) {
          return ValueListenableBuilder<double>(
            valueListenable:
                widget.notifiers[DefaultTabController.of(context).index],
            builder: (BuildContext context, double value, Widget child) {
              final double appbarHeight =
                  MediaQuery.of(context).padding.top + kToolbarHeight;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                child: Container(
                  constraints: BoxConstraints.tightFor(
                    height: appbarHeight,
                  ),
                  color:
                      value >= appbarHeight ? Colors.white : Colors.transparent,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TabBar(
                          tabs: widget.tabs.map((String tab) {
                            TextPainter textPainter = TextPainter(
                              text: TextSpan(
                                text: tab,
                                style: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              textDirection: Directionality.of(context),
                              locale: Localizations.localeOf(context),
                            )..layout();
                            return Tab(
                              child: Container(
                                alignment: Alignment.center,
                                width: textPainter.width,
                                child: Text(tab),
                              ),
                            );
                          }).toList(),
                          isScrollable: true,
                          indicatorPadding: EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                            bottom: 7.0,
                          ),
                          indicatorColor: value >= appbarHeight
                              ? Colors.green
                              : Colors.white,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: TextStyle(
                            fontSize: 18.0,
                          ),
                          labelColor: value >= appbarHeight
                              ? Colors.green
                              : Colors.white,
                          unselectedLabelStyle: TextStyle(
                            fontSize: 16.0,
                          ),
                          unselectedLabelColor: value >= appbarHeight
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(
                          width: kToolbarHeight,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          color: value >= appbarHeight
                              ? Colors.black
                              : Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                value: value >= appbarHeight
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light,
              );
            },
          );
        },
      ),
    );
  }
}
