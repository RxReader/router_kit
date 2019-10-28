import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:example/html/basic_types.dart';
import 'package:example/html/html.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:quiver/strings.dart';

class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.sourceUrl,
    this.customRender,
    this.window,
    double fontSize = 14.0,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
    TapVideoCallback onTapVideo,
  })  : rootContext = HtmlParseContext.rootContext(
          fontSize: fontSize,
        ),
        callbacks = HtmlTapCallbacks.all(
          onTapLink: onTapLink,
          onTapImage: onTapImage,
          onTapVideo: onTapVideo,
        );

  final String source;
  final String sourceUrl;
  final CustomRender customRender;
  final Size window;
  final HtmlParseContext rootContext;
  final HtmlTapCallbacks callbacks;

  static const List<String> _supportedBlockElements = <String>[
    'center',
    'div',
//    'h1',
//    'h2',
//    'h3',
//    'h4',
//    'h5',
//    'h6',
    'hr',
    'li',
    'p',
    'pre',
  ];

  static const List<String> _supportedLikeBlockElements = <String>[
    'blockquote',
    'ol',
    'ul',
  ];

  InlineSpan convert() {
    dom.Document document =
        html_parser.parse(source, generateSpans: true, sourceUrl: sourceUrl);
    return _parseNode(rootContext, document.body);
  }

  InlineSpan _parseNode(HtmlParseContext context, dom.Node node) {
    HtmlParseContext removeIndentContext =
        HtmlParseContext.removeIndentContext(context);
    InlineSpan result = customRender?.call(
        window, removeIndentContext, sourceUrl, node, _parseNodes, callbacks);
    if (result == null) {
      if (node is dom.Element) {
        switch (node.localName) {
          case 'a':
            result = _aRender(removeIndentContext, node);
            break;
          case 'abbr':
          case 'acronym':
            result = _abbrRender(removeIndentContext, node);
            break;
          case 'b':
          case 'strong':
            result = _boldRender(removeIndentContext, node);
            break;
          case 'big':
            result = _bigRender(removeIndentContext, node);
            break;
          case 'blockquote':
            // like block
            result = _blockquoteRender(removeIndentContext, node);
            break;
          case 'body':
            result = _bodyRender(removeIndentContext, node);
            break;
          case 'br':
            result = _brRender(removeIndentContext, node);
            break;
          case 'center':
            // block
            result = _centerRender(removeIndentContext, node);
            break;
          case 'cite':
          case 'dfn':
          case 'em':
          case 'i':
            result = _italicRender(removeIndentContext, node);
            break;
          case 'code':
          case 'kbd':
          case 'samp':
          case 'tt':
            result = _monospaceRender(removeIndentContext, node);
            break;
          case 'del':
          case 's':
          case 'strike':
            result = _strikeRender(removeIndentContext, node);
            break;
          case 'div':
            // block
            result = _divRender(removeIndentContext, node);
            break;
          case 'font':
            result = _fontRender(removeIndentContext, node);
            break;
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            // block
            result = _h1xh6Render(removeIndentContext, node,
                int.tryParse(node.localName.substring(1)) ?? 6);
            break;
          case 'hr':
            // block
            result = _hrRender(removeIndentContext, node);
            break;
          case 'img':
            result = _imgRender(removeIndentContext, node);
            break;
          case 'li':
            // block
            result = _liRender(removeIndentContext, node);
            break;
          case 'ins':
          case 'u':
            result = _underlineRender(removeIndentContext, node);
            break;
          case 'mark':
            result = _markRender(removeIndentContext, node);
            break;
          case 'ol':
            // like block
            result = _olRender(removeIndentContext, node);
            break;
          case 'p':
            // block
            result = _pRender(removeIndentContext, node);
            break;
          case 'pre':
            // block
            result = _preRender(removeIndentContext, node);
            break;
          case 'q':
            result = _qRender(removeIndentContext, node);
            break;
          case 'small':
            result = _smallRender(removeIndentContext, node);
            break;
          case 'span':
            result = _spanRender(removeIndentContext, node);
            break;
          case 'sub':
            result = _subRender(removeIndentContext, node);
            break;
          case 'sup':
            result = _supRender(removeIndentContext, node);
            break;
          case 'ul':
            // like block
            result = _ulRender(removeIndentContext, node);
            break;
          case 'video':
            result = _videoRender(removeIndentContext, node);
            break;
          default:
            result = _unsupportTagRender(removeIndentContext, node);
            break;
        }
      } else if (node is dom.Text) {
        result = _textRender(removeIndentContext, node);
      }
    }
    return result;
  }

  void _parseNodes(
    HtmlParseContext nextContext,
    List<dom.Node> nodes,
    List<InlineSpan> children,
  ) {
    for (dom.Node node in nodes) {
      InlineSpan child = _parseNode(nextContext, node);
      if (child != null) {
        children.add(child);
      }
    }
  }

  InlineSpan _bodyRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _unsupportTagRender(HtmlParseContext context, dom.Element node) {
    return TextSpan(
      text: '暂不支持(${node.localName})',
    );
  }

  InlineSpan _textRender(HtmlParseContext context, dom.Text node) {
    String finalText = node.text;
    if (isEmpty(node.text.trim()) && !node.text.contains(' ')) {
      return null;
    }
    if (context.condenseWhitespace) {
      finalText = _condenseHtmlWhitespace(node.text);
      if (context.parent == null || node.parent.localName == 'body') {
        finalText = finalText.trim();
      } else if (context.parent is TextSpan) {
        TextSpan parent = context.parent as TextSpan;
        String lastString = parent.text ?? '';
        if (parent.children.isNotEmpty) {
          InlineSpan nearly = parent.children.last;
          lastString = nearly is TextSpan ? (nearly.text ?? '') : '';
        }
        if (lastString.endsWith(' ') || lastString.endsWith('\n')) {
          finalText = finalText.trimLeft();
        }
      }
    }
    if (isEmpty(finalText) || finalText == ' ') {
      return null;
    }
    return TextSpan(
      text: finalText,
//      style: TextStyle(
//        backgroundColor: Colors.cyan,
//      ),
    );
  }

  String _condenseHtmlWhitespace(String stringToTrim) {
    stringToTrim = stringToTrim.replaceAll("\n", " ");
    while (stringToTrim.contains("  ")) {
      stringToTrim = stringToTrim.replaceAll("  ", " ");
    }
    return stringToTrim;
  }

  InlineSpan _aRender(HtmlParseContext context, dom.Element node) {
    Color linkColor = Html.parseHtmlColor('green');
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    ));
    String target = node.attributes['target'];
    String media = node.attributes['media'];
    String mimeType = node.attributes['type'];
    String href = node.attributes['href'];
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          callbacks.onTapLink?.call(
            target,
            media,
            mimeType,
            isNotEmpty(sourceUrl)
                ? Uri.parse(sourceUrl).resolve(href).toString()
                : href,
          );
        },
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _abbrRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _boldRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontWeight: FontWeight.bold,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _bigRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 1.25,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _blockquoteRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontStyle: FontStyle.italic,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        indentLevel: context.indentLevel + 1,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _brRender(HtmlParseContext context, dom.Element node) {
    return TextSpan(
      text: '\n',
      style: context.textStyle,
    );
  }

  InlineSpan _monospaceRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontFamily: 'monospace',
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _centerRender(HtmlParseContext context, dom.Element node) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _italicRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontStyle: FontStyle.italic,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _strikeRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.lineThrough,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _divRender(HtmlParseContext context, dom.Element node) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _fontRender(HtmlParseContext context, dom.Element node) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size']; // 1 - 7，默认：3
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: Html.parseHtmlColor(color),
      fontSize: int.tryParse(size) != null
          ? rootContext.textStyle.fontSize *
              math.pow(5 / 4, int.tryParse(size) - 3)
          : null,
      fontFamily: face,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _h1xh6Render(
      HtmlParseContext context, dom.Element node, int level) {
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
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _hrRender(HtmlParseContext context, dom.Element node) {
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
    double widthValue = Html.parseHtmlWH(width, window?.width);
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

  InlineSpan _imgRender(HtmlParseContext context, dom.Element node) {
    return defaultImgRender(
        window, context, sourceUrl, node, _parseNodes, callbacks);
  }

  InlineSpan _liRender(HtmlParseContext context, dom.Element node) {
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
    List<InlineSpan> children = <InlineSpan>[
      TextSpan(
        text: leading,
      ),
    ];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
        indentLevel: context.indentLevel + 1,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _underlineRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      decoration: TextDecoration.underline,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _markRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      backgroundColor: Html.parseHtmlColor('yellow'),
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _olRender(HtmlParseContext context, dom.Element node) {
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: context.textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        indentLevel: context.indentLevel + 2,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _pRender(HtmlParseContext context, dom.Element node) {
    String style = node.attributes['style'];
    Map<String, String> htmlStyle = Html.parseHtmlStyle(style);
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _preRender(HtmlParseContext context, dom.Element node) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
        condenseWhitespace: false,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _qRender(HtmlParseContext context, dom.Element node) {
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: context.textStyle,
    );
    children.add(const TextSpan(text: '"'));
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
      ),
      node.nodes,
      children,
    );
    children.add(const TextSpan(text: '"'));
    return result;
  }

  InlineSpan _smallRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.8,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _spanRender(HtmlParseContext context, dom.Element node) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result;
    result = TextSpan(
      children: children,
      style: textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _subRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.5,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = WidgetSpan(
      child: Text.rich(TextSpan(
        children: children,
        style: textStyle,
      )),
      alignment: ui.PlaceholderAlignment.bottom,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _supRender(HtmlParseContext context, dom.Element node) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.5,
    ));
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = WidgetSpan(
      child: Text.rich(TextSpan(
        children: children,
        style: textStyle,
      )),
      alignment: ui.PlaceholderAlignment.top,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        textStyle: textStyle,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _ulRender(HtmlParseContext context, dom.Element node) {
    List<InlineSpan> children = <InlineSpan>[];
    InlineSpan result = TextSpan(
      children: children,
      style: context.textStyle,
    );
    _parseNodes(
      HtmlParseContext.nextContext(
        context,
        parent: result,
        indentLevel: context.indentLevel + 2,
      ),
      node.nodes,
      children,
    );
    return result;
  }

  InlineSpan _videoRender(HtmlParseContext context, dom.Element node) {
    return defaultVideoRender(
        window, context, sourceUrl, node, _parseNodes, callbacks);
  }
}
