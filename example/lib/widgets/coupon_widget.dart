import 'dart:math' as math;
import 'package:flutter/material.dart';

class CouponWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 87,
      child: Row(
        children: <Widget>[
          Container(
            width: 103.59,
            decoration: ShapeDecoration(
              shape: _LeftShapeBorder(
                cornerRadius: 10.0,
              ),
              gradient: LinearGradient(
                begin: Alignment(-0.25, -0.25),
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFD6F54),
                  Color(0xFFFCA756),
                ],
              ),
              shadows: <BoxShadow>[
                BoxShadow(
                  color: Color(0x12000000),
                  offset: Offset(0, 1.5),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -2,
                  bottom: -7,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          Color(0x63FFFFFF),
                          Color(0xFFFFFFFF),
                        ],
                      ).createShader(Offset.zero & bounds.size);
                    },
                    child: Text(
                      '专',
                      style: TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.blue,
                shape: _RightShapeBorder(
                  cornerRadius: 10.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftShapeBorder extends ShapeBorder {
  _LeftShapeBorder({
    this.cornerRadius,
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
    path.moveTo(rect.left + cornerRadius, rect.top + 0.0);
    path.arcToPoint(
      Offset(rect.left, rect.top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: false,
    );
    path.lineTo(rect.left, rect.top + size.height - cornerRadius);
    path.arcToPoint(
      Offset(rect.left + cornerRadius, rect.top + size.height),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: false,
    );
    path.lineTo(rect.left + size.width - cornerRadius, rect.top + size.height);
    path.arcToPoint(
      Offset(rect.left + size.width, rect.top + size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: true,
    );
    path.lineTo(rect.left + size.width, rect.top + cornerRadius);
    path.arcToPoint(
      Offset(rect.left + size.width - cornerRadius, rect.top),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
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
    this.cornerRadius,
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
    path.moveTo(rect.left + cornerRadius, rect.top + 0.0);
    path.arcToPoint(
      Offset(rect.left, rect.top + cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: true,
    );
    path.lineTo(rect.left, rect.top + size.height - cornerRadius);
    path.arcToPoint(
      Offset(rect.left + cornerRadius, rect.top + size.height),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: true,
    );
    path.lineTo(rect.left + size.width - cornerRadius, rect.top + size.height);
    path.arcToPoint(
      Offset(rect.left + size.width, rect.top + size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
      clockwise: false,
    );
    path.lineTo(rect.left + size.width, rect.top + cornerRadius);
    path.arcToPoint(
      Offset(rect.left + size.width - cornerRadius, rect.top),
      radius: Radius.circular(cornerRadius),
      rotation: 1 / 4 * math.pi,
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
