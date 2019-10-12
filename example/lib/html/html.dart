import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:csslib/parser.dart' as css_parser;
import 'package:example/html/basic_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:quiver/strings.dart';

class Html {
  Html._();

  static InlineSpan fromHtml(
    String source, {
    CustomRender customRender,
    Size window,
    double fontSize = 14.0,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
  }) {
    HtmlToSpannedConverter converter = HtmlToSpannedConverter(
      source,
      customRender: customRender,
      window: window,
      fontSize: fontSize,
      onTapLink: onTapLink,
      onTapImage: onTapImage,
    );
    return converter.convert();
  }
}

class HtmlParseContext {
  final int indentLevel;
  final Leading leading;
  final TextStyle textStyle;

  HtmlParseContext.rootContext({
    double fontSize,
  })  : indentLevel = 0,
        leading = Leading.dotted,
        textStyle = TextStyle(fontSize: fontSize);

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    int indentLevel,
    this.leading = Leading.dotted,
    TextStyle textStyle,
  })  : indentLevel = indentLevel ?? context.indentLevel,
        textStyle = textStyle ?? context.textStyle;

  HtmlParseContext.removeIndentContext(HtmlParseContext context)
      : indentLevel = 0,
        leading = context.leading,
        textStyle = context.textStyle;
}

