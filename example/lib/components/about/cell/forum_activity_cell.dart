import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 福利活动
class ForumActivityCell extends StatefulWidget {
  const ForumActivityCell({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ForumActivityCellState();
  }
}

class _ForumActivityCellState extends State<ForumActivityCell> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        _buildTitleBar(),
        SizedBox(
          height: 10.0,
        ),
        _buildActivityList(),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  Widget _buildTitleBar() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 3.0,
            height: 15.0,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF66F3FF), Color(0xFF3688FF)],
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Text(
            '热门话题',
            style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                height: 1.0,
                textBaseline: TextBaseline.alphabetic),
          )
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double itemWidth = (mediaQuery.size.width - 15.5 * 2 - 11.0 * (4 - 1)) / 4;
    double scale = itemWidth / 78.0;
    double itemHeight = 65.5 * scale;
    return Container(
      height: itemHeight + 12.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 15.5,
          ),
          _buildActivityItem(itemWidth, itemHeight, scale),
          SizedBox(
            width: 11.0,
          ),
          _buildActivityItem(itemWidth, itemHeight, scale),
          SizedBox(
            width: 11.0,
          ),
          _buildActivityItem(itemWidth, itemHeight, scale),
          SizedBox(
            width: 11.0,
          ),
          _buildActivityItem(itemWidth, itemHeight, scale),
          SizedBox(
            width: 15.5,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(double width, double height, double scale) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          FutureBuilder<PaletteGenerator>(
            future: PaletteGenerator.fromImageProvider(NetworkImage(
                'http://b-ssl.duitang.com/uploads/blog/201312/04/20131204184148_hhXUT.jpeg')),
            builder: (BuildContext context,
                AsyncSnapshot<PaletteGenerator> snapshot) {
              return Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadows: <BoxShadow>[
                    BoxShadow(
                      color: snapshot.hasData
                          ? (snapshot.data.dominantColor?.color ?? Colors.transparent)
                          : Colors.transparent, //未取到色值
                      offset: Offset(0.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.network(
                    'http://b-ssl.duitang.com/uploads/blog/201312/04/20131204184148_hhXUT.jpeg',
                    fit: BoxFit.fill,
                    width: width,
                    height: height,
                  ),
                ),
              );
            },
          ),
//          Container(
//            width: width,
//            height: height,
//            decoration: ShapeDecoration(
//              color: Color(0xFF040404).withOpacity(0.6),
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.all(Radius.circular(10.0)),
//              ),
//            ),
//          ),
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              overflow: Overflow.clip,
              children: <Widget>[
                Positioned(
                  top: (-48.5 *
                      16.0 /
                      math.sqrt(math.pow(41.0, 2) + math.pow(48.5, 2)) * scale),
                  right: (48.5 -
                      math.sqrt(math.pow(41.0, 2) + math.pow(48.5, 2)) -
                      41.0 *
                          16.0 /
                          math.sqrt(math.pow(41.0, 2) + math.pow(48.5, 2))) * scale,
                  child: Transform.rotate(
                    angle: math.atan(41.0 / 48.5),
                    alignment: Alignment.topLeft,
                    transformHitTests: false,
                    child: Container(
                      alignment: Alignment.center,
                      height: 16.0 * scale,
                      width: math.sqrt(math.pow(41.0, 2) + math.pow(48.5, 2)) * scale,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(),
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFFFC7616), Color(0xFFFE400B)],
                        ),
                      ),
                      child: Text(
                        '未开始',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0 * scale,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
