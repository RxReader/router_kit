import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'not_found_page.g.dart';

@rca.Page(
  name: '404',
  routeName: '/not_found',
)
class NotFoundPage extends StatefulWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotFoundPageState();
  }
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('404 Page Not Found!'),
      ),
    );
  }
}
