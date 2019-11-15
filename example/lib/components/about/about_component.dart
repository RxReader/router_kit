import 'dart:math' as math;

import 'package:example/widgets/red_blue_voting.dart';
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
        ],
      ),
    );
  }
}
