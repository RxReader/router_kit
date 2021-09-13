enum FieldRename {
  none,
  kebab,
  snake,
  pascal,
}

class Page {
  const Page({
    this.flavor,
    required this.name,
    required this.routeName,
    this.fieldRename = FieldRename.snake,
  });

  final String? flavor;
  final String name;
  final String routeName;
  final FieldRename fieldRename;
}

class Manifest {
  const Manifest();
}
