import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReaderSettings {
  const ReaderSettings();

  TextAlign get textAlign => TextAlign.start;

  TextDirection get textDirection => TextDirection.ltr;

  double get textScaleFactor => 1.0;

  TextStyle get style => TextStyle(
        color: Colors.black,
        fontSize: 14,
        height: 1.0,
      );

  StrutStyle get strutStyle => StrutStyle.disabled;// 必须禁用；不然有可能出现强制行高，影响段间距实现问题。

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
