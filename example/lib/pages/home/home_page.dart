import 'package:example/app/app_router.dart';
import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart' as rca;

part 'home_page.g.dart';

@rca.Page(
  name: '首页',
  routeName: Navigator.defaultRouteName,
)
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouterKit'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Payment'),
            onTap: () {
              AppRouter.instance.pushNamed(
                context,
                PaymentPageProvider.routeName,
                arguments: PaymentPageProvider.routeArgument('a', null),
              );
            },
          ),
          ListTile(
            title: Text('Params'),
            onTap: () {
              AppRouter.instance.pushNamed(
                context,
                ParamsPageProvider.routeName,
                arguments: ParamsPageProvider.routeArgument('aaa', paramB: 'bbb'),
              );
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              AppRouter.instance.pushNamed(context, AboutPageProvider.routeName);
            },
          ),
        ],
      ),
    );
  }
}
