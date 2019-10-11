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
    Color linkColor,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
  }) {
    HtmlToSpannedConverter converter = HtmlToSpannedConverter(source);
    return converter.convert();
  }
}

class HtmlToSpannedConverter {
  final String source;
  final CustomRender customRender;
  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;

  HtmlToSpannedConverter(
    this.source, {
    this.customRender,
    this.onTapLink,
    this.onTapImage,
  });

  InlineSpan convert() {
    dom.Document document = html_parser.parse(source);
    return _parseNode(document.body);
  }

  InlineSpan _parseNode(dom.Node node) {
    if (customRender != null) {
      InlineSpan customSpan = customRender(node, _parseNodes(node.nodes));
      if (customSpan != null) {
        return customSpan;
      }
    }
    if (node is dom.Element) {
      switch (node.localName) {
        case 'a':
          return _aRender(node, _parseNodes(node.nodes));
        case 'body':
          return _bodyRender(node, _parseNodes(node.nodes));
        case 'font':
          return _fontRender(node, _parseNodes(node.nodes));
      }
    } else if (node is dom.Text) {
      return TextSpan(text: node.text);
    }
    return TextSpan(text: '暂不支持');
  }

  InlineSpan _aRender(dom.Node node, List<InlineSpan> children) {
    return TextSpan(
      children: children,
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

  InlineSpan _bodyRender(dom.Element node, List<InlineSpan> children) {
    return TextSpan(
      children: children,
    );
  }

  InlineSpan _fontRender(dom.Element node, List<InlineSpan> children) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size'];
    return TextSpan(
      style: TextStyle(
        color: _parseHtmlColor(color),
        fontSize: double.tryParse(size),
        fontFamily: face,
      ),
      children: children,
    );
  }

  List<InlineSpan> _parseNodes(List<dom.Node> nodes) {
    return nodes.map((dom.Node node) {
      return _parseNode(node);
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
