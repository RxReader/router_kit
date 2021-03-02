import 'package:flutter/foundation.dart';

abstract class Base {
  const Base({
    @required this.code,
    @required this.msg,
  });

  final int code;
  final String msg;
}
