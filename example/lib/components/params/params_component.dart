import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart';

@Component(
  routeName: '/params',
  nameFormatter: toSnakeCase,
)
// ignore: must_be_immutable
class ParamsComponent extends StatefulWidget {
  ParamsComponent({
    Key key,
    @required this.paramA,
    this.paramB,
  }) : super(key: key);

  final String paramA;

  @Alias('paramC')
  final String paramB;

  @Ignore()
  String paramC;

  final String paramD = '';

  String paramE = '';

  static String paramF = '';

  static const String paramG = '';

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
