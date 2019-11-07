import 'package:csslib/parser.dart' as css_parser;
import 'package:example/html/basic_types.dart';
import 'package:example/html/converter.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart' as strings;

class Html {
  Html._();

  static const Map<String, Color> _htmlColorNameMap = <String, Color>{
    'aqua': Color(0xFF00FFFF),
    'black': Colors.black,
    'blue': Color(0xFF0000FF),
    'fuchsia': Color(0xFFFF00FF),
    'gray': Color(0xFF888888),
    'green': Color(0xFF00FF00),
    'lime': Color(0xFF00FF00),
    'maroon': Color(0xFF800000),
    'navy': Color(0xFF000080),
    'olive': Color(0xFF808000),
    'purple': Color(0xFF800080),
    'red': Color(0xFFFF0000),
    'silver': Color(0xFFC0C0C0),
    'teal': Color(0xFF008080),
    'white': Colors.white,
    'yellow': Color(0xFFFFFF00),
  };

  static InlineSpan fromHtml(
    String source, {
    String sourceUrl,
    CustomRender customRender,
    Size window,
    double fontSize = 14.0,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
    TapVideoCallback onTapVideo,
  }) {
    HtmlToSpannedConverter converter = HtmlToSpannedConverter(
      source,
      sourceUrl: sourceUrl,
      customRender: customRender,
      window: window,
      fontSize: fontSize,
      onTapLink: onTapLink,
      onTapImage: onTapImage,
      onTapVideo: onTapVideo,
    );
    return converter.convert();
  }

  static Color parseHtmlColor(String color) {
    Color htmlColor;
    if (strings.isNotEmpty(color)) {
      htmlColor = _htmlColorNameMap[color];
      if (htmlColor == null) {
        if (color.startsWith('#')) {
          color = color.substring(1);
          if (color.length == 3) {
            color = '#FF${color.split('').map((String s) => '$s$s').join('')}';
          } else if (color.length == 6) {
            color = '#FF$color';
          }
        }
        css_parser.Color parsedColor = css_parser.Color.css(color);
        htmlColor = Color(parsedColor.argbValue);
      }
    }
    return htmlColor;
  }

  static String convertHtmlColor(Color color) {
    return css_parser.Color(color.value).cssExpression;
  }

  static double parseHtmlWH(String value, [double refValue]) {
    if (strings.isNotEmpty(value)) {
      if (value.endsWith('%')) {
        value = value.replaceAll('%', '');
        return refValue != null && double.tryParse(value) != null
            ? double.tryParse(value) * refValue
            : null;
      } else {
        value = value.toLowerCase().replaceAll('px', '');
        return double.tryParse(value);
      }
    }
    return null;
  }

  static Map<String, String> parseHtmlStyle(String style) {
    return <String, String>{};
  }
}
