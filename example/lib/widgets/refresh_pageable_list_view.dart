import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

typedef SliverHeaderBuilder = Widget Function();
typedef SliverItemBuilder<T> = Widget Function(T item);
typedef SliverFooterBuilder = Widget Function(bool isEnd);

enum _RefreshPageableListViewMode {
  list,
  pageable,
  refresh,
}

abstract class RefreshPageableListModel<T> extends Model {
  _RefreshPageableListViewMode _mode;
  List<T> _data = <T>[];

  @protected
  Future<void> list() async {
    _mode = _RefreshPageableListViewMode.list;
    notifyListeners();

    List<T> newData = await onList();
    _data = newData;

    _mode = null;
    notifyListeners();
  }

  @protected
  Future<void> pageable() async {
    _mode = _RefreshPageableListViewMode.pageable;
    notifyListeners();

    List<T> pageableData = await onPageable();
    _data.addAll(pageableData);

    onScrollTo(1);
    _mode = null;
    notifyListeners();
  }

  @protected
  Future<void> refresh() async {
    _mode = _RefreshPageableListViewMode.refresh;
    notifyListeners();

    List<T> newData = await onRefresh();
    _data = newData;

    _mode = null;
    notifyListeners();
  }

  List<T> getData() {
    return _data;
  }

  bool isIdle() {
    return _mode == null;
  }

  bool isRefresh() {
    return _mode == _RefreshPageableListViewMode.refresh;
  }

  bool isRefreshDisable() {
    return _mode == _RefreshPageableListViewMode.list ||
        _mode == _RefreshPageableListViewMode.pageable;
  }

  void onScrollTo(int page) {}

  Future<List<T>> onRefresh();

  Future<List<T>> onList();

  Future<List<T>> onPageable();

  bool isEnd();
}

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

class _RefreshPageableListViewState<T>
    extends State<RefreshPageableListView<T>> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    widget.model.list();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RefreshPageableListModel<T>>(
      model: widget.model,
      child: ScopedModelDescendant<RefreshPageableListModel<T>>(
        builder: (BuildContext context, Widget child,
            RefreshPageableListModel<T> model) {
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
                  model.onScrollTo(page);
                  if (notification.metrics.axisDirection ==
                          AxisDirection.down &&
                      notification.metrics.extentAfter == 0) {
                    if (model.isIdle() && !model.isEnd()) {
                      model.pageable();
                    }
                  }
                }
                if (model.isRefreshDisable()) {
                  // 加载更多的适合，不让下拉刷新
                  return true;
                }
                return false;
              },
              child: CustomScrollView(
                physics: widget.physics,
                slivers: <Widget>[
                  model.getData().isNotEmpty && widget.sliverHeaderBuilder != null
                      ? widget.sliverHeaderBuilder()
                      : SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        ),
                  ...model.getData().map((T item) {
                    return widget.sliverItemBuilder(item);
                  }).toList(),
                  model.getData().isNotEmpty && widget.sliverFooterBuilder != null
                      ? widget.sliverFooterBuilder(model.isEnd())
                      : SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        ),
                ],
              ),
            ),
            displacement: widget.displacement,
            onRefresh: model.refresh,
          );
        },
      ),
    );
  }
}
