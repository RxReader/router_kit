import 'package:flutter/painting.dart';

class Attributes {
  Attributes({
    this.textStyle,
    this.fontSizeFactor = 1.0,
    this.backgroundColor,
  });

  final TextStyle textStyle;
  final double fontSizeFactor;
  final Color backgroundColor;
}
