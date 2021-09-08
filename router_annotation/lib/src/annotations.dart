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
    this.flavor,
  });

  final String name;
  final String routeName;
  final FieldRename fieldRename;
  final String? flavor;
}

class Manifest {
  const Manifest();
}
