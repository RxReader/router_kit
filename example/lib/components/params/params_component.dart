import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart';

part 'params_component.route.dart';

@Component(
  routeName: '/params',
  nameFormatter: toSnakeCase,
)
// ignore: must_be_immutable
class ParamsComponent extends StatefulWidget {
  ParamsComponent(
    this.paramA, {
    Key key,
    @required this.paramB,
    this.paramC,
    @required this.paramE,
  }) : super(key: key);

  final String paramA;

  final String paramB;

  @Alias('paramD')
  final String paramC;

  @Ignore()
  String paramD;

  @Ignore()
  String paramE;

  final String paramF = '';

  String paramG = '';

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
        child: Column(
          children: <Widget>[
            Image.network('https://www.baidu.com/img/bd_logo1.png'),
            Text('${widget.paramA} - ${widget.paramB} - ${widget.paramC}'),
          ],
        ),
      ),
    );
  }
}
