import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as router;

part 'payment_page.g.dart';

@router.Page(
  routeName: '/payment',
)
class PaymentPage extends StatefulWidget {
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
