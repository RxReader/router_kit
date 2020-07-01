import 'package:example/pages/about/about_page.dart';
import 'package:example/pages/params/params_page.dart';
import 'package:example/pages/payment/payment_page.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart' as router;

part 'home_page.g.dart';

@router.Page(
  routeName: Navigator.defaultRouteName,
)
class HomePage extends StatefulWidget {
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
            title: const Text('Payment'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(PaymentPageProvider.routeName)
                  .then((dynamic resp) => print('resp: $resp'));
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
              AppRouter.defaultRouter(context).pushNamed(
                ParamsPageProvider.routeName,
                arguments:
                ParamsPageProvider.routeArgument('aaa', paramB: 'bbb'),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(AboutPageProvider.routeName);
            },
          ),
        ],
      ),
    );
  }
}
