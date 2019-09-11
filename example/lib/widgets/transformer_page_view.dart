import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

typedef Transformer = Widget Function(BuildContext context, Axis scrollDirection, bool reverse, PageMetrics metrics, int index, Widget child);

class TransformerPageView extends StatefulWidget {
  const TransformerPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.transformer,
    @required this.builder,
    @required this.childCount,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final Axis scrollDirection;
  final bool reverse;
  final PageController controller;
  final ScrollPhysics physics;
  final bool pageSnapping;
  final ValueChanged<int> onPageChanged;
  final Transformer transformer;
  final IndexedWidgetBuilder builder;
  final int childCount;
  final DragStartBehavior dragStartBehavior;

  @override
  State<StatefulWidget> createState() {
    return _TransformerPageViewState();
  }
}

class _TransformerPageViewState extends State<TransformerPageView> {
  ValueNotifier<PageMetrics> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<PageMetrics>(null);
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0) {
          PageMetrics metrics = notification.metrics as PageMetrics;
          _notifier.value = metrics;
        }
        return false;
      },
      child: PageView.custom(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        onPageChanged: widget.onPageChanged,
        childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return ValueListenableBuilder(
              valueListenable: _notifier,
              builder: (BuildContext context, PageMetrics value, Widget child) {
                return widget.transformer != null ? widget.transformer(context, widget.scrollDirection, widget.reverse, value, index, child) : child;
              },
              child: widget.builder(context, index),
            );
          },
          childCount: widget.childCount,
        ),
        dragStartBehavior: widget.dragStartBehavior,
      ),
    );
  }
}
