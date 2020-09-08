import 'package:example/pages/reader/html/style.dart';
import 'package:html/dom.dart' as dom;

// ignore: implementation_imports
import 'package:html/src/query_selector.dart';

class StyledElement {
  StyledElement({
    this.name = '[[No name]]',
    this.elementId,
    this.elementClasses,
    this.children,
    this.style,
    dom.Element node,
  }) : _node = node;

  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Element _node;

  bool matchesSelector(String selector) => _node != null && matches(_node, selector);

  Map<String, String> get attributes => _node.attributes.cast<String, String>();

  dom.Element get element => _node;
}
