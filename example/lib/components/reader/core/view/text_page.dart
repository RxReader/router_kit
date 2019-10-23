import 'package:flutter/cupertino.dart';

class TextPage {
  final int startWordCursor;
  final int endWordCursor;
  final String content;
  final List<InlineSpan> children;

  TextPage({
    @required this.startWordCursor,
    @required this.endWordCursor,
    @required this.content,
    @required this.children,
  });
}
