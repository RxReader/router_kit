import 'package:example/widgets/refresh_pageable_list_view.dart';

class TestModel extends RefreshPageableListModel<String> {
  TestModel(this.name);

  static const int _pageSize = 10;

  final String name;

  int _pageIndex = 0;

  @override
  bool isEnd() {
    return _pageIndex >= 9;
  }

  @override
  Future<List<String>> onInit() async {
    print('onInit: $name');
    await Future<void>.delayed(Duration(seconds: 3));
    _pageIndex = 0;
    List<String> result =
        List<String>.generate(_pageSize, (int index) => 'Index: $index');
    return result;
  }

  @override
  Future<List<String>> onPageable() async {
    print('onPageable: $name - ${_pageIndex + 1}');
    await Future<void>.delayed(Duration(seconds: 3));
    _pageIndex++;
    List<String> result = List<String>.generate(
        _pageSize, (int index) => 'Index: ${_pageIndex * _pageSize + index}');
    return result;
  }

  @override
  Future<List<String>> onRefresh() async {
    print('onRefresh: $name');
    await Future<void>.delayed(Duration(seconds: 3));
    _pageIndex = 0;
    List<String> result =
        List<String>.generate(_pageSize, (int index) => 'Index: $index');
    return result;
  }
}
