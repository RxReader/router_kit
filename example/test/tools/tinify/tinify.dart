import 'dart:convert';
import 'dart:io';

import 'package:fake_okhttp/fake_okhttp.dart';
import 'package:fake_okhttp/okhttp3/tools/curl_interceptor.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

class Tinify {
  Tinify({
    @required ApiKey apiKey,
    int compressionCount = 0,
  })  : _apiKey = apiKey,
        _compressionCount = compressionCount;

  final ApiKey _apiKey;
  int _compressionCount;

  bool get available => _compressionCount < _apiKey.maxAccessCount;

  Future<List<int>> compress(List<int> bytes) async {
    OkHttpClient client = OkHttpClientBuilder()
        .addNetworkInterceptor(HttpLoggingInterceptor(level: LoggingLevel.body))
        .build();
    Response response = await client
        .newCall(RequestBuilder()
            .url(HttpUrl.parse('https://api.tinify.com/shrink'))
            .post(RequestBody.bytesBody(null, bytes))
            .addHeader(HttpHeaders.authorizationHeader,
                'Basic ${base64.encode(utf8.encode('api:${_apiKey.apiKey}'))}')
            .build())
        .enqueue();
    String compressionCount = response.header('Compression-Count');
//    print('compressionCount: $compressionCount');
    if (compressionCount != null && compressionCount.isNotEmpty) {
      _compressionCount = int.parse(compressionCount);
    }
    if (response.code() >= HttpStatus.ok &&
        response.code() < HttpStatus.multipleChoices) {
      String location = response.header('Location');
      if (location != null && location.isNotEmpty) {
        response = await client
            .newCall(RequestBuilder()
                .url(HttpUrl.parse(location))
                .get()
                .addHeader(
                    HttpHeaders.contentTypeHeader, MediaType.json.toString())
                .addHeader(HttpHeaders.authorizationHeader,
                    'Basic ${base64.encode(Encoding.getByName('iso-8859-1').encode('api:${_apiKey.apiKey}'))}')
                .build())
            .enqueue();
        if (response.code() >= HttpStatus.ok &&
            response.code() < HttpStatus.multipleChoices) {
          return response.body().bytes();
        }
      }
    }
    throw HttpException(
        'Tinify Http: ${response.code()} - ${response.message()}');
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
