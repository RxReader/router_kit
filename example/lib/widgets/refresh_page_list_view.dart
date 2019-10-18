import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

typedef SliverWidgetBuilder = List<Widget> Function(BuildContext context);
typedef SliverTapWidgetBuilder = List<Widget> Function(
    BuildContext context, VoidCallback onTap);
typedef SliverHeaderBuilder = List<Widget> Function(
    BuildContext context, bool isEmpty);
typedef SliverBodyBuilder<T> = List<Widget> Function(
    BuildContext context, T data);
typedef SliverFooterBuilder = List<Widget> Function(BuildContext context,
    bool isEnd, bool isPagedError, VoidCallback onPagingRetry);

enum _RefreshPageListViewMode {
  none,
  loading,
  empty,
  error,
  paging,
  pagedError,
  refreshing,
}

abstract class ObjectModel<T> extends Model {
  _RefreshPageListViewMode _mode = _RefreshPageListViewMode.none;

  Key _modelKey = GlobalKey();
  T _data;
  bool _inited = false;

  bool get isInited {
    return _inited;
  }

  @protected
  Future<void> tryInit(bool retry) async {
    _mode = _RefreshPageListViewMode.loading;
    notifyListeners();

    try {
      T newData = await onInit(retry);
      _data = newData;
      _mode = _emptyLike(_data)
          ? _RefreshPageListViewMode.empty
          : _RefreshPageListViewMode.none;
    } catch (e) {
      _mode = _RefreshPageListViewMode.error;
    }

    if (retry) {
      _modelKey = GlobalKey();
    }

    _inited = true;
    notifyListeners();
  }

  bool _emptyLike(T data) {
    return data == null;
  }

  Future<T> onInit(bool retry);

  @protected
  Key get modelKey => _modelKey;

  @protected
  T get data {
    return _data;
  }

  bool get isLoading {
    return _mode == _RefreshPageListViewMode.loading;
  }

  bool get isEmpty {
    return _mode == _RefreshPageListViewMode.empty;
  }

  bool get isError {
    return _mode == _RefreshPageListViewMode.error;
  }

  bool get isIdle {
    return _mode == _RefreshPageListViewMode.none ||
        _mode == _RefreshPageListViewMode.pagedError;
  }

  @protected
  M cast<M extends ObjectModel<T>>() {
    return this is M ? this as M : null;
  }

  static M of<T, M extends ObjectModel<T>>(BuildContext context) {
    return ScopedModel.of<ObjectModel<T>>(context) as M;
  }
}

mixin RefreshableModel<T> on ObjectModel<T> {
  @protected
  Future<void> tryRefresh() async {
    _RefreshPageListViewMode lastMode = _mode;
    _mode = _RefreshPageListViewMode.refreshing;
    notifyListeners();

    try {
      T newData = await onRefresh();
      _data = newData;
      _mode = _emptyLike(_data)
          ? _RefreshPageListViewMode.empty
          : _RefreshPageListViewMode.none;

      _modelKey = GlobalKey();
    } catch (e) {
      if (lastMode == _RefreshPageListViewMode.empty) {
        _mode = _RefreshPageListViewMode.error;
        _modelKey = GlobalKey();
      } else {
        _mode = _RefreshPageListViewMode.none;
      }
    }

    notifyListeners();
  }

  Future<T> onRefresh();

  bool get isRefreshing {
    return _mode == _RefreshPageListViewMode.refreshing;
  }

  @protected
  bool get isRefreshEnable {
    return _mode != _RefreshPageListViewMode.loading &&
        _mode != _RefreshPageListViewMode.error &&
        _mode != _RefreshPageListViewMode.paging;
  }
}

mixin ListModel<T> on ObjectModel<List<T>> {
  @override
  bool _emptyLike(List<T> data) {
    if (data == null || data.isEmpty) {
      return true;
    }
    return super._emptyLike(data);
  }

  @override
  List<T> get data => super.data != null ? List.unmodifiable(super.data) : null;
}

