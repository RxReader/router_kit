import 'package:example/components/about/about_component.dart';
import 'package:example/components/params/params_component.dart';
import 'package:example/components/payment/payment_component.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'home_component.c.dart';

@Component(
  routeName: Navigator.defaultRouteName,
)
class HomeComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeComponentState();
  }
}

class _HomeComponentState extends State<HomeComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Router'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Banner'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(AboutComponentProvider.routeName);
            },
          ),
          ListTile(
            title: const Text('Payment'),
            onTap: () {
              AppRouter.defaultRouter(context)
                  .pushNamed(PaymentComponentProvider.routeName)
                  .then((dynamic resp) => print('resp: $resp'));
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
              AppRouter.defaultRouter(context).pushNamed(
                ParamsComponentProvider.routeName,
                arguments:
                ParamsComponentProvider.routeArgument('aaa', paramB: 'bbb'),
              );
            },
          ),
        ],
      ),
    );
  }
}
