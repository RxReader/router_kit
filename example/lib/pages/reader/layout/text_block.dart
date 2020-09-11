import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class ParagraphBlock {
  const ParagraphBlock({
    @required this.composing,
    @required this.paragraph,
    @required this.paragraphCursor,
  });

  final TextRange composing;
  final InlineSpan paragraph;
  final int paragraphCursor;
}

class ParagraphCaretOffset {
  const ParagraphCaretOffset({
    @required this.offset,
    @required this.paragraphCursor,
  });

  final Offset offset;
  final int paragraphCursor;
}

class PageBlock {
  const PageBlock({
    @required this.composing,
    @required this.paragraphBlocks,
    @required this.paragraphCaretOffsets,
  });

  final TextRange composing;
  final List<ParagraphBlock> paragraphBlocks;
  final List<ParagraphCaretOffset> paragraphCaretOffsets;

  static const PageBlock dummy = PageBlock(
    composing: TextRange.empty,
    paragraphBlocks: <ParagraphBlock>[],
    paragraphCaretOffsets: <ParagraphCaretOffset>[],
  );
}
