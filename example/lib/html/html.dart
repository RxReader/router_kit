import 'dart:ui' as ui;

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

enum Leading {
  none,
  number,
  dotted,
}

String _convertLeading(Leading leading, int index) {
  switch (leading) {
    case Leading.none:
      return '';
    case Leading.number:
      return '${index + 1}.';
    case Leading.dotted:
      return '•';
  }
}

class HtmlParseContext {
  final int index;
  final int indentLevel;
  final Leading leading;
  final double fontSize;

  HtmlParseContext({
    this.fontSize,
  })  : index = 0,
        indentLevel = 0,
        leading = Leading.none;

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    int indentLevel,
    this.leading = Leading.none,
    double fontSize,
  })  : index = 0,
        indentLevel = indentLevel ?? context.indentLevel,
        fontSize = fontSize ?? context.fontSize;

  HtmlParseContext.indexContext(
    HtmlParseContext context, {
    this.index = 0,
  })  : indentLevel = context.indentLevel,
        leading = context.leading,
        fontSize = context.fontSize;
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
    return _parseNode(document.body, HtmlParseContext(fontSize: fontSize));
  }

  InlineSpan _parseNode(dom.Node node, HtmlParseContext context) {
    if (customRender != null) {
      InlineSpan customSpan = customRender(node, context, _parseNodes);
      if (customSpan != null) {
        return customSpan;
      }
    }
    if (node is dom.Element) {
      switch (node.localName) {
        case 'a':
          return _aRender(node, context);
        case 'abbr':
        case 'acronym':
          return _abbrRender(node, context);
        case 'address':
        case 'cite':
        case 'em':
        case 'i':
        case 'var':
          return _italicRender(node, context);
        case 'b':
        case 'strong':
          return _boldRender(node, context);
        case 'big':
          return _bigRender(node, context);
        case 'blockquote':
          return _blockquoteRender(node, context);
        case 'body':
          return _bodyRender(node, context);
        case 'code':
        case 'kbd':
        case 'samp':
        case 'tt':
          return _monospaceRender(node, context);
        case 'del':
        case 's':
        case 'strike':
          return _strikeRender(node, context);
        case 'font':
          return _fontRender(node, context);
        case 'li':
          return _liRender(node, context);
        case 'ol':
          return _olRender(node, context);
        case 'ins':
        case 'u':
          return _underlineRender(node, context);
        case 'mark':
          return _markRender(node, context);
        case 'small':
          return _smallRender(node, context);
        case 'ul':
          return _ulRender(node, context);
      }
    } else if (node is dom.Text) {
      return TextSpan(text: node.text);
    }
    return TextSpan(text: '暂不支持');
  }

  InlineSpan _aRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
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

  InlineSpan _abbrRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
    );
  }

  InlineSpan _italicRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  InlineSpan _boldRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InlineSpan _bigRender(dom.Node node, HtmlParseContext context) {
    double fontSize = context.fontSize * 1.25;
    return TextSpan(
      children: _parseNodes(node.nodes,
          HtmlParseContext.nextContext(context, fontSize: fontSize)),
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }

  InlineSpan _blockquoteRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: <InlineSpan>[
        WidgetSpan(
          child: Text('\r\r\r\r'),
          alignment: ui.PlaceholderAlignment.middle,
        ),
        ..._parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      ],
    );
  }

  InlineSpan _bodyRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
    );
  }

  InlineSpan _monospaceRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        fontFamily: 'monospace',
      ),
    );
  }

  InlineSpan _strikeRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        decoration: TextDecoration.lineThrough,
      ),
    );
  }

  InlineSpan _fontRender(dom.Node node, HtmlParseContext context) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size']; // 1 - 7，默认：3
    double fontSize = context.fontSize * (double.tryParse(size) ?? 3.0) / 3.0;
    return TextSpan(
      children: _parseNodes(node.nodes,
          HtmlParseContext.nextContext(context, fontSize: fontSize)),
      style: TextStyle(
        color: _parseHtmlColor(color),
        fontSize: fontSize,
        fontFamily: face,
      ),
    );
  }

  InlineSpan _liRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: <InlineSpan>[
        WidgetSpan(
          child: Text(
              '${List<String>.generate(context.indentLevel, (int index) => '\r\r\r\r').join('')}${_convertLeading(context.leading, context.index)}\r\r'),
          alignment: ui.PlaceholderAlignment.middle,
        ),
        ..._parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
        TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _olRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          indentLevel: context.indentLevel + 1,
          leading: Leading.number,
        ),
      ),
    );
  }

  InlineSpan _underlineRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        decoration: TextDecoration.underline,
      ),
    );
  }

  InlineSpan _markRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      style: TextStyle(
        color: _htmlColorNameMap['black'],
        backgroundColor: _htmlColorNameMap['yellow'],
      ),
    );
  }

  InlineSpan _smallRender(dom.Node node, HtmlParseContext context) {
    double fontSize = context.fontSize * 0.8;
    return TextSpan(
      children: _parseNodes(node.nodes,
          HtmlParseContext.nextContext(context, fontSize: fontSize)),
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
  }

  InlineSpan _ulRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          indentLevel: context.indentLevel + 1,
          leading: Leading.dotted,
        ),
      ),
    );
  }

  List<InlineSpan> _parseNodes(List<dom.Node> nodes, HtmlParseContext context) {
    return nodes.map((dom.Node node) {
      return _parseNode(node,
          HtmlParseContext.indexContext(context, index: nodes.indexOf(node)));
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
