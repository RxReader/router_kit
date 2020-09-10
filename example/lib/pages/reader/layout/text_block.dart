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
    @required this.composing,
    @required this.paragraphTextRangeMap,
    @required this.paragraphCaretOffsetMap,
  });

  final TextRange composing;
  final Map<int, TextRange> paragraphTextRangeMap;
  final Map<int, Offset> paragraphCaretOffsetMap;

  static const PageBlock dummy = PageBlock(
    composing: TextRange.empty,
    paragraphTextRangeMap: <int, TextRange>{},
    paragraphCaretOffsetMap: <int, Offset>{},
  );
}