class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.customRender,
    this.window,
    double fontSize = 14.0,
    this.onTapLink,
    this.onTapImage,
  }) : rootContext = HtmlParseContext.rootContext(fontSize: fontSize);

  final String source;
  final CustomRender customRender;
  final Size window;
  final HtmlParseContext rootContext;
  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;

  InlineSpan convert() {
    dom.Document document = html_parser.parse(source);
    return _parseNode(document.body, rootContext);
  }

  InlineSpan _parseNode(dom.Node node, HtmlParseContext context) {
    HtmlParseContext removeIndentContext =
        HtmlParseContext.removeIndentContext(context);
    InlineSpan result =
        customRender?.call(node, window, removeIndentContext, _parseNodes);
    if (result == null) {
      if (node is dom.Element) {
        switch (node.localName) {
          case 'a':
            result = _aRender(node, removeIndentContext);
            break;
          case 'abbr':
            result = _abbrRender(node, removeIndentContext);
            break;
          case 'b':
          case 'strong':
            result = _boldRender(node, removeIndentContext);
            break;
          case 'big':
            result = _bigRender(node, removeIndentContext);
            break;
          case 'blockquote':
            // like block
//            result = _blockquoteRender(node, removeIndentContext);
            break;
          case 'body':
            result = _containerRender(node, removeIndentContext);
            break;
          case 'br':
            result = _brRender(node, removeIndentContext);
            break;
          case 'center':
//            result = _centerRender(node, removeIndentContext);
            break;
          case 'del':
          case 's':
          case 'strike':
            result = _strikeRender(node, removeIndentContext);
            break;
          case 'div':
//            result = _containerRender(node, removeIndentContext);
            break;
          case 'em':
          case 'i':
            result = _italicRender(node, removeIndentContext);
            break;
          case 'font':
            result = _fontRender(node, removeIndentContext);
            break;
          case 'footer':
//            result = _containerRender(node, removeIndentContext);
            break;
          case 'h1':
            break;
          case 'h2':
            break;
          case 'h3':
            break;
          case 'h4':
            break;
          case 'h5':
            break;
          case 'h6':
            break;
          case 'header':
//            result = _containerRender(node, removeIndentContext);
            break;
          case 'hr':
//            result = _hrRender(node, removeIndentContext);
            break;
          case 'img':
            result = _imgRender(node, removeIndentContext);
            break;
          case 'li':
//            result = _liRender(node, removeIndentContext);
            break;
          case 'ins':
          case 'u':
            result = _underlineRender(node, removeIndentContext);
            break;
          case 'mark':
            result = _markRender(node, removeIndentContext);
            break;
          case 'ol':
            // like block
//            result = _olRender(node, removeIndentContext);
            break;
          case 'p':
            break;
          case 'small':
            result = _smallRender(node, removeIndentContext);
            break;
          case 'sub':
            result = _subRender(node, removeIndentContext);
            break;
          case 'sup':
            result = _supRender(node, removeIndentContext);
            break;
          case 'ul':
            // like block
//            result = _ulRender(node, removeIndentContext);
            break;
          case 'video':
            break;
        }
      } else if (node is dom.Text) {
        result = TextSpan(
          text: node.text,
//          style: context.textStyle,
        );
      }
    }
    if (result == null) {
      result = TextSpan(
        text: '暂不支持',
//        style: context.textStyle,
      );
    }
    return result;
  }

  List<InlineSpan> _parseNodes(
      List<dom.Node> nodes, HtmlParseContext nextContext) {
    return nodes.map((dom.Node node) {
      return _parseNode(node, nextContext);
    }).toList();
  }

  InlineSpan _containerRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(context),
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _aRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: _htmlColorNameMap['green'],
      decoration: TextDecoration.underline,
      decorationColor: _htmlColorNameMap['green'],
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
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
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _boldRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontWeight: FontWeight.bold,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _bigRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 1.25,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _brRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      text: '\n',
      style: context.textStyle,
    );
  }

  InlineSpan _strikeRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.lineThrough,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _italicRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontStyle: FontStyle.italic,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _fontRender(dom.Node node, HtmlParseContext context) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size']; // 1 - 7，默认：3
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: _parseHtmlColor(color),
      fontSize: int.tryParse(size) != null
          ? rootContext.textStyle.fontSize *
              math.pow(5 / 4, int.tryParse(size) - 3)
          : null,
      fontFamily: face,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _imgRender(dom.Node node, HtmlParseContext context) {
    String src = node.attributes['src'];
    String alt = node.attributes['alt'];
    String align = node.attributes['align']; // 不支持 left/right
    String border = node.attributes['border'];
    String height = node.attributes['height'];
    String hspace = node.attributes['hspace'];
    String vspace = node.attributes['vspace'];
    String width = node.attributes['width'];
    Uri uri = isNotEmpty(src) ? Uri.tryParse(src) : null;
    ui.PlaceholderAlignment alignment;
    switch (align) {
      case 'top':
        alignment = ui.PlaceholderAlignment.top;
        break;
      case 'bottom':
        alignment = ui.PlaceholderAlignment.bottom;
        break;
      case 'middle':
        alignment = ui.PlaceholderAlignment.middle;
        break;
      case 'left':
      case 'right':
      default:
        alignment = ui.PlaceholderAlignment.bottom;
        break;
    }
    double widthValue = _parseHtmlWH(width, window?.width);
    double heightValue = _parseHtmlWH(height, window?.height) ??
        _parseHtmlWH(width, window?.width);
    Widget result;
    if (uri == null) {
      result = SizedBox(
        width: widthValue,
        height: heightValue,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.image,
                    color: _htmlColorNameMap['gray'],
                  ),
                  Text.rich(TextSpan(
                    text: alt ?? '',
                    style: context.textStyle,
                  )),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      ImageProvider image;
      if (uri.data != null && uri.data.isBase64) {
        image = MemoryImage(uri.data.contentAsBytes());
      } else {
        image = NetworkImage(uri.toString());
      }
      result = Image(
        image: image,
        width: widthValue,
        height: heightValue,
      );
    }
    return WidgetSpan(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: _parseHtmlWH(vspace, null) ?? 0.0,
          horizontal: _parseHtmlWH(hspace, null) ?? 0.0,
        ),
        decoration: _parseHtmlWH(border, null) != null
            ? ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: _parseHtmlWH(border, null) ?? 0.0),
                ),
              )
            : null,
        child: result,
      ),
      alignment: alignment,
    );
  }

  InlineSpan _underlineRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.underline,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _markRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      backgroundColor: _htmlColorNameMap['yellow'],
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _smallRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.8,
    ));
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
      ),
      style: textStyle,
    );
  }

  InlineSpan _subRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.5,
    ));
    List<InlineSpan> children = _parseNodes(
      node.nodes,
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
    );
    return PlainTextWidgetSpan(
      children: children,
      child: Text.rich(TextSpan(
        children: children,
        style: textStyle,
      )),
      alignment: ui.PlaceholderAlignment.bottom,
    );
  }

  InlineSpan _supRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.5,
    ));
    List<InlineSpan> children = _parseNodes(
      node.nodes,
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
    );
    return PlainTextWidgetSpan(
      children: children,
      child: Text.rich(TextSpan(
        children: children,
        style: textStyle,
      )),
      alignment: ui.PlaceholderAlignment.top,
    );
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

double _parseHtmlWH(String value, double refValue) {
  if (isNotEmpty(value)) {
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
