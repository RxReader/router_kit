import 'package:example/components/nested_scroll/nested_scroll_refresh_list_page.dart';
import 'package:example/components/nested_scroll/nested_scroll_refresh_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'nested_scroll_component.component.dart';

@Component(
  routeName: '/nested_scroll',
)
class NestedScrollComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NestedScrollComponentState();
  }
}

class _NestedScrollComponentState extends State<NestedScrollComponent> {
  static const List<String> _tabs = <String>[
    'idea',
    'discover',
  ];

  List<TestModel> _models;
  List<PageStorageKey<String>> _scrollKeys;

  @override
  void initState() {
    super.initState();
    _models = _tabs.map((String name) => TestModel(name)).toList();
    _scrollKeys =
        _tabs.map((String name) => PageStorageKey<String>(name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverAppBar(
                  title: Text('Nested Scroll Demo'),
                  pinned: true,
                  expandedHeight: 250.0,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) {
              int index = _tabs.indexOf(name);
              return NestedScrollRefreshListPage(
                name: name,
                model: _models[index],
                scrollKey: _scrollKeys[index],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
