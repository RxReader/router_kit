import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:example/html/basic_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

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
    return _parseNode(rootContext, document.body);
  }

  InlineSpan _parseNode(HtmlParseContext context, dom.Node node) {
    HtmlParseContext removeIndentContext =
        HtmlParseContext.removeIndentContext(context);
    InlineSpan result =
        customRender?.call(window, removeIndentContext, node, _parseNodes, callbacks);
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
        text: '暂不支持(${node is dom.Element ? node.localName : '${node.runtimeType}'})',
      );
    }
    return result;
  }

  List<InlineSpan> _parseNodes(
      HtmlParseContext nextContext, List<dom.Node> nodes) {
    return nodes.map((dom.Node node) {
      return _parseNode(nextContext, node);
    }).toList();
  }

  InlineSpan _bodyRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(context),
        node.nodes,
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _aRender(dom.Node node, HtmlParseContext context) {
    Color linkColor = parseHtmlColor('green');
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    ));
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          String target = node.attributes['target'];
          String media = node.attributes['media'];
          String mimeType = node.attributes['type'];
          String href = node.attributes['href'];
          callbacks.onTapLink?.call(target, media, mimeType, href);
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _blockquoteRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(context),
        node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _centerRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    List<InlineSpan> children = _parseNodes(
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
      node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _divRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _fontRender(dom.Node node, HtmlParseContext context) {
    String color = node.attributes['color'];
    String face = node.attributes['face'];
    String size = node.attributes['size']; // 1 - 7，默认：3
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      color: parseHtmlColor(color),
      fontSize: int.tryParse(size) != null
          ? rootContext.textStyle.fontSize *
              math.pow(5 / 4, int.tryParse(size) - 3)
          : null,
      fontFamily: face,
    ));
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
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
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
      node.nodes,
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
    double widthValue = parseHtmlWH(width, window?.width);
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
    return imageRender(window, context, node, _parseNodes, callbacks);
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
          HtmlParseContext.nextContext(
            context,
            indentLevel: context.indentLevel + 1,
            textStyle: textStyle,
          ),
          node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _markRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      backgroundColor: parseHtmlColor('yellow'),
    ));
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _olRender(dom.Node node, HtmlParseContext context) {
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          indentLevel: context.indentLevel + 1,
        ),
        node.nodes,
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _pRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _spanRender(dom.Node node, HtmlParseContext context) {
//    String style = node.attributes['style'];
    TextStyle textStyle = context.textStyle.merge(TextStyle());
    return TextSpan(
      children: _parseNodes(
        HtmlParseContext.nextContext(
          context,
          textStyle: textStyle,
        ),
        node.nodes,
      ),
      style: textStyle,
    );
  }

  InlineSpan _subRender(dom.Node node, HtmlParseContext context) {
    TextStyle textStyle = context.textStyle.merge(TextStyle(
      fontSize: context.textStyle.fontSize * 0.5,
    ));
    List<InlineSpan> children = _parseNodes(
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
      node.nodes,
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
      HtmlParseContext.nextContext(
        context,
        textStyle: textStyle,
      ),
      node.nodes,
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
        HtmlParseContext.nextContext(
          context,
          indentLevel: context.indentLevel + 1,
        ),
        node.nodes,
      ),
      style: context.textStyle,
    );
  }

  InlineSpan _videoRender(dom.Node node, HtmlParseContext context) {
    return videoRender(window, context, node, _parseNodes, callbacks);
  }
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
