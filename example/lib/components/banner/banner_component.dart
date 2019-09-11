import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'banner_component.component.dart';

@Component(
  routeName: '/banner',
)
class BannerComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BannerComponentState();
  }
}

class _BannerComponentState extends State<BannerComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
