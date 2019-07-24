part of '../navigator_route.dart';

/// TODO 注解自动生成

class ParamsRoute {
  ParamsRoute._();

  static WidgetBuilder route = (BuildContext context) {
    Map<dynamic, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<dynamic, dynamic>;
    return ParamsComponent(
      paramA: arguments['paramA'] as String,
      paramB: arguments['paramC'] as String,
    );
  };

  static Map<dynamic, dynamic> arguments({
    @required String paramA,
    String paramC,
  }) {
    return <dynamic, dynamic>{
      'paramA': 'aaa',
      'paramC': 'ccc',
    };
  }
}
