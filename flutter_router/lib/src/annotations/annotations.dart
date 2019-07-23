import 'package:meta/meta.dart';

class Component {
  Component({
    @required this.routeName,
    this.autowired = true,
  }) : assert(routeName != null && routeName.isNotEmpty);

  final String routeName;
  final bool autowired;
}

class Autowired {
  Autowired({
    this.name,
  });

  final String name;
}

class Ignored {}
