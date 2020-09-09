import 'dart:async';

import 'package:example/pages/reader/html/element/interactable_element.dart';
import 'package:example/pages/reader/html/element/replaced_element.dart';
import 'package:example/pages/reader/html/element/styled_element.dart';
import 'package:example/pages/reader/html/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

typedef TapLinkCallback = void Function(String target, String media, String mimeType, String href);
typedef TapImageCallback = void Function(String src, double width, double height);
typedef TapVideoCallback = void Function(String poster, String src, double width, double height);

class TapCallbacks {
  TapCallbacks.all({
    this.onTapLink,
    this.onTapImage,
    this.onTapVideo,
  });

  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;
  final TapVideoCallback onTapVideo;
}

class RenderContext {
  RenderContext();

  RenderContext.rootContext();

  RenderContext nextContext() {
    return RenderContext();
  }
}

// XHTML
// 文字选择功能有限，'WidgetSpan'内的文字无法被选中，故而尽量使用'TextSpan'
class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.sourceUrl,
    this.window,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
    TapVideoCallback onTapVideo,
  }) : callbacks = TapCallbacks.all(
          onTapLink: onTapLink,
          onTapImage: onTapImage,
          onTapVideo: onTapVideo,
        );

  final String source;
  final String sourceUrl;
  final Size window;
  final TapCallbacks callbacks;

  static const List<String> _styledElements = <String>[
    'abbr',
    'acronym',
    'address',
    'b',
    'bdi',
    'bdo',
    'big',
    'cite',
    'code',
    'data',
    'del',
    'dfn',
    'em',
    'font',
    'i',
    'ins',
    'kbd',
    'mark',
    'q',
    's',
    'samp',
    'small',
    'span',
    'strike',
    'strong',
    'sub',
    'sup',
    'td',
    'th',
    'time',
    'tt',
    'u',
    'var',
    'wbr',

    // BLOCK ELEMENTS
    'article',
    'aside',
    'blockquote',
    'body',
    'center',
    'dd',
    'div',
    'dl',
    'dt',
    'figcaption',
    'figure',
    'footer',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hr',
    'html',
    'li',
    'main',
    'nav',
    'noscript',
    'ol',
    'p',
    'pre',
    'section',
    'ul',
  ];

  static const List<String> _interactableElements = <String>[
    'a',
  ];

  static const List<String> _replacedElements = <String>[
    'audio',
    'br',
    'head',
    'iframe',
    'img',
    'svg',
    'template',
    'video',
    'rp',
    'rt',
    'ruby',
  ];

  static const List<String> _layoutElements = <String>[
    'table',
    'tr',
    'tbody',
    'tfoot',
    'thead',
  ];

  static const List<String> _tableStyleElements = <String>[
    'col',
    'colgroup',
  ];

  FutureOr<InlineSpan> convert() {
    dom.Document html = html_parser.parse(source, generateSpans: true, sourceUrl: sourceUrl);
    StyledElement lexedTree = _lexDomTree(html);
    return null;
  }

  StyledElement _lexDomTree(dom.Document html) {
    return StyledElement(
      name: '[Tree Root]',
      children: _parseChildren(html),
      node: html.documentElement,
      style: Style(),
    );
  }

  List<StyledElement> _parseChildren(dom.Node node) {
    return node.nodes.map((dom.Node childNode) => _recursiveLexer(childNode)).toList();
  }

  StyledElement _recursiveLexer(dom.Node node) {
    if (node is dom.Element) {
      if (_styledElements.contains(node.localName)) {
        return _parseStyledElement(node, _parseChildren(node));
      } else {
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement();
    } else {
      return EmptyContentElement();
    }
  }

  StyledElement _parseStyledElement(dom.Element element, List<StyledElement> children) {
    Style style = Style();
    switch (element.localName) {
      case 'abbr':
      case 'acronym':
        TextStyle textStyle = TextStyle(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        );
        break;
      case 'address':
      case 'cite':
      case 'dfn':
      case 'em':
      case 'i':
      case 'var':
        TextStyle textStyle = TextStyle(
          fontStyle: FontStyle.italic,
        );
        break;
      case 'b':
      case 'strong':
      case 'th':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        break;
      case 'bdo':
        // 暂不支持
        // TextDirection textDirection = ((element.attributes['dir'] ?? 'ltr') == 'rtl') ? TextDirection.rtl : TextDirection.ltr;
        break;
      case 'big':
        double textScaleFactor = 1.2;
        break;
      case 'code':
      case 'kbd':
      case 'samp':
      case 'tt':
        TextStyle textStyle = TextStyle(
          fontFamily: 'Monospace',
        );
        break;
      case 'del':
      case 's':
      case 'strike':
        TextStyle textStyle = TextStyle(
          decoration: TextDecoration.lineThrough,
        );
        break;
      case 'ins':
      case 'u':
        TextStyle textStyle = TextStyle(
          decoration: TextDecoration.underline,
        );
        break;
      case 'mark':
        TextStyle textStyle = TextStyle(
          color: Colors.black,
        );
        Color backgroundColor = Colors.yellow;
        break;
      case 'q':
        String before = '\"';
        String after = '\"';
        break;
      case 'small':
        double textScaleFactor = 0.83;
        break;
      case 'sub':
        double textScaleFactor = 0.83;
        // TODO
        break;
      case 'sup':
        double textScaleFactor = 0.83;
        // TODO
        break;

      // BLOCK ELEMENTS
      case 'article':
        break;
      case 'aside':
        break;
      case 'blockquote':
        // EdgeInsets margin = EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0);
        break;
      case 'body':
        break;
      case 'center':
        // Alignment align = Alignment.center;
        break;
      case 'dd':
        // EdgeInsets margin = EdgeInsets.only(left: 40.0);
        break;
      case 'div':
        break;
      case 'dl':
        // EdgeInsets margin = EdgeInsets.symmetric(vertical: 14.0);
        break;
      case 'dt':
        break;
      case 'figcaption':
        break;
      case 'figure':
        // EdgeInsets margin = EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0);
        break;
      case 'footer':
        // 暂不支持
        break;
      case 'h1':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 28.0 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 18.67);
        break;
      case 'h2':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 21.0 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 17.5);
        break;
      case 'h3':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 16.38 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 16.5);
        break;
      case 'h4':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 14.0 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 18.5);
        break;
      case 'h5':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 11.62 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 19.25);
        break;
      case 'h6':
        TextStyle textStyle = TextStyle(
          fontWeight: FontWeight.bold,
        );
        double textScaleFactor = 9.38 / 14.0;
        // EdgeInsets margin = EdgeInsets.only(left: 22.0);
        break;
      case 'header':
        break;
      case 'hr':
        // 暂不支持
        // EdgeInsets margin = EdgeInsets.symmetric(vertical: 7.0);
        // double width = double.infinity;
        // Border border = Border(bottom: BorderSide(width: 1.0));
        break;
      case 'html':
        break;
      case 'li':
        if (element.parent.localName == 'ul') {
          String markerContent = '${element.parent.children.indexOf(element) + 1}.';
        } else {
          String markerContent = '•';
        }
        break;
      case 'main':
        break;
      case 'nav':
        break;
      case 'noscript':
        break;
      case 'ol':
        break;
      case 'p':
        break;
      case 'pre':
        TextStyle textStyle = TextStyle(
          fontFamily: 'Monospace'
        );
        // EdgeInsets margin = EdgeInsets.only(left: 14.0);
        break;
      case 'section':
        break;
      case 'ul':
        break;
    }
    return StyledElement(
      name: element.localName,
      elementId: element.id,
      elementClasses: element.classes.toList(),
      children: children,
      style: style,
      node: element,
    );
  }

  InteractableElement _parseInteractableElement(dom.Element element, List<StyledElement> children) {
    return null;
  }

  ReplacedElement _parseReplacedElement(dom.Element element) {
    return null;
  }
}
