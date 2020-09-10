import 'dart:ui' as ui;

import 'package:example/pages/reader/layout/text_symbol.dart';
import 'package:flutter/material.dart';

class StyleSwapperTextSpan extends TextSpan {
  StyleSwapperTextSpan({
    @required this.wrapped,
  }) : super(
          text: TextSymbol.zeroWidthSpace,
          style: wrapped.style.copyWith(
            fontSize: _generateFontSize(TextSymbol.zeroWidthSpace, wrapped.height),
            letterSpacing: wrapped.width,
          ),
        );

  final StyleWidgetSpan wrapped;

  static double _generateFontSize(String text, double height) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr
    );
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: height,
      ),
    );
    painter.layout();
    return height * height / painter.height;
  }
}

abstract class StyleWidgetSpan extends WidgetSpan {
  StyleWidgetSpan({
    @required Widget child,
    @required this.width,
    @required this.height,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline baseline,
    @required TextStyle style,
  }) : super(child: child, alignment: alignment, baseline: baseline, style: style);

  final double width;
  final double height;

  StyleSwapperTextSpan swapper() {
    return StyleSwapperTextSpan(wrapped: this);
  }

  static InlineSpan swap(InlineSpan span) {
    if (span is StyleWidgetSpan) {
      return span.swapper();
    }
    if (span is TextSpan) {
      return TextSpan(
        text: span.text,
        children: span.children?.map((InlineSpan child) => swap(child))?.toList(),
        style: span.style,
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    }
    return span;
  }

  static InlineSpan reverseSwap(InlineSpan span) {
    if (span is StyleSwapperTextSpan) {
      return span.wrapped;
    }
    if (span is TextSpan) {
      return TextSpan(
        text: span.text,
        children: span.children.map((InlineSpan child) => reverseSwap(child)).toList(),
        style: span.style,
        recognizer: span.recognizer,
        semanticsLabel: span.semanticsLabel,
      );
    }
    return span;
  }
}

class GenericStyleWidgetSpan extends StyleWidgetSpan {
  GenericStyleWidgetSpan({
    @required Widget child,
    @required this.placeholder,
    @required double width,
    @required double height,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline baseline,
    @required TextStyle style,
  }) : super(child: child, width: width, height: height, alignment: alignment, baseline: baseline, style: style);

  final String placeholder;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    if (includePlaceholders) {
      buffer.write(placeholder);
    }
  }
}

class SubWidgetSpan extends StyleWidgetSpan {
  SubWidgetSpan({
    @required this.textSpan,
    @required double width,
    @required double height,
    TextBaseline baseline,
    @required TextStyle style,
  }) : super(child: Text.rich(textSpan, textScaleFactor: 0), width: width, height: height, alignment: ui.PlaceholderAlignment.bottom, baseline: baseline, style: style);

  final TextSpan textSpan;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    StringBuffer innerBuffer = StringBuffer();
    textSpan.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    buffer.write('<sub>$innerBuffer</sub>');
  }
}

class SupWidgetSpan extends StyleWidgetSpan {
  SupWidgetSpan({
    @required this.textSpan,
    @required double width,
    @required double height,
    TextBaseline baseline,
    @required TextStyle style,
  }) : super(child: Text.rich(textSpan, textScaleFactor: 0), width: width, height: height, alignment: ui.PlaceholderAlignment.top, baseline: baseline, style: style);

  final TextSpan textSpan;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    StringBuffer innerBuffer = StringBuffer();
    textSpan.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    buffer.write('<sup>$innerBuffer</sup>');
  }
}
