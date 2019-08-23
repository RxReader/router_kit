import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: NestedScrollView.sliverOverlapAbsorberHandleFor(context)
              .layoutExtent +
          40.0,
      child: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
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
        onNotification: (ScrollNotification notification) {
          ScrollMetrics metrics = notification.metrics;
          if (metrics.axisDirection == AxisDirection.down &&
              metrics.extentAfter == 0) {
            _onLoadMore();
          }
          return false;
        },
      ),
      onRefresh: _onRefresh,
    );
  }

  Future<void> _onLoadMore() async {
    if (!_isLoading) {
      print('aaaaaaaaaaaaaaaaaaaaaaaa');
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 3));
      _childCount += 10;
      setState(() {
        _isLoading = false;
      });
      print('bbbbbbbbbbbbbbbbbbbbbbbb');
    }
  }

  Future<void> _onRefresh() async {
    if (!_isLoading) {
      print('xxxxxxxxxxxxxxxxxxxxxxxx');
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 3));
      _childCount = 10;
      setState(() {
        _isLoading = false;
      });
      print('yyyyyyyyyyyyyyyyyyyyyyyy');
    }
  }
}

class NestedScrollModel extends Model {

  bool isLoading() {
    return false;
  }

  bool isEnd() {
    return false;
  }
}
