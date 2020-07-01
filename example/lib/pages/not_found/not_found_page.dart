import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as router;

part 'not_found_page.g.dart';

@router.Page(
  routeName: '/not_found',
)
class NotFoundPage extends StatefulWidget {
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
        title: const Text('404 Page Not Found!'),
      ),
    );
  }
}
