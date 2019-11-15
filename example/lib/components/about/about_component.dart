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
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: _LeftShapeBorder(
                      cornerRadius: 5.0,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFFE7552), Color(0xFFFFB568)],
                    ),
                    shadows: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x69FCA25E),
                        offset: Offset(0, -2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 46.5,
                  ),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: _RightShapeBorder(
                      cornerRadius: 5.0,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.center,
                      colors: [Color(0xFF64C1FB), Color(0xFF3688FF)],
                    ),
                    shadows: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x7551ACF9),
                        offset: Offset(0, -2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 46.5,
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

class _LeftShapeBorder extends ShapeBorder {
  _LeftShapeBorder({
    this.cornerRadius = 0.0,
  });

  final double cornerRadius;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.zero;
  }

  @override
  ShapeBorder scale(double t) {
    return _LeftShapeBorder(
      cornerRadius: cornerRadius * t,
    );
  }

  @override
  ShapeBorder lerpFrom(ShapeBorder a, double t) {
    assert(t != null);
    if (a is _LeftShapeBorder) {
      return _LeftShapeBorder(
        cornerRadius: t == 0 ? a.cornerRadius : cornerRadius,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder lerpTo(ShapeBorder b, double t) {
    assert(t != null);
    if (b is _LeftShapeBorder) {
      return _LeftShapeBorder(
        cornerRadius: t == 0 ? cornerRadius : b.cornerRadius,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Size size = rect.size;
    Path path = Path();
    path.moveTo(rect.left + size.height / 2.0, rect.top + 0.0);
    path.arcToPoint(
      Offset(rect.left + size.height / 2.0, rect.top + size.height),
      radius: Radius.circular(size.height / 2.0),
      rotation: 1.0 / 2.0,
      clockwise: false,
    );
    path.lineTo(
        rect.left +
            size.width -
            size.height / math.sqrt(3.0) +
            math.sqrt(3.0) * cornerRadius -
            1.0 / 2.0 * cornerRadius,
        rect.top + size.height);
    path.arcToPoint(
      Offset(
          rect.left +
              size.width -
              size.height / math.sqrt(3.0) +
              math.sqrt(3.0) * cornerRadius +
              1.0 / 4.0 * cornerRadius,
          rect.top + size.height - math.sqrt(3.0) / 4.0 * cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 6.0,
      clockwise: false,
    );
    path.lineTo(
        rect.left + size.width - (1.0 - math.sqrt(3.0) / 2.0) * cornerRadius,
        rect.top + (1.0 + 1.0 / 2.0) * cornerRadius);
    path.arcToPoint(
      Offset(rect.left + size.width - cornerRadius, rect.top + 0.0),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 3.0,
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final _LeftShapeBorder typedOther = other;
    return cornerRadius == typedOther.cornerRadius;
  }

  @override
  int get hashCode => hashValues(runtimeType, cornerRadius);

  @override
  String toString() {
    return '$runtimeType($cornerRadius)';
  }
}

class _RightShapeBorder extends ShapeBorder {
  _RightShapeBorder({
    this.cornerRadius = 0.0,
  });

  final double cornerRadius;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.zero;
  }

  @override
  ShapeBorder scale(double t) {
    return _RightShapeBorder(
      cornerRadius: cornerRadius * t,
    );
  }

  @override
  ShapeBorder lerpFrom(ShapeBorder a, double t) {
    assert(t != null);
    if (a is _RightShapeBorder) {
      return _RightShapeBorder(
        cornerRadius: t == 0 ? a.cornerRadius : cornerRadius,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder lerpTo(ShapeBorder b, double t) {
    assert(t != null);
    if (b is _RightShapeBorder) {
      return _RightShapeBorder(
        cornerRadius: t == 0 ? cornerRadius : b.cornerRadius,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Size size = rect.size;
    Path path = Path();
    path.moveTo(rect.left + size.width - size.height / 2.0, rect.top + 0.0);
    path.arcToPoint(
      Offset(
          rect.left + size.width - size.height / 2.0, rect.top + size.height),
      radius: Radius.circular(size.height / 2.0),
      rotation: 1.0 / 2.0,
      clockwise: true,
    );
    path.lineTo(rect.left + cornerRadius, rect.top + size.height);
    path.arcToPoint(
      Offset(rect.left + (1.0 - math.sqrt(3.0) / 2.0) * cornerRadius,
          rect.top + size.height - (1.0 + 1.0 / 2.0) * cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 120.0 / 360.0,
      clockwise: true,
    );
    path.lineTo(
        rect.left +
            size.height / math.sqrt(3.0) -
            math.sqrt(3.0) * cornerRadius -
            1.0 / 4.0 * cornerRadius,
        rect.top + math.sqrt(3.0) / 4 * cornerRadius);
    path.arcToPoint(
      Offset(
          rect.left +
              size.height / math.sqrt(3.0) -
              math.sqrt(3.0) * cornerRadius +
              1.0 / 2.0 * cornerRadius,
          rect.top + 0.0),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 6.0,
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final _RightShapeBorder typedOther = other;
    return cornerRadius == typedOther.cornerRadius;
  }

  @override
  int get hashCode => hashValues(runtimeType, cornerRadius);

  @override
  String toString() {
    return '$runtimeType($cornerRadius)';
  }
}
