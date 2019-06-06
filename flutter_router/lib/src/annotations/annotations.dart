import 'package:meta/meta.dart';

abstract class FRouter {
}

class NameRouter implements FRouter {
  const NameRouter({
    @required this.name,
  }) : assert(name != null);

  final String name;
}

class NotFoundRouter implements FRouter {
  const NotFoundRouter();
}
