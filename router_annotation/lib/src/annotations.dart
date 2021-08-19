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
    this.flavorName,
  });

  final String name;
  final String routeName;
  final FieldRename fieldRename;
  final String? flavorName;
}

class Manifest {
  const Manifest();
}
