import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/utility/path_provider.dart';
import 'package:fake_okhttp/fake_okhttp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pedantic/pedantic.dart';

class OkHttpImage extends ImageProvider<NetworkImage> implements NetworkImage {
  const OkHttpImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
  })  : assert(url != null),
        assert(scale != null);

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  @override
  Future<NetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<OkHttpImage>(this);
  }

  @override
  ImageStreamCompleter load(NetworkImage key) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<NetworkImage>('Image key', key),
        ];
      },
    );
  }

  OkHttpClient _client() {
    return OkHttpClientBuilder()
        .addNetworkInterceptor(HttpLoggingInterceptor(LoggingLevel.basic))
        .cache(Cache(DiskCache.create(
            () => PathProvider.buildCacheDir(type: PathProvider.images))))
        .build();
  }

  Future<ui.Codec> _loadAsync(
    NetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    try {
      assert(key == this);
      Uri resolved = Uri.base.resolve(key.url);
      Response resp = await _client()
          .newBuilder()
          .addNetworkInterceptor(ProgressResponseInterceptor((HttpUrl url,
              String method, int progressBytes, int totalBytes, bool isDone) {
            chunkEvents.add(ImageChunkEvent(
              cumulativeBytesLoaded: progressBytes,
              expectedTotalBytes: totalBytes,
            ));
          }))
          .build()
          .newCall(RequestBuilder()
              .get()
              .url(HttpUrl.from(resolved))
              .headers(Headers.of((headers ?? <String, String>{})
                  .map<String, List<String>>((String key, String value) =>
                      MapEntry<String, List<String>>(key, <String>[value]))))
              .build())
          .enqueue();
      if (resp.code() != HttpStatus.ok) {
        throw Exception(
            'HTTP request failed, statusCode: ${resp.code()}, $resolved');
      }
      List<int> bytes = await resp.body().bytes();
      if (bytes.isEmpty) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }
      return PaintingBinding.instance
          .instantiateImageCodec(Uint8List.fromList(bytes));
    } finally {
      unawaited(chunkEvents.close());
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OkHttpImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          scale == other.scale;

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
