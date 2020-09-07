import 'package:flutter/rendering.dart';
import 'package:flutter_html/html_parser.dart';

// ignore: implementation_imports
import 'package:flutter_html/src/html_elements.dart';
// ignore: implementation_imports
import 'package:flutter_html/src/replaced_element.dart';
// ignore: implementation_imports
import 'package:flutter_html/src/styled_element.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;

class ReaderHtml {
  ReaderHtml._();

  static InlineSpan parseHtml(String data, {Map<String, Style> style, Map<String, CustomRender> customRender, List<String> blacklistedElements}) {
    StyledElement lexedTree = lexDomTree(HtmlParser.parseHTML(data), customRender?.keys?.toList() ?? <String>[], blacklistedElements);
    StyledElement styledTree = HtmlParser.applyCSS(lexedTree);
    StyledElement inlineStyledTree = HtmlParser.applyInlineStyles(styledTree);
    StyledElement customStyledTree = _applyCustomStyles(inlineStyledTree, style);
    StyledElement cascadedStyledTree = _cascadeStyles(customStyledTree);
    StyledElement cleanedTree = HtmlParser.cleanTree(cascadedStyledTree);
    return null;
  }

  static StyledElement lexDomTree(
    dom.Document html,
    List<String> customRenderTags,
    List<String> blacklistedElements,
  ) {
    StyledElement tree = StyledElement(
      name: '[Tree Root]',
      children: <StyledElement>[],
      node: html.documentElement,
    );
    // ignore: avoid_function_literals_in_foreach_calls
    html.nodes.forEach((dom.Node node) {
      tree.children.add(_recursiveLexer(node, customRenderTags, blacklistedElements));
    });
    return tree;
  }

  static StyledElement _recursiveLexer(
    dom.Node node,
    List<String> customRenderTags,
    List<String> blacklistedElements,
  ) {
    List<StyledElement> children = <StyledElement>[];
    // ignore: avoid_function_literals_in_foreach_calls
    node.nodes.forEach((dom.Node childNode) {
      children.add(_recursiveLexer(childNode, customRenderTags, blacklistedElements));
    });
    if (node is dom.Element) {
      if (blacklistedElements?.contains(node.localName) ?? false) {
        return EmptyContentElement();
      }
      if (STYLED_ELEMENTS.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else if (INTERACTABLE_ELEMENTS.contains(node.localName)) {
        return parseInteractableElement(node, children);
      } else if (REPLACED_ELEMENTS.contains(node.localName)) {
        return _parseReplacedElement(node);
//      } else if (LAYOUT_ELEMENTS.contains(node.localName)) {
//        return parseLayoutElement(node, children);
//      } else if (TABLE_STYLE_ELEMENTS.contains(node.localName)) {
//        return parseTableDefinitionElement(node, children);
      } else if (customRenderTags.contains(node.localName)) {
        return parseStyledElement(node, children);
      } else {
        return EmptyContentElement();
      }
    } else if (node is dom.Text) {
      return TextContentElement(text: node.text);
    } else {
      return EmptyContentElement();
    }
  }

  static ReplacedElement _parseReplacedElement(dom.Element element) {
    switch (element.localName) {
      case 'audio':
        break;
      case 'iframe':
        break;
      case 'img':
        break;
      case 'video':
        break;
      case 'ruby':
        break;
    }
    return parseReplacedElement(element);
  }

  static StyledElement _cascadeStyles(StyledElement tree) {
    // ignore: avoid_function_literals_in_foreach_calls
    tree.children?.forEach((StyledElement child) {
      child.style = tree.style.copyOnlyInherited(child.style);
      _cascadeStyles(child);
    });
    return tree;
  }

  static StyledElement _applyCustomStyles(StyledElement tree, Map<String, Style> style) {
    if (style == null) {
      return tree;
    }
    style.forEach((String key, Style style) {
      if (tree.matchesSelector(key)) {
        if (tree.style == null) {
          tree.style = style;
        } else {
          tree.style = tree.style.merge(style);
        }
      }
    });
    // ignore: avoid_function_literals_in_foreach_calls
    tree.children?.forEach((StyledElement tree) => _applyCustomStyles(tree, style));
    return tree;
  }
}
