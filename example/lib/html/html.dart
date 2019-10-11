import 'package:csslib/parser.dart' as css_parser;
import 'package:example/html/basic_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

class Html {
  Html._();

  static InlineSpan fromHtml(
    String source, {
    CustomRender customRender,
    double fontSize = 14.0,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
  }) {
    HtmlToSpannedConverter converter = HtmlToSpannedConverter(
      source,
      customRender: customRender,
      fontSize: fontSize,
      onTapLink: onTapLink,
      onTapImage: onTapImage,
    );
    return converter.convert();
  }
}

class HtmlToSpannedConverter {
  const HtmlToSpannedConverter(
    this.source, {
    this.customRender,
    this.fontSize = 14.0,
    this.onTapLink,
    this.onTapImage,
  });

  final String source;
  final CustomRender customRender;
  final double fontSize;
  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;

  InlineSpan convert() {
    assert(fontSize != null);
    dom.Document document = html_parser.parse(source);
    return _parseNode(document.body, fontSize);
  }

  InlineSpan _parseNode(dom.Node node, double fontSize) {
//    List<InlineSpan> children = _parseNodes(node.nodes);
//    if (customRender != null) {
//      InlineSpan customSpan = customRender(node, children);
//      if (customSpan != null) {
//        return customSpan;
//      }
//    }
    if (node is dom.Element) {
      switch (node.localName) {
        case 'a':
          return _aRender(node, fontSize);
        case 'abbr':
        case 'acronym':
          return _abbrRender(node, fontSize);
        case 'address':
        case 'cite':
        case 'em':
        case 'i':
        case 'var':
          return _italicRender(node, fontSize);
        case 'b':
        case 'strong':
          return _boldRender(node, fontSize);
        case 'big':
          return _bigRender(node, fontSize);
        case 'body':
          return _bodyRender(node, fontSize);
        case 'code':
        case 'kbd':
        case 'samp':
        case 'tt':
          return _monospaceRender(node, fontSize);
        case 'font':
          return _fontRender(node, fontSize);
        case 'ins':
        case 'u':
          return _underlineRender(node, fontSize);
        case 'small':
          return _smallRender(node, fontSize);
      }
    } else if (node is dom.Text) {
      return TextSpan(text: node.text);
    }
    return TextSpan(text: '暂不支持');
  }

  InlineSpan _aRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        color: _htmlColorNameMap['green'],
        decoration: TextDecoration.underline,
        decorationColor: _htmlColorNameMap['green'],
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          String target = node.attributes['target'];
          String media = node.attributes['media'];
          String mimeType = node.attributes['type'];
          String url = node.attributes['href'];
          onTapLink?.call(target, media, mimeType, url);
        },
    );
  }

  InlineSpan _abbrRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
    );
  }

  InlineSpan _italicRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  InlineSpan _boldRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InlineSpan _bigRender(dom.Node node, double fontSize) {
    fontSize *= 1.25;
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }

  InlineSpan _bodyRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
    );
  }

  InlineSpan _monospaceRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        fontFamily: 'monospace',
      ),
    );
  }

  InlineSpan _fontRender(dom.Node node, double fontSize) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size']; // 1 - 7，默认：3
    fontSize *= (double.tryParse(size) ?? 3.0) / 3.0;
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        color: _parseHtmlColor(color),
        fontSize: fontSize,
        fontFamily: face,
      ),
    );
  }

  InlineSpan _underlineRender(dom.Node node, double fontSize) {
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        decoration: TextDecoration.underline,
      ),
    );
  }

  InlineSpan _smallRender(dom.Node node, double fontSize) {
    fontSize *= 0.8;
    return TextSpan(
      children: _parseNodes(node.nodes, fontSize),
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }

  List<InlineSpan> _parseNodes(List<dom.Node> nodes, double fontSize) {
    return nodes.map((dom.Node node) {
      return _parseNode(node, fontSize);
    }).toList();
  }
}

const Map<String, Color> _htmlColorNameMap = <String, Color>{
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

Color _parseHtmlColor(String color) {
  Color htmlColor = _htmlColorNameMap[color];
  if (htmlColor == null) {
    css_parser.Color parsedColor = css_parser.Color.css(color);
    htmlColor = Color(parsedColor.argbValue);
  }
  return htmlColor;
}
