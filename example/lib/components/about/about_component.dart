import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'about_component.component.dart';

@Component(
  routeName: '/about',
)
class AboutComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutComponentState();
  }
}

class _AboutComponentState extends State<AboutComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ClipPath(
                  clipper: _LeftShapeClipper(
                    cornerRadius: 5.0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFE7552), Color(0xFFFFB568)],
                      ),
                    ),
                    child: SizedBox(
                      height: 46.5,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipPath(
                  clipper: _RightShapeClipper(
                    cornerRadius: 5.0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.center,
                        colors: [Color(0xFF64C1FB), Color(0xFF3688FF)],
                      ),
                    ),
                    child: SizedBox(
                      height: 46.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeftShapeClipper extends CustomClipper<Path> {
  _LeftShapeClipper({
    this.cornerRadius = 0.0,
  });

  final double cornerRadius;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.height / 2.0, 0.0);
    path.arcToPoint(
      Offset(size.height / 2.0, size.height),
      radius: Radius.circular(size.height / 2.0),
      rotation: 1.0 / 2.0,
      clockwise: false,
    );
    path.lineTo(size.width - size.height / 2.0, size.height);
    path.arcToPoint(
      Offset(size.width - size.height / 2.0 + (1.0 + 1.0 / 2.0) * cornerRadius,
          size.height - math.sqrt(3.0) / 2.0 * cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 3.0,
      clockwise: false,
    );
    path.lineTo(size.width - 1.0 / math.sqrt(3.0) * cornerRadius, cornerRadius);
    path.arcToPoint(
      Offset(size.width - (1.0 / math.sqrt(3.0) + 1.0) * cornerRadius, 0.0),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 4.0,
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != ShapeBorderClipper) {
      return true;
    }
    final _LeftShapeClipper typedOldClipper = oldClipper;
    return typedOldClipper.cornerRadius != cornerRadius;
  }
}

class _RightShapeClipper extends CustomClipper<Path> {
  _RightShapeClipper({
    this.cornerRadius = 0.0,
  });

  final double cornerRadius;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width - size.height / 2.0, 0);
    path.arcToPoint(
      Offset(size.width - size.height / 2.0, size.height),
      radius: Radius.circular(size.height / 2.0),
      rotation: 1.0 / 2.0,
      clockwise: true,
    );
    path.lineTo((1.0 / math.sqrt(3.0) + 1.0) * cornerRadius, size.height);
    path.arcToPoint(
      Offset(
          1.0 / math.sqrt(3.0) * cornerRadius, size.height - cornerRadius), //
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 4.0,
      clockwise: true,
    );
    path.lineTo(size.height / 2.0 - (1.0 + 1.0 / 2.0) * cornerRadius,
        math.sqrt(3.0) / 2.0 * cornerRadius);
    path.arcToPoint(
      Offset(size.height / 2.0, 0.0),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 3.0,
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != ShapeBorderClipper) {
      return true;
    }
    final _RightShapeClipper typedOldClipper = oldClipper;
    return typedOldClipper.cornerRadius != cornerRadius;
  }
}
