enum FieldRename {
  none,
  kebab,
  snake,
  pascal,
}

class Page {
  const Page({
    required this.name,
    required this.routeName,
    this.fieldRename = FieldRename.snake,
  });

  final String name;
  final String routeName;
  final FieldRename fieldRename;
}

class Controller {}
