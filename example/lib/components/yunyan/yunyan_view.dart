import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class YunyanView extends StatefulWidget {
  const YunyanView({
    Key key,
    @required this.title,
  })  : assert(title != null),
        super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _YunyanViewState();
  }
}

class _YunyanViewState extends State<YunyanView> {

  @override
  void initState() {
    super.initState();
    print('${widget.runtimeType} - ${widget.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          color: Colors.green,
        ),
        CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).padding.top +
                    kToolbarHeight +
                    114.0 +
                    42.5,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipPath(
                        clipper: _BannerClipper(offset: 10.0),
                        child: Container(
                          color: Colors.white,
                          height: 42.5 + 10.0,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text('看，有灰机！'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                height: 200,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.red,
                height: 200,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.blue,
                height: 200,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.amber,
                height: 200,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.cyan,
                height: 200,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.black,
                height: 200,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BannerClipper extends CustomClipper<Path> {
  _BannerClipper({
    @required this.offset,
  });

  final double offset;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0.0, offset);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, offset);
    path.arcToPoint(
      Offset(0.0, offset),
      radius:
          Radius.circular(offset / 2 + math.pow(size.width, 2) / (8 * offset)),
      rotation: 1.0 / 3.0,
      clockwise: false,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != ShapeBorderClipper) {
      return true;
    }
    final _BannerClipper typedOldClipper = oldClipper;
    return typedOldClipper.offset != offset;
  }
}
