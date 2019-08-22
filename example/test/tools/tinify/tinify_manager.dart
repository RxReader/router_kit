import 'dart:io';

import 'tinify.dart';

class TinifyManager {
  TinifyManager._();

  factory TinifyManager.get() {
    return _instance;
  }

  static final TinifyManager _instance = TinifyManager._();

  static const List<ApiKey> apiKeys = <ApiKey>[
    ApiKey(
      email: 'v7lin@qq.com',
      apiKey: '3OzjN0gt7T3Gq73PZS9GJnsH6JnwBWOl',
    ),
    ApiKey(
      email: '912404846@qq.com',
      apiKey: 'wcMMlmg5BkwRqmXQycyk2HVdl90G9rnm',
    ),
  ];

  int _cursor = 0;
  Tinify _tinify;

  List<int> compress(List<int> bytes) {
    if (_tinify == null || !_tinify.available) {
      _tinify = _createTinify();
    }
    if (_tinify == null) {
      throw UnsupportedError('no available tinify');
    }
    return _tinify.compress(bytes);
  }

  Tinify _createTinify() {
    if (_cursor < apiKeys.length) {
      return Tinify(apiKey: apiKeys[_cursor++]);
    }
    return null;
  }
}