mixin PageableModel<T> on ListModel<T> {
  @protected
  Future<void> tryPaging() async {
    _mode = _RefreshPageListViewMode.paging;
    notifyListeners();

    try {
      List<T> pagingData = await onPaging();
      _data.addAll(pagingData ?? <T>[]);
      _mode = _RefreshPageListViewMode.none;
    } catch (e) {
      _mode = _RefreshPageListViewMode.pagedError;
    }

    notifyListeners();
  }

  Future<List<T>> onPaging();

  bool get isEnd;

  bool get isPaging {
    return _mode == _RefreshPageListViewMode.paging;
  }

  bool get isPagedError {
    return _mode == _RefreshPageListViewMode.pagedError;
  }
}

class RefreshPageView<T> extends StatefulWidget {
  const RefreshPageView({
    Key key,
    this.scrollKey,
    @required this.model,
    @required this.sliverBodyBuilder,
    SliverWidgetBuilder sliverLoadingBuilder,
    SliverWidgetBuilder sliverEmptyBuilder,
    SliverTapWidgetBuilder sliverErrorBuilder,
    this.displacement = 40.0,
    this.physics,
    this.controller,
    this.cacheExtent = 100.0,
  })  : sliverLoadingBuilder = sliverLoadingBuilder ?? null,
        sliverEmptyBuilder = sliverEmptyBuilder ?? null,
        sliverErrorBuilder = sliverErrorBuilder ?? null,
        super(key: key);

  final Key scrollKey;
  final ObjectModel<T> model;
  final SliverBodyBuilder<T> sliverBodyBuilder;
  final SliverWidgetBuilder sliverLoadingBuilder;
  final SliverWidgetBuilder sliverEmptyBuilder;
  final SliverTapWidgetBuilder sliverErrorBuilder;
  final double displacement;
  final ScrollPhysics physics;
  final ScrollController controller;
  final double cacheExtent;

  @override
  State<StatefulWidget> createState() {
    return _RefreshPageViewState<T>();
  }
}

class _RefreshPageViewState<T> extends State<RefreshPageView<T>> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ObjectModel<T>>(
      model: widget.model,
      child: ScopedModelDescendant<ObjectModel<T>>(
        builder: (BuildContext context, Widget child, ObjectModel<T> model) {
          RefreshableModel<T> refreshableModel =
              model.cast<RefreshableModel<T>>();
          Widget child = Builder(
            key: model.modelKey, // 刷新后必须清理列表里的 StatefulWidget 的 State
            builder: (BuildContext context) {
              return CustomScrollView(
                key: widget.scrollKey,
                scrollDirection: Axis.vertical,
                physics: widget.physics,
                controller: widget.controller,
                cacheExtent: widget.cacheExtent,
                slivers: <Widget>[
                  ..._buildSliverBody(context, model),
                ],
              );
            },
          );
          return refreshableModel != null
              ? RefreshIndicator(
                  child: child,
                  displacement: widget.displacement,
                  onRefresh: refreshableModel.tryRefresh,
                )
              : child;
        },
      ),
    );
  }

  List<Widget> _buildSliverBody(BuildContext context, ObjectModel<T> model) {
    if (model.isLoading) {
      return widget.sliverLoadingBuilder(context);
    }
    if (model.isEmpty) {
      return widget.sliverEmptyBuilder(context);
    }
    if (model.isError) {
      return widget.sliverErrorBuilder(context, () {
        model.tryInit(true);
      });
    }
    return widget.sliverBodyBuilder(context, model.data);
  }
}

class RefreshPageListView<T> extends StatefulWidget {
  RefreshPageListView({
    Key key,
    this.scrollKey,
    @required this.model,
    this.sliverHeaderBuilder,
    @required this.sliverBodyBuilder,
    SliverFooterBuilder sliverFooterBuilder,
    SliverWidgetBuilder sliverLoadingBuilder,
    SliverWidgetBuilder sliverEmptyBuilder,
    SliverTapWidgetBuilder sliverErrorBuilder,
    this.displacement = 40.0,
    this.physics,
    this.controller,
    this.cacheExtent = 100.0,
  })  : assert(model != null),
        sliverFooterBuilder =
            sliverFooterBuilder ?? (model is PageableModel<T> ? null : null),
        sliverLoadingBuilder = sliverLoadingBuilder ?? null,
        sliverEmptyBuilder = sliverEmptyBuilder ?? null,
        sliverErrorBuilder = sliverErrorBuilder ?? null,
        assert(sliverBodyBuilder != null),
        super(key: key);

