import 'package:flutter/painting.dart';

class Attributes {
  Attributes({
    this.display,
    this.textStyle,
    this.fontSizeFactor = 1.0,
    this.backgroundColor,
  });

  final Display display;
  final TextStyle textStyle;
  final double fontSizeFactor;
  final Color backgroundColor;
}

enum Display {
  BLOCK,
  LIST_ITEM,
}
