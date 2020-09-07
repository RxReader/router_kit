import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class Typeset {
  Typeset({
    @required this.padding,
    @required this.fontSize,
    this.fontFamily,
    @required this.wordSpacing,
    @required this.letterSpacing,
    @required this.textScaleFactor,
  });

  final EdgeInsetsDirectional padding;
  final double fontSize;
  final String fontFamily;
  final double wordSpacing;
  final double letterSpacing;
  final double textScaleFactor;

  Size resolveCanvas(Size canvas) {
    return padding/*.resolve(textDirection)*/.deflateSize(canvas);
  }

  TextStyle resolveTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      wordSpacing: wordSpacing, // 词间距
      letterSpacing: letterSpacing, // 字间距
    );
  }

  TextPainter resolveTextPainter(Locale locale) {
    return TextPainter(
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
    );
  }

  TextAlign get textAlign => TextAlign.start;

  TextDirection get textDirection => TextDirection.ltr;

  /// 禁用；不然有可能出现强制行高，影响富文本布局问题。
  StrutStyle get strutStyle => StrutStyle.disabled;

  static final Typeset defaultTypeset = Typeset(
    padding: EdgeInsetsDirectional.only(start: 20.0, top: 20.0, end: 20.0, bottom: 20.0),
    fontSize: 14.0,
    wordSpacing: 0.0,
    letterSpacing: 0.0,
    textScaleFactor: 1.0,
  );
}
