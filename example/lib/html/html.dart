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
}

class HtmlParseContext {
  final int indentLevel;
  final TextStyle textStyle;

  HtmlParseContext.rootContext({
    double fontSize,
  })  : indentLevel = 0,
        textStyle = TextStyle(fontSize: fontSize);

  HtmlParseContext.nextContext(
    HtmlParseContext context, {
    int indentLevel,
    TextStyle textStyle,
  })  : indentLevel = indentLevel ?? context.indentLevel,
        textStyle = textStyle ?? context.textStyle;

  HtmlParseContext.removeIndentContext(HtmlParseContext context)
      : indentLevel = 0,
        textStyle = context.textStyle;
}

class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.sourceUrl,
    this.customRender,
    this.window,
    double fontSize = 14.0,
    this.onTapLink,
    this.onTapImage,
    this.onTapVideo,
  }) : rootContext = HtmlParseContext.rootContext(fontSize: fontSize);

  final String source;
  final String sourceUrl;
  final CustomRender customRender;
  final Size window;
  final HtmlParseContext rootContext;
  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;
  final TapVideoCallback onTapVideo;

  static const List<String> _supportedBlockElements = <String>[
    'center',
    'div',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'hr',
    'li',
    'p',
  ];

  static const List<String> _supportedLikeBlockElements = <String>[
    'blockquote',
    'ol',
    'ul',
  ];

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
            result = _blockquoteRender(node, removeIndentContext);
            break;
          case 'body':
            result = _bodyRender(node, removeIndentContext);
            break;
          case 'br':
            result = _brRender(node, removeIndentContext);
            break;
          case 'center':
            // block
            result = _centerRender(node, removeIndentContext);
            break;
          case 'cite':
          case 'dfn':
          case 'em':
          case 'i':
            result = _italicRender(node, removeIndentContext);
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
          case 'div':
            // block
            result = _divRender(node, removeIndentContext);
            break;
          case 'font':
            result = _fontRender(node, removeIndentContext);
            break;
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            // block
            result = _h1xh6Render(node, removeIndentContext,
                int.tryParse(node.localName.substring(1)) ?? 6);
            break;
          case 'hr':
            // block
            result = _hrRender(node, removeIndentContext);
            break;
          case 'img':
            result = _imgRender(node, removeIndentContext);
            break;
          case 'li':
            // block
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
            // like block
            result = _olRender(node, removeIndentContext);
            break;
          case 'p':
            // block
            result = _pRender(node, removeIndentContext);
            break;
          case 'small':
            result = _smallRender(node, removeIndentContext);
            break;
          case 'span':
            result = _spanRender(node, removeIndentContext);
            break;
          case 'sub':
            result = _subRender(node, removeIndentContext);
            break;
          case 'sup':
            result = _supRender(node, removeIndentContext);
            break;
          case 'ul':
            // like block
            result = _ulRender(node, removeIndentContext);
            break;
          case 'video':
            result = _videoRender(node, removeIndentContext);
            break;
        }
      } else if (node is dom.Text) {
        result = TextSpan(
          text: node.text,
        );
      }
    }
    if (result == null) {
      result = TextSpan(
        text: '暂不支持',
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

  InlineSpan _bodyRender(dom.Node node, HtmlParseContext context) {
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
          String href = node.attributes['href'];
          onTapLink?.call(target, media, mimeType, href);
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

  InlineSpan _blockquoteRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(context),
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _brRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      text: '\n',
      style: context.textStyle,
    );
  }

  InlineSpan _monospaceRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontFamily: 'monospace',
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

  InlineSpan _centerRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = _parseNodes(
      node.nodes,
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
    );
    return PlainTextWidgetSpan(
      children: children,
      child: Center(
        child: Text.rich(TextSpan(
          children: children,
          style: textStyle,
        )),
      ),
      alignment: ui.PlaceholderAlignment.middle,
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

  InlineSpan _divRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
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

  InlineSpan _h1xh6Render(dom.Node node, HtmlParseContext context, int level) {
//    String style = node.attributes['style'];
    String align = node.attributes['align'];
    TextAlign textAlign;
    switch (align) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      case 'justify':
        textAlign = TextAlign.justify;
        break;
      case 'left':
      default:
        textAlign = TextAlign.left;
        break;
    }
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: context.textStyle.fontSize * (1.0 + (6 - level) / 10),
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
      child: SizedBox(
        width: double.infinity,
        child: Text.rich(
          TextSpan(
            children: children,
            style: textStyle,
          ),
          textAlign: textAlign,
        ),
      ),
      alignment: ui.PlaceholderAlignment.middle,
    );
  }

  InlineSpan _hrRender(dom.Node node, HtmlParseContext context) {
    String align = node.attributes['align'];
    String width = node.attributes['width'];
    ui.PlaceholderAlignment alignment;
    switch (align) {
      case 'top':
        alignment = ui.PlaceholderAlignment.top;
        break;
      case 'bottom':
        alignment = ui.PlaceholderAlignment.bottom;
        break;
      case 'center':
        alignment = ui.PlaceholderAlignment.middle;
        break;
      default:
        alignment = ui.PlaceholderAlignment.middle;
        break;
    }
    double widthValue = _parseHtmlWH(width, window?.width);
    return WidgetSpan(
      child: SizedBox(
        width: widthValue,
        child: Divider(
          height: 1.0,
          color: Colors.black38,
        ),
      ),
      alignment: alignment,
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
    double heightValue = _parseHtmlWH(height, window?.height) ?? widthValue;
    Widget child;
    if (uri == null) {
      child = SizedBox(
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
      child = Image(
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
        child: GestureDetector(
          onTap: () {
            onTapImage?.call(src, widthValue, heightValue);
          },
          child: child,
        ),
      ),
      alignment: alignment,
    );
  }

  InlineSpan _liRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    String leading;
    if (node.parent.localName == 'ol') {
      int index = node.parent.nodes
          .where(
              (dom.Node node) => node is dom.Element && node.localName == 'li')
          .toList()
          .indexOf(node);
      leading = '${index + 1}.';
    } else {
      leading = '•';
    }
    return TextSpan(
      children: <InlineSpan>[
        TextSpan(
          text: leading,
        ),
        ..._parseNodes(
          node.nodes,
          HtmlParseContext.nextContext(
            context,
            indentLevel: context.indentLevel + 1,
            textStyle: textStyle,
          ),
        ),
      ],
      style: textStyle,
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

  InlineSpan _olRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(context),
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _pRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
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

  InlineSpan _spanRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
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

  InlineSpan _ulRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        node.nodes,
        HtmlParseContext.nextContext(context),
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _videoRender(dom.Node node, HtmlParseContext context) {
    String height = node.attributes['height'];
    String poster = node.attributes['poster'];
    String src = node.attributes['src'];
    String width = node.attributes['width'];
    double widthValue = _parseHtmlWH(width, null);
    double heightValue = _parseHtmlWH(height, null);
    Widget child;
    Uri uri = isNotEmpty(poster) ? Uri.tryParse(poster) : null;
    if (uri == null) {
      // TODO
      child = Text.rich(TextSpan(text: 'video', style: context.textStyle));
    } else {
      ImageProvider image;
      if (uri.data != null && uri.data.isBase64) {
        image = MemoryImage(uri.data.contentAsBytes());
      } else {
        image = NetworkImage(uri.toString());
      }
      child = Image(
        image: image,
        width: widthValue,
        height: heightValue,
      );
    }
    // TODO
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          onTapVideo?.call(poster, src, widthValue, heightValue);
        },
        child: child,
      ),
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

class PlainTextWidgetSpan extends WidgetSpan {
  PlainTextWidgetSpan({
    @required this.children,
    @required Widget child,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline baseline,
    TextStyle style,
  }) : super(
          child: child,
          alignment: alignment,
          baseline: baseline,
          style: style,
        );

  final List<InlineSpan> children;

  @override
  void computeToPlainText(StringBuffer buffer,
      {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
//    super.computeToPlainText(buffer,
//        includeSemanticsLabels: includeSemanticsLabels,
//        includePlaceholders: includePlaceholders);
    if (children != null) {
      for (InlineSpan child in children) {
        child.computeToPlainText(
          buffer,
          includeSemanticsLabels: includeSemanticsLabels,
          includePlaceholders: includePlaceholders,
        );
      }
    }
  }
}
