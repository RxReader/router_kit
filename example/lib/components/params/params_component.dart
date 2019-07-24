import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart';

@Component(routeName: '/params')
// ignore: must_be_immutable
class ParamsComponent extends StatefulWidget {
  ParamsComponent({
    Key key,
    @required this.paramA,
    this.paramB,
  }) : super(key: key);

  final String paramA;

  @Autowired(name: 'paramC')
  final String paramB;

  @Ignored()
  String paramC;

  @override
  State<StatefulWidget> createState() {
    return _ParamsComponentState();
  }
}

class _ParamsComponentState extends State<ParamsComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Params'),
      ),
      body: Center(
        child: Text('${widget.paramA} - ${widget.paramB} - ${widget.paramC}'),
      ),
    );
  }
}
