import 'package:example/widgets/basic_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

class RefreshPageableListView<T> extends StatefulWidget {
  const RefreshPageableListView({
    Key key,
    @required this.model,
    this.sliverHeaderBuilder,
    @required this.sliverItemBuilder,
    this.sliverFooterBuilder,
    this.physics,
    this.displacement = 40.0,
  })  : assert(model != null),
        assert(sliverItemBuilder != null),
        super(key: key);

  final RefreshPageableListModel<T> model;
  final SliverHeaderBuilder sliverHeaderBuilder;
  final SliverItemBuilder<T> sliverItemBuilder;
  final SliverFooterBuilder sliverFooterBuilder;
  final ScrollPhysics physics;
  final double displacement;

  @override
  State<StatefulWidget> createState() {
    return _RefreshPageableListViewState<T>();
  }
}

enum _RefreshPageableListViewMode {
  list,
  pageable,
  refresh,
}

class _RefreshPageableListViewState<T>
    extends State<RefreshPageableListView<T>> {
  _RefreshPageableListViewMode _mode;
  List<T> data = <T>[];
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _onList();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RefreshPageableListModel>(
      model: widget.model,
      child: ScopedModelDescendant<RefreshPageableListModel>(
        builder: (BuildContext context, Widget child,
            RefreshPageableListModel model) {
          return RefreshIndicator(
            key: _refreshKey,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification) {
                  int page = (notification.metrics.pixels /
                              _refreshKey.currentContext.size.height)
                          .roundToDouble()
                          .toInt() +
                      1;
                  widget.model.onAnalytics(page);
                  if (notification.metrics.axisDirection ==
                          AxisDirection.down &&
                      notification.metrics.extentAfter == 0) {
                    if (_mode == null && !model.isEnd()) {
                      _onPageable(model);
                    }
                  }
                }
                if (_mode == _RefreshPageableListViewMode.list ||
                    _mode == _RefreshPageableListViewMode.pageable) {
                  // 加载更多的适合，不让下拉刷新
                  return true;
                }
                return false;
              },
              child: CustomScrollView(
                physics: widget.physics,
                slivers: <Widget>[
                  data.isNotEmpty && widget.sliverHeaderBuilder != null
                      ? widget.sliverHeaderBuilder()
                      : SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        ),
                  ...data.map((T item) {
                    return widget.sliverItemBuilder(item);
                  }).toList(),
                  data.isNotEmpty && widget.sliverFooterBuilder != null
                      ? widget.sliverFooterBuilder(model.isEnd())
                      : SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        ),
                ],
              ),
            ),
            displacement: widget.displacement,
            onRefresh: () => _onRefresh(model),
          );
        },
      ),
    );
  }

  Future<void> _onList() async {
    setState(() {
      _mode = _RefreshPageableListViewMode.list;
    });
    List<T> newData = await widget.model.onList();
    data = newData;
    setState(() {
      _mode = null;
    });
  }

  Future<void> _onPageable(RefreshPageableListModel model) async {
    setState(() {
      _mode = _RefreshPageableListViewMode.pageable;
    });
    List<T> pageableData = await model.onPageable();
    data.addAll(pageableData);
    setState(() {
      widget.model.onAnalytics(1);
      _mode = null;
    });
  }

  Future<void> _onRefresh(RefreshPageableListModel model) async {
    setState(() {
      _mode = _RefreshPageableListViewMode.refresh;
    });
    List<T> newData = await model.onRefresh();
    data = newData;
    setState(() {
      _mode = null;
    });
  }
}
