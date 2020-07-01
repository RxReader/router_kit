import 'package:flutter/material.dart';
import 'package:router_annotation/router_annotation.dart' as router;

part 'login_page.g.dart';

@router.Page(
  routeName: '/login',
)
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Login'),
            onTap: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
