import 'package:meta/meta.dart';

class Tinify {
  Tinify({
    @required ApiKey apiKey,
    int compressionCount = 0,
  })  : _apiKey = apiKey,
        _compressionCount = compressionCount;

  final ApiKey _apiKey;
  int _compressionCount;

  bool get available => _compressionCount < _apiKey.maxAccessCount;

  List<int> compress(List<int> bytes) {
    return bytes;
  }
}

class ApiKey {
  const ApiKey({
    this.email,
    @required this.apiKey,
    this.maxAccessCount = 500,
  });

  final String email;
  final String apiKey;
  final int maxAccessCount;
}
