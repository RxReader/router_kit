import 'package:example/app/app.manifest.g.dart';
import 'package:example/pages/about/about_page.dart';
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
  const HomePage({Key? key}) : super(key: key);

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
              // Navigator.of(context).pushNamed(PaymentPageProvider.routeName);
            },
          ),
          ListTile(
            title: const Text('Params'),
            onTap: () {
              // Navigator.of(context).pushNamed(
              //   ParamsPageProvider.routeName,
              //   arguments: ParamsPageProvider.routeArgument('aaa', paramB: 'bbb'),
              // );
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              // Navigator.of(context).pushNamed(AboutPageProvider.routeName);
              AppNavigator.pushNamed(context, AboutPageProvider.routeName);
            },
          ),
        ],
      ),
    );
  }
}
