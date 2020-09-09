import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class StyleSpan {
  double get width;
  double get height;
}

class StyleWidgetSpan extends WidgetSpan implements StyleSpan {
  StyleWidgetSpan({
    @required Widget child,
    @required this.placeholder,
    @required this.width,
    @required this.height,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline baseline,
    TextStyle style,
  }): super(child: child, alignment: alignment, baseline: baseline, style: style);

  final String placeholder;
  @override
  final double width;
  @override
  final double height;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    if (includePlaceholders) {
      buffer.write(placeholder);
    }
  }
}

class SubWidgetSpan extends WidgetSpan implements StyleSpan {
  SubWidgetSpan({
    @required this.textSpan,
    @required this.width,
    @required this.height,
    TextBaseline baseline,
    TextStyle style,
  }): super(child: Text.rich(textSpan, textScaleFactor: 0), alignment: ui.PlaceholderAlignment.bottom, baseline: baseline, style: style);

  final TextSpan textSpan;
  @override
  final double width;
  @override
  final double height;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    StringBuffer innerBuffer = StringBuffer();
    textSpan.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    buffer.write('<sub>$innerBuffer</sub>');
  }
}

class SupWidgetSpan extends WidgetSpan implements StyleSpan {
  SupWidgetSpan({
    @required this.textSpan,
    @required this.width,
    @required this.height,
    TextBaseline baseline,
    TextStyle style,
  }): super(child: Text.rich(textSpan, textScaleFactor: 0), alignment: ui.PlaceholderAlignment.top, baseline: baseline, style: style);

  final TextSpan textSpan;
  @override
  final double width;
  @override
  final double height;

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    StringBuffer innerBuffer = StringBuffer();
    textSpan.computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    buffer.write('<sup>$innerBuffer</sup>');
  }
}