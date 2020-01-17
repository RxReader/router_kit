import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart';

part 'payment_component.c.dart';

@Component(
  routeName: '/payment',
)
class PaymentComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PaymentComponentState();
  }
}

class _PaymentComponentState extends State<PaymentComponent> {
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
