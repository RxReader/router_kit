import 'dart:math' as math;

import 'package:example/components/about/cell/forum_activity_cell.dart';
import 'package:example/components/about/cell/forum_subject_cell.dart';
import 'package:example/widgets/coupon_widget.dart';
import 'package:example/widgets/red_blue_voting.dart';
import 'package:example/widgets/list_voting.dart' as list;
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
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          CouponWidget(),
          SizedBox(
            height: 10.0,
          ),
          RedBlueVotingBar(
            red: Voting(
              title: '赞同',
              standpoint: '理想值得奉上一切',
            ),
            blue: Voting(
              title: '不赞同',
              standpoint: '理想值得奉上一切',
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          RedBlueVotingResult(
            red: VotingResult(
              title: '赞同458人',
              number: 458,
            ),
            blue: VotingResult(
              title: '不赞同118人',
              number: 118,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          list.ListVotingBar(
            votings: List<list.Voting>.generate(
                4,
                (int index) => list.Voting(
                      title: '选项$index',
                      number: math.pow(index, 5),
                    )),
            selected: 1,
          ),
          SizedBox(
            height: 10.0,
          ),
          ForumSubjectCell(
            subjects: <String>[
              '#最后悔的\n一件事#',
              '#给你1个亿\n你有啥计划#',
              '#推荐一本你\n最喜欢的书#',
              '#给你1个亿\n你有啥计划#',
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          ForumActivityCell(),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
