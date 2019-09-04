import 'package:example/components/nested_scroll/nested_scroll_refresh_list_view_model.dart';
import 'package:example/widgets/refresh_pageable_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NestedScrollRefreshListPage extends StatefulWidget {
  const NestedScrollRefreshListPage({
    Key key,
    this.name,
    this.model,
    this.scrollKey,
  }) : super(key: key);

  final String name;
  final TestModel model;
  final PageStorageKey<String> scrollKey;

  @override
  State<StatefulWidget> createState() {
    return _NestedScrollRefreshListPageState();
  }
}

class _NestedScrollRefreshListPageState
    extends State<NestedScrollRefreshListPage> {
  GlobalKey<RefreshPageableListViewState> _refreshKey =
      GlobalKey<RefreshPageableListViewState>();

  @override
  void initState() {
    super.initState();
    if (!widget.model.isInited()) {
      print('page: ${widget.name} - 1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshPageableListView<String>(
      key: _refreshKey,
      scrollKey: widget.scrollKey,
      model: widget.model,
      sliverHeaderBuilder: () => SliverOverlapInjector(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
      sliverItemBuilder: (List<String> items, String item) => <Widget>[
        SliverToBoxAdapter(
          child: ListTile(
            title: Text(item),
          ),
        ),
      ],
      physics: AlwaysScrollableScrollPhysics(),
      displacement: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
              .layoutExtent +
          40.0,
      notificationCallback: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          int page = (notification.metrics.pixels /
                      _refreshKey.currentContext.size.height)
                  .roundToDouble()
                  .toInt() +
              1;
          print('page: ${widget.name} - $page');
        }
      },
    );
  }
}
