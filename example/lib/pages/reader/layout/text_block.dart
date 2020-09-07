import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

abstract class TextBlock {
  const TextBlock({
    this.startWordCursor,
    this.endWordCursor,
  });

  final int startWordCursor;
  final int endWordCursor;
}

class ParagraphBlock extends TextBlock {
  const ParagraphBlock({
    @required int startWordCursor,
    @required int endWordCursor,
    @required this.paragraphCursor,
    @required this.paragraphWordCursor,
  }) : super(
          startWordCursor: startWordCursor,
          endWordCursor: endWordCursor,
        );

  final int paragraphCursor;
  final int paragraphWordCursor;
}

class PageBlock extends TextBlock {
  const PageBlock({
    @required int startWordCursor,
    @required int endWordCursor,
    @required this.paragraphBlocks,
//    @required this.paragraphSpans,
    @required this.paragraphCaretOffsetMap,
  }) : super(
          startWordCursor: startWordCursor,
          endWordCursor: endWordCursor,
        );

  final List<ParagraphBlock> paragraphBlocks;
//  final List<InlineSpan> paragraphSpans;
  final Map<int, Offset> paragraphCaretOffsetMap;

  static const PageBlock dummy = PageBlock(
    startWordCursor: 0,
    endWordCursor: 0,
    paragraphBlocks: <ParagraphBlock>[],
//    paragraphSpans: <InlineSpan>[],
    paragraphCaretOffsetMap: <int, Offset>{},
  );
}
