import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AwkErrorWidget extends StatelessWidget {
  const AwkErrorWidget({
    Key key,
    this.details,
  }) : super(key: key);

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        /// 判断是否全屏
        return Container(
          color: Colors.transparent,
        );
      },
    );
  }

  static ErrorWidgetBuilder builder =
      (FlutterErrorDetails details) => AwkErrorWidget(
            details: details,
          );
}
