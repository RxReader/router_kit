import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'reader_component.component.dart';

@Component(
  routeName: '/reader',
)
class ReaderComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReaderComponentState();
  }
}

class _ReaderComponentState extends State<ReaderComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
      ),
    );
  }
}
