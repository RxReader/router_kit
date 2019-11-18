import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart' as strings;

class Voting {
  Voting({
    @required this.title,
    @required this.standpoint,
    this.onTap,
    this.flex = 1,
  })  : assert(strings.isNotEmpty(title)),
        assert(strings.isNotEmpty(standpoint));

  final String title;
  final String standpoint;
  final VoidCallback onTap;
  final int flex;
}

class RedBlueVotingBar extends StatelessWidget {
  const RedBlueVotingBar({
    Key key,
    @required this.red,
    @required this.blue,
  })  : assert(red != null),
        assert(blue != null),
        super(key: key);

  final Voting red;
  final Voting blue;

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      height: 1.406,
    );
    TextStyle standpointStyle = TextStyle(
      color: Color(0xFFFEFEFE),
      fontSize: 11.0,
      height: 1.364,
    );
    return Row(
      children: <Widget>[
        Expanded(
          flex: red.flex,
          child: GestureDetector(
            child: Container(
              height: 46.5,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
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
                    offset: Offset(0.0, 2.0),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    red.title,
                    style: titleStyle,
                  ),
                  Text(
                    red.standpoint,
                    style: standpointStyle,
                  ),
                ],
              ),
            ),
            onTap: red.onTap,
          ),
        ),
        Expanded(
          flex: blue.flex,
          child: GestureDetector(
            child: Container(
              height: 46.5,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
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
                    offset: Offset(0.0, 2.0),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    blue.title,
                    style: titleStyle,
                  ),
                  Text(
                    blue.standpoint,
                    style: standpointStyle,
                  ),
                ],
              ),
            ),
            onTap: blue.onTap,
          ),
        ),
      ],
    );
  }
}

class VotingResult {
  VotingResult({
    @required this.title,
    @required this.number,
  })  : assert(strings.isNotEmpty(title)),
        assert(number != null);

  final String title;
  final int number;
}

class RedBlueVotingResult extends StatelessWidget {
  const RedBlueVotingResult({
    Key key,
    this.red,
    this.blue,
  }) : super(key: key);

  final VotingResult red;
  final VotingResult blue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildRedBlueTitle(),
        SizedBox(
          height: 5.0,
        ),
        _buildRedBlueFlex(),
        SizedBox(
          height: 5.0,
        ),
        _buildRedBluePercentage(),
      ],
    );
  }

  Widget _buildRedBlueTitle() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 15.0,
                height: 15.0,
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFE7552), Color(0xFFFFB568)],
                  ),
                ),
                child: Text(
                  '√',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.0,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(
                width: 6.0,
              ),
              Text(
                red.title,
                style: TextStyle(
                  color: Color(0xFFFF7552),
                  fontSize: 14.0,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                blue.title,
                style: TextStyle(
                  color: Color(0xFF348DF5),
                  fontSize: 14.0,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRedBlueFlex() {
    if (red.number != 0 && blue.number == 0) {
      return Container(
        height: 14.5,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.5 / 2.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.centerRight,
            colors: [Color(0xFFFE7552), Color(0xFFFFB568)],
          ),
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x69FCA25E),
              offset: Offset(0.0, 2.0),
              blurRadius: 4.0,
            ),
          ],
        ),
      );
    }
    if (red.number == 0 && blue.number != 0) {
      return Container(
        height: 14.5,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.5 / 2.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.center,
            colors: [Color(0xFF64C1FB), Color(0xFF3688FF)],
          ),
          shadows: <BoxShadow>[
            BoxShadow(
              color: Color(0x7551ACF9),
              offset: Offset(0.0, 2.0),
              blurRadius: 4.0,
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int leftFlex = 1;
        int rightFlex = 1;
        if (red.number != 0 && blue.number != 0) {
          double minWidth = 14.5 / math.sqrt(3) + 14.5 / 2 + 2;
          double leftPercent = red.number / (red.number + blue.number);
          if (leftPercent * constraints.maxWidth < minWidth) {
            leftFlex = minWidth.toInt();
            rightFlex = (constraints.maxWidth - minWidth).toInt();
          } else if ((1 - leftPercent) * constraints.maxWidth < minWidth) {
            leftFlex = (constraints.maxWidth - minWidth).toInt();
            rightFlex = minWidth.toInt();
          } else {
            leftFlex = red.number;
            rightFlex = blue.number;
          }
        }
        return Row(
          children: <Widget>[
            Expanded(
              flex: leftFlex,
              child: Container(
                height: 14.5,
                decoration: ShapeDecoration(
                  shape: _LeftShapeBorder(
                    cornerRadius: 2.0,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFFE7552), Color(0xFFFFB568)],
                  ),
                  shadows: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x69FCA25E),
                      offset: Offset(0.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: rightFlex,
              child: Container(
                height: 14.5,
                decoration: ShapeDecoration(
                  shape: _RightShapeBorder(
                    cornerRadius: 2.0,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.center,
                    colors: [Color(0xFF64C1FB), Color(0xFF3688FF)],
                  ),
                  shadows: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x7551ACF9),
                      offset: Offset(0.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRedBluePercentage() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Text(
                red.number == 0
                    ? '0%'
                    : '${(red.number * 100 / (red.number + blue.number)).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.0,
                  height: 1.375,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                blue.number == 0
                    ? '0%'
                    : '${(blue.number * 100 / (red.number + blue.number)).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12.0,
                  height: 1.375,
                ),
              ),
            ],
          ),
        ),
      ],
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
      rotation: 1.0 / 2.0 * math.pi,
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
      rotation: 1.0 / 6.0 * math.pi,
      clockwise: false,
    );
    path.lineTo(
        rect.left + size.width - (1.0 - math.sqrt(3.0) / 2.0) * cornerRadius,
        rect.top + (1.0 + 1.0 / 2.0) * cornerRadius);
    path.arcToPoint(
      Offset(rect.left + size.width - cornerRadius, rect.top + 0.0),
      radius: Radius.circular(cornerRadius),
      rotation: 1.0 / 3.0 * math.pi,
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
      rotation: 1.0 / 2.0 * math.pi,
      clockwise: true,
    );
    path.lineTo(rect.left + cornerRadius, rect.top + size.height);
    path.arcToPoint(
      Offset(rect.left + (1.0 - math.sqrt(3.0) / 2.0) * cornerRadius,
          rect.top + size.height - (1.0 + 1.0 / 2.0) * cornerRadius),
      radius: Radius.circular(cornerRadius),
      rotation: 120.0 / 360.0 * math.pi,
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
      rotation: 1.0 / 6.0 * math.pi,
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
