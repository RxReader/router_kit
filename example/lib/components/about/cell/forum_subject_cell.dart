import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 热门话题/圆桌话题
class ForumSubjectCell extends StatefulWidget {
  const ForumSubjectCell({
    Key key,
    @required this.subjects,
  }) : super(key: key);

  final List<String> subjects;

  @override
  State<StatefulWidget> createState() {
    return _ForumSubjectCellState();
  }
}

class _ForumSubjectCellState extends State<ForumSubjectCell> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        _buildTitleBar(),
        SizedBox(
          height: 15.0,
        ),
        _buildubjectList(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
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
          GestureDetector(
            onTap: () {
              // TODO
            },
            child: Text(
              '查看更多',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                height: 1.333,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildubjectList() {
    return Container(
      height: 58.0,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              width: 15.0,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final int itemIndex = index ~/ 2;
                Widget child;
                if (index.isEven) {
                  child = GestureDetector(
                    onTap: () {
                      // TODO
                    },
                    child: SizedBox(
                      width: 100,
                      height: 58,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            child: Image.network(
                              'https://www.baidu.com/img/bd_logo1.png?where=super',
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: Color(0xFF040404).withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            child: Text(
                              '${widget.subjects[itemIndex]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                height: 1.429,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  child = SizedBox(
                    width: 10.0,
                  );
                }
                return child;
              },
              childCount: math.max(0, widget.subjects.length * 2 - 1),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              width: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
