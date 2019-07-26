import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'splash_component.component.dart';

@Component(
  routeName: '/splash',
)
class SplashComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashComponentState();
  }
}

class _SplashComponentState extends State<SplashComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}
