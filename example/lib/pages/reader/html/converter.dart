import 'dart:async';

import 'package:example/pages/reader/html/element/interactable_element.dart';
import 'package:example/pages/reader/html/element/replaced_element.dart';
import 'package:example/pages/reader/html/element/styled_element.dart';
import 'package:example/pages/reader/html/attributes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

typedef TapLinkCallback = void Function(String target, String media, String mimeType, String href);
typedef TapImageCallback = void Function(String src, double width, double height);
typedef TapVideoCallback = void Function(String poster, String src, double width, double height);

class TapCallbacks {
  TapCallbacks({
    this.onTapLink,
    this.onTapImage,
    this.onTapVideo,
  });

  final TapLinkCallback onTapLink;
  final TapImageCallback onTapImage;
  final TapVideoCallback onTapVideo;

  TapCallbacks copyWith({
    final TapLinkCallback onTapLink,
    final TapImageCallback onTapImage,
    final TapVideoCallback onTapVideo,
  }) {
    return TapCallbacks(
      onTapLink: onTapLink ?? this.onTapLink,
      onTapImage: onTapImage ?? this.onTapImage,
      onTapVideo: onTapVideo ?? this.onTapVideo,
    );
  }
}

// XHTML
// 文字选择功能有限，'WidgetSpan'内的文字无法被选中，故而尽量使用'TextSpan'
class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.sourceUrl,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
    TapVideoCallback onTapVideo,
  }) : callbacks = TapCallbacks(
          onTapLink: onTapLink,
          onTapImage: onTapImage,
          onTapVideo: onTapVideo,
        );

  final String source;
  final String sourceUrl;
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

  FutureOr<InlineSpan> convert({Size canvas, TextStyle style}) {
    dom.Document html = html_parser.parse(source, generateSpans: true, sourceUrl: sourceUrl);
    StyledElement lexedTree = _lexDomTree(html);
    return lexedTree.apply(canvas: canvas, style: style, sourceUrl: sourceUrl, callbacks: callbacks);
  }

  StyledElement _lexDomTree(dom.Document html) {
    return StyledElement(
      name: '[Tree Root]',
      children: _parseChildren(html),
      node: html.documentElement,
    );
  }

  List<StyledElement> _parseChildren(dom.Node node) {
    List<StyledElement> children = <StyledElement>[];
    for (dom.Node childNode in node.nodes) {
      StyledElement child = _recursiveLexer(childNode);
      if (child != null) {
        children.add(child);
      }
    }
    return children;
  }

  StyledElement _recursiveLexer(dom.Node node) {
    if (node is dom.Element) {
      if (_styledElements.contains(node.localName)) {
        return _parseStyledElement(node, _parseChildren(node));
      } else if (_interactableElements.contains(node.localName)) {
        return _parseInteractableElement(node, _parseChildren(node));
      } else if (_replacedElements.contains(node.localName)) {
        return _parseReplacedElement(node);
      } else {
        return EmptyContentElement(name: node.localName, elementId: node.id, node: node);
      }
    } else if (node is dom.Text) {
      return TextContentElement(text: node.text, node: node);
    } else {
      return EmptyContentElement(name: null, elementId: null, node: node);
    }
  }

  StyledElement _parseStyledElement(dom.Element element, List<StyledElement> children) {
    Attributes attributes;
    switch (element.localName) {
      case 'abbr':
      case 'acronym':
        attributes = Attributes(
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
          ),
        );
        break;
      case 'address':
      case 'cite':
      case 'dfn':
      case 'em':
      case 'i':
      case 'var':
        attributes = Attributes(
          textStyle: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        );
        break;
      case 'b':
      case 'strong':
      case 'th':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
        break;
      case 'bdo':
        // 暂不支持
        // TextDirection textDirection = ((element.attributes['dir'] ?? 'ltr') == 'rtl') ? TextDirection.rtl : TextDirection.ltr;
        break;
      case 'big':
        attributes = Attributes(
          fontSizeFactor: 1.2,
        );
        break;
      case 'code':
      case 'kbd':
      case 'samp':
      case 'tt':
        attributes = Attributes(
          textStyle: TextStyle(
            fontFamily: 'Monospace',
          ),
        );
        break;
      case 'del':
      case 's':
      case 'strike':
        attributes = Attributes(
          textStyle: TextStyle(
            decoration: TextDecoration.lineThrough,
          ),
        );
        break;
      case 'ins':
      case 'u':
        attributes = Attributes(
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
          ),
        );
        break;
      case 'mark':
        attributes = Attributes(
          textStyle: TextStyle(
            color: Colors.black,
          ),
          backgroundColor: Colors.yellow,
        );
        break;
      case 'q':
//        String before = '\"';
//        String after = '\"';
        break;
      case 'small':
        attributes = Attributes(
          fontSizeFactor: 0.83,
        );
        break;
      case 'sub':
        attributes = Attributes(
          fontSizeFactor: 0.83,
        );
        break;
      case 'sup':
        attributes = Attributes(
          fontSizeFactor: 0.83,
        );
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
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 28.0 / 14.0,
        );
        break;
      case 'h2':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 21.0 / 14.0,
        );
        break;
      case 'h3':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 16.38 / 14.0,
        );
        break;
      case 'h4':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 14.0 / 14.0,
        );
        break;
      case 'h5':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 11.62 / 14.0,
        );
        break;
      case 'h6':
        attributes = Attributes(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          fontSizeFactor: 9.38 / 14.0,
        );
        break;
      case 'header':
        break;
      case 'hr':
//        double width = double.infinity;
//        Border border = Border(bottom: BorderSide(width: 1.0));
        break;
      case 'html':
        break;
      case 'li':
//        if (element.parent.localName == 'ul') {
//          String markerContent = '${element.parent.children.where((dom.Element childElement) => childElement.localName == element.localName).toList().indexOf(element) + 1}.';
//        } else {
//          String markerContent = '•';
//        }
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
        // EdgeInsets margin = EdgeInsets.only(left: 14.0);
        attributes = Attributes(
          textStyle: TextStyle(
            fontFamily: 'Monospace',
          ),
        );
        break;
      case 'section':
        break;
      case 'ul':
        break;
    }
    return StyledElement(
      name: element.localName,
      elementId: element.id,
      children: children,
      attributes: attributes,
      node: element,
    );
  }

  InteractableElement _parseInteractableElement(dom.Element element, List<StyledElement> children) {
    switch (element.localName) {
      case 'a':
        return InteractableElement(
          name: element.localName,
          elementId: element.id,
          children: children,
          attributes: Attributes(
            textStyle: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          target: element.attributes['target'],
          media: element.attributes['media'],
          mimeType: element.attributes['type'],
          href: element.attributes['href'],
          node: element,
        );
    }
    return null;
  }

  ReplacedElement _parseReplacedElement(dom.Element element) {
    switch (element.localName) {
      case 'audio':
        List<String> sources = <String>[
          if (element.attributes['src'] != null) element.attributes['src'],
          ..._parseMediaSources(element.children),
        ];
        break;
      case 'br':
        return TextContentElement(text: '\n', node: element);
      case 'head':
        break;
      case 'iframe':
        break;
      case 'img':
        break;
      case 'svg':
        break;
      case 'template':
        break;
      case 'video':
        break;
      case 'rp':
        break;
      case 'rt':
        break;
      case 'ruby':
        break;
    }
    return null;
  }

  List<String> _parseMediaSources(List<dom.Element> elements) {
    return elements.where((dom.Element element) {
      return element.localName == 'source';
    }).map((dom.Element element) {
      return element.attributes['src'];
    }).toList();
  }
}
