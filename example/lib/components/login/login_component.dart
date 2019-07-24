import 'package:flutter/material.dart';

class LoginComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginComponentState();
  }
}

class _LoginComponentState extends State<LoginComponent> {
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
