import 'package:after_layout/after_layout.dart';
import 'package:flutter/widgets.dart';

class AfterLayout extends StatefulWidget {
  const AfterLayout({
    Key key,
    @required this.child,
    @required this.onAfterFirstLayout,
  }) : super(key: key);

  final Widget child;
  final void Function(BuildContext context, int times) onAfterFirstLayout;

  @override
  State<StatefulWidget> createState() {
    return _AfterLayoutState();
  }
}

class _AfterLayoutState extends State<AfterLayout> with AfterLayoutMixin<AfterLayout> {
  int _times = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    widget.onAfterFirstLayout?.call(context, _times++);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
