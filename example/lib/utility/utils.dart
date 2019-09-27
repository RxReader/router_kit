import 'package:flutter/services.dart';

class Utils {
  Utils._();

  static const MethodChannel _channel = MethodChannel('app');

  static Future<String> getNativeLibraryDir() {
    return _channel.invokeMethod('getNativeLibraryDir');
  }
}
