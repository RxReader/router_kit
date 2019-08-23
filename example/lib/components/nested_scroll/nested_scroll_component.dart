import 'package:example/components/nested_scroll/nested_scroll_refresh_list_page.dart';
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
  List<String> _tabs = <String>[
    'idea',
    'discover',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverAppBar(
                  title: Text('Nested Scroll Demo'),
                  pinned: true,
                  expandedHeight: 250.0,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _tabs.map((String name) => Tab(text: name,),).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) => NestedScrollRefreshListPage()).toList(),
          ),
        ),
      ),
    );
  }
}
