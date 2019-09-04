import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

typedef SliverHeaderBuilder = Widget Function();
typedef SliverItemBuilder<T> = List<Widget> Function(List<T> items, T item);
typedef SliverFooterBuilder = Widget Function(
    bool isEnd, bool isPageableFailure, VoidCallback onPageableRetry);
typedef ScrollNotificationCallback = void Function(
    ScrollNotification notification);

Widget _defaultSliverFooterBuilder<T>(
    bool isEnd, bool isPageableFailure, VoidCallback onPageableRetry) {
  return SliverToBoxAdapter(
    child: Builder(
      builder: (BuildContext context) {
        if (isEnd) {
          return Container(
            height: 60,
            alignment: Alignment.center,
            child: Text('--- 我是有底线的 ---'),
          );
        }
        if (isPageableFailure) {
          return GestureDetector(
            onTap: onPageableRetry,
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: Text('加载失败，点击重试'),
            ),
          );
        }
        return Container(
          height: 60,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );
      },
    ),
  );
}

enum _RefreshPageableListViewMode {
  normal,
  init,
  pageable,
  pageableFailure,
  refresh,
}

abstract class RefreshPageableListModel<T> extends Model {
  _RefreshPageableListViewMode _mode = _RefreshPageableListViewMode.normal;
  List<T> _data = <T>[];
  bool _inited = false;

  bool isInited() {
    return _inited;
  }

  @protected
  Future<void> init() async {
    _mode = _RefreshPageableListViewMode.init;
    notifyListeners();

    try {
      List<T> newData = await onInit();
      _data = newData ?? <T>[];
    } catch (e) {}

    _mode = _RefreshPageableListViewMode.normal;
    _inited = true;
    notifyListeners();
  }

  @protected
  Future<void> pageable() async {
    _mode = _RefreshPageableListViewMode.pageable;
    notifyListeners();

    try {
      List<T> pageableData = await onPageable();
      _data.addAll(pageableData ?? <T>[]);
      _mode = _RefreshPageableListViewMode.normal;
    } catch (e) {
      _mode = _RefreshPageableListViewMode.pageableFailure;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    _mode = _RefreshPageableListViewMode.refresh;
    notifyListeners();

    try {
      List<T> newData = await onRefresh();
      _data = newData ?? <T>[];
    } catch (e) {}

    _mode = _RefreshPageableListViewMode.normal;
    notifyListeners();
  }

  @protected
  List<T> getData() {
    return List<T>.unmodifiable(_data);
  }

  @protected
  bool isIdle() {
    return _mode == _RefreshPageableListViewMode.normal ||
        _mode == _RefreshPageableListViewMode.pageableFailure;
  }

  @protected
  bool isRefresh() {
    return _mode == _RefreshPageableListViewMode.refresh;
  }

  @protected
  bool isPageableFailure() {
    return _mode == _RefreshPageableListViewMode.pageableFailure;
  }

  @protected
  bool isRefreshDisable() {
    return _mode == _RefreshPageableListViewMode.init ||
        _mode == _RefreshPageableListViewMode.pageable;
  }

  Future<List<T>> onInit();

  Future<List<T>> onPageable();

  Future<List<T>> onRefresh();

  bool isEnd();
}

class RefreshPageableListView<T> extends StatefulWidget {
  const RefreshPageableListView({
    Key key,
    this.scrollKey,
    @required this.model,
    this.sliverHeaderBuilder,
    @required this.sliverItemBuilder,
    this.sliverFooterBuilder = _defaultSliverFooterBuilder,
    this.displacement = 40.0,
    this.physics,
    this.controller,
    this.notificationCallback,
  })  : assert(model != null),
        assert(sliverItemBuilder != null),
        super(key: key);

  final Key scrollKey;
  final RefreshPageableListModel<T> model;
  final SliverHeaderBuilder sliverHeaderBuilder;
  final SliverItemBuilder<T> sliverItemBuilder;
  final SliverFooterBuilder sliverFooterBuilder;
  final double displacement;
  final ScrollPhysics physics;
  final ScrollController controller;
  final ScrollNotificationCallback notificationCallback;

  @override
  State<StatefulWidget> createState() {
    return RefreshPageableListViewState<T>();
  }
}

class RefreshPageableListViewState<T>
    extends State<RefreshPageableListView<T>> {
  @override
  void initState() {
    super.initState();
    if (!widget.model.isInited()) {
      widget.model.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RefreshPageableListModel<T>>(
      model: widget.model,
      child: ScopedModelDescendant<RefreshPageableListModel<T>>(
        builder: (BuildContext context, Widget child,
            RefreshPageableListModel<T> model) {
          return RefreshIndicator(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.axis == Axis.vertical) {
                  if (widget.notificationCallback != null) {
                    widget.notificationCallback(notification);
                  }
                  if (notification is ScrollEndNotification) {
                    if (notification.metrics.axisDirection ==
                            AxisDirection.down &&
                        notification.metrics.extentAfter == 0) {
                      if (model.isIdle() && !model.isEnd()) {
                        model.pageable();
                      }
                    }
                  }
                  if (model.isRefreshDisable()) {
                    // 加载更多的时候，不让下拉刷新
                    return true;
                  }
                }
                return false;
              },
              child: CustomScrollView(
                key: widget.scrollKey,
                scrollDirection: Axis.vertical,
                physics: widget.physics,
                controller: widget.controller,
                slivers: <Widget>[
                  ...(model.getData().isNotEmpty &&
                          widget.sliverHeaderBuilder != null
                      ? <Widget>[
                          widget.sliverHeaderBuilder(),
                        ]
                      : <Widget>[]),
                  ...model
                      .getData()
                      .map((T item) {
                        return widget.sliverItemBuilder(
                          model.getData(),
                          item,
                        );
                      })
                      .expand((List<Widget> pairs) => pairs)
                      .toList(),
                  ...(model.getData().isNotEmpty &&
                          widget.sliverFooterBuilder != null
                      ? <Widget>[
                          widget.sliverFooterBuilder(
                            model.isEnd(),
                            model.isPageableFailure(),
                            () {
                              if (model.isIdle() && !model.isEnd()) {
                                model.pageable();
                              }
                            },
                          ),
                        ]
                      : <Widget>[]),
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
