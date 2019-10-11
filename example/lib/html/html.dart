import 'dart:ui' as ui;

import 'package:csslib/parser.dart' as css_parser;
import 'package:example/html/basic_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:quiver/strings.dart';

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
  number,
  dotted,
}

String _convertLeading(Leading leading, int index) {
  switch (leading) {
    case Leading.number:
      return '${index + 1}.';
    case Leading.dotted:
    default:
      return '•';
  }
}

class HtmlParseContext {
  final int indentLevel;
  final Leading leading;
  final double fontSize;

  HtmlParseContext({
    this.fontSize,
  })  : indentLevel = 0,
        leading = Leading.dotted;

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    int indentLevel,
    this.leading = Leading.dotted,
    double fontSize,
  })  : indentLevel = indentLevel ?? context.indentLevel,
        fontSize = fontSize ?? context.fontSize;

  HtmlParseContext.removeIndent(HtmlParseContext context)
      : indentLevel = 0,
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
    HtmlParseContext removeIndentContext =
        HtmlParseContext.removeIndent(context);
    InlineSpan result =
        customRender?.call(node, removeIndentContext, _parseNodes);
    if (result == null) {
      if (node is dom.Element) {
        switch (node.localName) {
          case 'a':
            result = _aRender(node, removeIndentContext);
            break;
          case 'abbr':
          case 'acronym':
            result = _abbrRender(node, removeIndentContext);
            break;
          case 'address':
          case 'cite':
          case 'em':
          case 'i':
          case 'var':
            result = _italicRender(node, removeIndentContext);
            break;
          case 'b':
          case 'strong':
            result = _boldRender(node, removeIndentContext);
            break;
          case 'bdi':
          case 'data':
          case 'rp':
          case 'rt':
          case 'ruby':
          case 'span':
          case 'time':
            result = _containerRender(node, removeIndentContext);
            break;
          case 'big':
            result = _bigRender(node, removeIndentContext);
            break;
          case 'blockquote':
            result = _blockquoteRender(node, removeIndentContext);
            break;
          case 'body':
            result = _containerRender(node, removeIndentContext);
            break;
          case 'br':
            result = _brRender(node, removeIndentContext);
            break;
          case 'caption':
            result = _containerRender(node, removeIndentContext);
            break;
          case 'code':
          case 'kbd':
          case 'samp':
          case 'tt':
            result = _monospaceRender(node, removeIndentContext);
            break;
          case 'del':
          case 's':
          case 'strike':
            result = _strikeRender(node, removeIndentContext);
            break;
          case 'font':
            result = _fontRender(node, removeIndentContext);
            break;
          case 'hr':
            result = _hrRender(node, removeIndentContext);
            break;
          case 'img':
            result = _imgRender(node, removeIndentContext);
            break;
          case 'li':
            result = _liRender(node, removeIndentContext);
            break;
          case 'ins':
          case 'u':
            result = _underlineRender(node, removeIndentContext);
            break;
          case 'mark':
            result = _markRender(node, removeIndentContext);
            break;
          case 'ol':
            result = _olRender(node, removeIndentContext);
            break;
          case 'q':
            result = _qRender(node, removeIndentContext);
            break;
          case 'small':
            result = _smallRender(node, removeIndentContext);
            break;
          case 'ul':
            result = _ulRender(node, removeIndentContext);
            break;
        }
      } else if (node is dom.Text) {
        result = TextSpan(text: node.text);
      }
    }
    if (result == null) {
      result = TextSpan(text: '暂不支持');
    }
    String indent = List<String>.generate(
      context.indentLevel,
      (int index) => '\r\r\r\r',
    ).join('');
    return TextSpan(children: <InlineSpan>[
      if (isNotEmpty(indent))
        WidgetSpan(
          child: Text('$indent'),
          alignment: ui.PlaceholderAlignment.middle,
        ),
      result,
    ]);
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
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          fontSize: fontSize,
        ),
      ),
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

  InlineSpan _containerRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
    );
  }

  InlineSpan _brRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(text: '\n');
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

  InlineSpan _hrRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: <InlineSpan>[
        TextSpan(text: '\n'),
        WidgetSpan(
          child: Divider(
            height: 1.0,
            color: Colors.black38,
          ),
          alignment: ui.PlaceholderAlignment.middle,
        ),
        TextSpan(text: '\n'),
      ],
    );
  }

  InlineSpan _imgRender(dom.Node node, HtmlParseContext context) {
    String src = node.attributes['src'];
    Uri uri = isNotEmpty(src) ? Uri.tryParse(src) : null;
    if (uri == null) {
      return null;
    } else {
      return WidgetSpan(
        child: Image(
          image: uri.data != null && uri.data.isBase64
              ? MemoryImage(uri.data.contentAsBytes())
              : NetworkImage(uri.toString()),
          height: 50,
          width: 50,
        ),
        alignment: ui.PlaceholderAlignment.middle,
      );
    }
  }

  InlineSpan _liRender(dom.Node node, HtmlParseContext context) {
    int index = node.parent.nodes
        .where((dom.Node node) => node is dom.Element && node.localName == 'li')
        .toList()
        .indexOf(node);
    String leading = _convertLeading(context.leading, index);
    return TextSpan(
      children: <InlineSpan>[
        WidgetSpan(
          child: Text('$leading\r\r'),
          alignment: ui.PlaceholderAlignment.middle,
        ),
        ..._parseNodes(node.nodes, HtmlParseContext.nextContext(context)),
      ],
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

  InlineSpan _qRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: <InlineSpan>[
        TextSpan(text: '"'),
        ..._parseNodes(
          node.nodes,
          HtmlParseContext.nextContext(context),
        ),
        TextSpan(text: '"'),
      ],
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

  List<InlineSpan> _parseNodes(
      List<dom.Node> nodes, HtmlParseContext nextContext) {
    return nodes.isNotEmpty
        ? nodes.map((dom.Node node) {
            List<InlineSpan> children = <InlineSpan>[
              _parseNode(node, nextContext),
            ];
            if (node is dom.Element && node.localName == 'li') {
              children = <InlineSpan>[
                TextSpan(text: '\n'),
                ...children,
                if (nodes.last == node) TextSpan(text: '\n'),
              ];
            } else if (node.parent.localName == 'ul' ||
                node.parent.localName == 'ul') {
              children = <InlineSpan>[
                ...children,
                if (nodes.last == node) TextSpan(text: '\n'),
              ];
              if (nodes.first == node) {
                children = <InlineSpan>[
                  TextSpan(text: '\n'),
                  ...children,
                ];
              } else {
                dom.Node previousNode = nodes[nodes.indexOf(node) - 1];
                if (previousNode is dom.Element &&
                    previousNode.localName == 'li') {
                  children = <InlineSpan>[
                    TextSpan(text: '\n'),
                    ...children,
                  ];
                }
              }
            }
            return children;
          }).reduce((List<InlineSpan> value, List<InlineSpan> element) {
            return <InlineSpan>[
              ...value,
              ...element,
            ];
          })
        : <InlineSpan>[];
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
