import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart';

part 'not_found_component.component.dart';

@Component(
  routeName: '/not_found',
)
class NotFoundComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotFoundComponentState();
  }
}

class _NotFoundComponentState extends State<NotFoundComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 Page Not Found!'),
      ),
    );
  }
}
