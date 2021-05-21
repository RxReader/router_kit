import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'params_page.g.dart';

typedef Callback = String Function(String info);

@rca.Page(
  name: '参数',
  routeName: '/params',
)
// ignore: must_be_immutable
class ParamsPage extends StatefulWidget {
  ParamsPage(
    this.paramA, {
    Key? key,
    required this.paramB,
    this.paramC,
    this.callback,
  }) : super(key: key);

  final String paramA;

  final String paramB;

  final String? paramC;

  final String paramD = '';

  String paramE = '';

  Callback? callback;

  @override
  State<StatefulWidget> createState() {
    return _ParamsPageState();
  }
}

class _ParamsPageState extends State<ParamsPage> {
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
