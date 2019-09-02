import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

mixin AnalyticsModel on Model {
  void onAnalytics(int page) {}
}

mixin RefreshModel<T> on Model {
  Future<T> onRefresh();
}

mixin ListModel<T> on Model {
  Future<List<T>> onList();
}

mixin PageableModel<T> on Model {
  Future<T> onPageable();

  bool isEnd();
}

abstract class RefreshPageableListModel<T> extends Model
    with
        AnalyticsModel,
        RefreshModel<List<T>>,
        ListModel<T>,
        PageableModel<List<T>> {}

typedef SliverHeaderBuilder = Widget Function();
typedef SliverItemBuilder<T> = Widget Function(T item);
typedef SliverFooterBuilder = Widget Function(bool isEnd);
