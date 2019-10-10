import 'package:example/html/basic_types.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class Html {
  Html._();

  static InlineSpan fromHtml(
    String source, {
    CustomRender customRender,
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
    Document document = parser.parse(source);
    return _parseNode(document.body);
  }

  InlineSpan _parseNode(Node node) {
    if (customRender != null) {
      InlineSpan customSpan = customRender(node, _parseNodes(node.nodes));
      if (customSpan != null) {
        return customSpan;
      }
    }
    if (node is Element) {
      switch (node.localName) {
        case 'a':
          return _aRender(node, _parseNodes(node.nodes));
      }
    }
    return TextSpan(text: '暂不支持');
  }

  InlineSpan _aRender(Node node, List<InlineSpan> children) {
    return TextSpan(
      children: children,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          String url = node.attributes['href'];
          onTapLink?.call(url);
        },
    );
  }



  List<InlineSpan> _parseNodes(List<Node> nodes) {
    return nodes.map((Node node) {
      return _parseNode(node);
    }).toList();
  }
}
