import 'package:flutter/material.dart';

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
