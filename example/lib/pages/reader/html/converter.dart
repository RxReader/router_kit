import 'dart:async';

import 'package:example/pages/reader/html/element/replaced_element.dart';
import 'package:example/pages/reader/html/element/styled_element.dart';
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

typedef CustomRender = FutureOr<InlineSpan> Function(
  Size window,
  RenderContext context,
  String sourceUrl,
  dom.Element element,
  Map<String, String> attributes,
  InlineSpan parsedChild,
  TapCallbacks callbacks,
);

class HtmlToSpannedConverter {
  HtmlToSpannedConverter(
    this.source, {
    this.sourceUrl,
    this.customRenders,
    this.window,
    TapLinkCallback onTapLink,
    TapImageCallback onTapImage,
    TapVideoCallback onTapVideo,
  })  : rootContext = RenderContext.rootContext(),
        callbacks = TapCallbacks.all(
          onTapLink: onTapLink,
          onTapImage: onTapImage,
          onTapVideo: onTapVideo,
        );

  final String source;
  final String sourceUrl;
  final Map<String, CustomRender> customRenders;
  final Size window;
  final RenderContext rootContext;
  final TapCallbacks callbacks;

  FutureOr<InlineSpan> convert() {
    dom.Document document = html_parser.parse(source, generateSpans: true, sourceUrl: sourceUrl);
    return null;
  }

  StyledElement _lexDomTree(dom.Document html) {
    List<StyledElement> children = <StyledElement>[];
    for (dom.Node node in html.nodes) {
      children.add(_recursiveLexer(node));
    }
    return StyledElement(
      name: '[Tree Root]',
      children: children,
      node: html.documentElement,
    );
  }

  StyledElement _recursiveLexer(dom.Node node) {
    List<StyledElement> children = <StyledElement>[];
    for (dom.Node childNode in node.nodes) {
      children.add(_recursiveLexer(childNode));
    }
    if (node is dom.Element) {

    } else if (node is dom.Text) {

    } else {
      return EmptyContentElement();
    }
  }
}
