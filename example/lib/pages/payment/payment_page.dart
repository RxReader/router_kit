import 'package:example/app/app.dart';
import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'payment_page.g.dart';

@rca.Page(
  name: '购买',
  routeName: '/payment',
  interceptors: <rca.RouteInterceptor>[
    App.globalAuth,
  ],
)
class PaymentPage extends StatefulWidget {
  const PaymentPage(this.paramA, [Key key, this.paramB]) : super(key: key);

  final String paramA;

  final String paramB;

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
