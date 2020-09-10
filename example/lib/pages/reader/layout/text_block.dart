import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

//class ParagraphBlock {
//  const ParagraphBlock({
//    @required this.range,
//    @required this.paragraphCursor,
//  });
//
//  final TextRange range;
//  final int paragraphCursor;
//}

class PageBlock {
  const PageBlock({
    @required this.range,
    @required this.paragraphCaretOffsetMap,
  });

  final TextRange range;
  final Map<int, Offset> paragraphCaretOffsetMap;

  static const PageBlock dummy = PageBlock(
    range: TextRange.empty,
    paragraphCaretOffsetMap: <int, Offset>{},
  );
}