  final Key scrollKey;
  final ListModel<T> model;
  final SliverHeaderBuilder sliverHeaderBuilder;
  final SliverBodyBuilder<List<T>> sliverBodyBuilder;
  final SliverFooterBuilder sliverFooterBuilder;
  final SliverWidgetBuilder sliverLoadingBuilder;
  final SliverWidgetBuilder sliverEmptyBuilder;
  final SliverTapWidgetBuilder sliverErrorBuilder;
  final double displacement;
  final ScrollPhysics physics;
  final ScrollController controller;
  final double cacheExtent;

  @override
  State<StatefulWidget> createState() {
    return _RefreshPageListViewState<T>();
  }
}

class _RefreshPageListViewState<T> extends State<RefreshPageListView<T>> {
  @override
  void initState() {
    super.initState();
    if (!widget.model.isInited) {
      widget.model.tryInit(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ListModel<T>>(
      model: widget.model,
      child: ScopedModelDescendant<ListModel<T>>(
        builder: (BuildContext context, Widget child, ListModel<T> model) {
          PageableModel<T> pageableModel = model.cast<PageableModel<T>>();
          RefreshableModel<List<T>> refreshableModel =
              model.cast<RefreshableModel<List<T>>>();
          Widget child = Builder(
            key: model.modelKey, // 刷新后必须清理列表里的 StatefulWidget 的 State
            builder: (BuildContext context) {
              return CustomScrollView(
                key: widget.scrollKey,
                scrollDirection: Axis.vertical,
                physics: widget.physics,
                controller: widget.controller,
                cacheExtent: widget.cacheExtent,
                slivers: <Widget>[
                  ..._buildSliverHeader(context, model),
                  ..._buildSliverBody(context, model),
                  ..._buildSliverFooter(context, model, pageableModel),
                ],
              );
            },
          );
          child = NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.axis == Axis.vertical) {
                if (notification is ScrollEndNotification) {
                  if (notification.metrics.axisDirection ==
                          AxisDirection.down &&
                      notification.metrics.extentAfter == 0) {
                    if (pageableModel != null) {
                      if (model.isIdle && !pageableModel.isEnd) {
                        pageableModel.tryPaging();
                      }
                    }
                  }
                }
                if (notification is OverscrollNotification) {
                  if (refreshableModel != null &&
                      !refreshableModel.isRefreshEnable) {
                    // 加载更多的时候，不让下拉刷新
                    return true;
                  }
                }
              }
              return false;
            },
            child: child,
          );
          return refreshableModel != null
              ? RefreshIndicator(
                  child: child,
                  displacement: widget.displacement,
                  onRefresh: refreshableModel.tryRefresh,
                )
              : child;
        },
      ),
    );
  }

  List<Widget> _buildSliverHeader(BuildContext context, ListModel<T> model) {
    return widget.sliverHeaderBuilder != null
        ? widget.sliverHeaderBuilder(context, model.data.isEmpty)
        : <Widget>[];
  }

  List<Widget> _buildSliverBody(BuildContext context, ListModel<T> model) {
    if (model.isLoading) {
      return widget.sliverLoadingBuilder(context);
    }
    if (model.isEmpty) {
      return widget.sliverEmptyBuilder(context);
    }
    if (model.isError) {
      return widget.sliverErrorBuilder(context, () {
        model.tryInit(true);
      });
    }
    return widget.sliverBodyBuilder(context, model.data);
  }

  List<Widget> _buildSliverFooter(BuildContext context, ListModel<T> model,
      PageableModel<T> pageableModel) {
    return model.data.isNotEmpty && widget.sliverFooterBuilder != null
        ? widget.sliverFooterBuilder(
            context,
            pageableModel == null || pageableModel.isEnd,
            pageableModel != null && pageableModel.isPagedError,
            () {
              if (pageableModel != null) {
                if (model.isIdle && !pageableModel.isEnd) {
                  pageableModel.tryPaging();
                }
              }
            },
          )
        : <Widget>[];
  }
}
