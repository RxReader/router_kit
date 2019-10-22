import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReaderSettings {
  const ReaderSettings();

  @protected
  TextAlign get textAlign => TextAlign.start;

  @protected
  TextDirection get textDirection => TextDirection.ltr;

  @protected
  double get textScaleFactor => 1.0;

  TextStyle get style => TextStyle(
        color: Colors.black,
        fontSize: 14,
      );

  StrutStyle get strutStyle => StrutStyle.fromTextStyle(style);

  @protected
  Locale get locale => Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

  TextPainter get textPainter {
    return TextPainter(
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
    );
  }
}
