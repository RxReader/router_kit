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
//              AppRouter.defaultRouter(context)
//                  .pushNamed(PaymentComponentProvider.routeName)
//                  .then((dynamic resp) => print('resp: $resp'));
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
//              AppRouter.defaultRouter(context).pushNamed(
//                ParamsComponentProvider.routeName,
//                arguments:
//                ParamsComponentProvider.routeArgument('aaa', paramB: 'bbb'),
//              );
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
//              AppRouter.defaultRouter(context)
//                  .pushNamed(AboutComponentProvider.routeName);
            },
          ),
        ],
      ),
    );
  }
}
