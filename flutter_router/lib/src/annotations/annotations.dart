import 'package:meta/meta.dart';

class Component {
  const Component({
    @required this.routeName,
    this.autowired = true,
  }) : assert(routeName != null);

  final String routeName;
  final bool autowired;
}

class Autowired {
  const Autowired({
    this.name,
  });

  final String name;
}

class Ignored {
  const Ignored();
}
