import 'package:example/html/html.dart';
import 'package:example/html/test_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:router_annotation/router_annotation.dart';

part 'html_component.component.dart';

@Component(
  routeName: '/html',
)
class HtmlComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HtmlComponentState();
  }
}

class _HtmlComponentState extends State<HtmlComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Html'),
      ),
//      body: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Text('tag --> bdi'),
//          Text.rich(
//            Html.fromHtml(htmlTestData['bdi'], fontSize: 14),
//            style: TextStyle(fontSize: 14),
//          ),
//        ],
//      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          String key = htmlTestData.keys.toList()[index];
          String value = htmlTestData[key];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('tag --> $key'),
              Text.rich(
                Html.fromHtml(value, fontSize: 14),
                style: TextStyle(fontSize: 14),
              ),
            ],
          );
        },
        itemCount: htmlTestData.keys.toList().length,
      ),
    );
  }
}
