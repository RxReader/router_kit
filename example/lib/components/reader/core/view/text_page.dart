import 'package:flutter/cupertino.dart';

class TextPage {
  final int startWordCursor;
  final int endWordCursor;
  final TextSpan textSpan;
  final Map<int, Offset> paragraphEndOffsetMap;

  TextPage({
    @required this.startWordCursor,
    @required this.endWordCursor,
    @required this.textSpan,
    @required this.paragraphEndOffsetMap,
  });
}
