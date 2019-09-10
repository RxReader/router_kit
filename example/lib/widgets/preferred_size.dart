import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreferredSizePadding extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizePadding({
    Key key,
    @required this.padding,
    @required this.child,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => padding.inflateSize(child.preferredSize);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class ResizeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResizeAppBar({
    Key key,
    @required this.appBar,
  }) : super(key: key);

  final AppBar appBar;

  @override
  Size get preferredSize =>
      Size.fromHeight(48 + (appBar.bottom?.preferredSize?.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return appBar;
  }
}

class ResizeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const ResizeTabBar({
    Key key,
    @required this.tabBar,
  }) : super(key: key);

  final TabBar tabBar;

  @override
  Size get preferredSize {
    Size wrapped = tabBar.preferredSize;
    return Size(wrapped.width, wrapped.height - 6.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: preferredSize,
      child: tabBar,
    );
  }
}
