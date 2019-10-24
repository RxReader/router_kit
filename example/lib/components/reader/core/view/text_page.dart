import 'package:flutter/cupertino.dart';

class TextPage {
  final int startWordCursor;
  final int endWordCursor;
  final List<InlineSpan> spansInPage;
  final Map<int, Offset> paragraphEndOffsetMap;

  TextPage({
    @required this.startWordCursor,
    @required this.endWordCursor,
    @required this.spansInPage,
    @required this.paragraphEndOffsetMap,
  });
}
