import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'payment_page.g.dart';

@rca.Page(
  name: '购买',
  routeName: '/payment',
)
class PaymentPage extends StatefulWidget {
  const PaymentPage(
    this.paramA,
    this.paramAA,[
    Key? key,
    this.paramB,
    this.paramC = 'abc',
    this.paramD = 'asd',
  ]) : super(key: key);

  final String paramA;
  final String? paramAA;

  final String? paramB;
  final String paramC;
  final String? paramD;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Pay'),
            onTap: () {
              Navigator.of(context).pop('Click Pay');
            },
          ),
        ],
      ),
    );
  }
}
