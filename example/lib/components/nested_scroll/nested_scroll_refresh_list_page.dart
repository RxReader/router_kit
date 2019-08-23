import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

class NestedScrollRefreshListPage extends StatefulWidget {
  const NestedScrollRefreshListPage({
    Key key,
    this.name,
  }) : super(key: key);

  final String name;

  @override
  State<StatefulWidget> createState() {
    return _NestedScrollRefreshListPageState();
  }
}

class _NestedScrollRefreshListPageState
    extends State<NestedScrollRefreshListPage> {
  int _childCount = 10;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: NestedScrollView.sliverOverlapAbsorberHandleFor(context).layoutExtent + 40,
      child: CustomScrollView(
        key: PageStorageKey<String>(widget.name),
        physics: AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverFixedExtentList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
                childCount: _childCount,
              ),
              itemExtent: 48.0,
            ),
          ),
        ],
      ),
      onRefresh: () async {
        print('xxxxxxxxxxxxxxxxxxxxxxxx');
        await Future.delayed(Duration(seconds: 3));
        _childCount = 10;
        print('yyyyyyyyyyyyyyyyyyyyyyyy');
      },
    );
  }
}
