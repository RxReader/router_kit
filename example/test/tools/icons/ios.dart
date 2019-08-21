class IosIconTemplate {
  IosIconTemplate({
    this.name,
    this.size,
  });

  final String name;
  final int size;
}

List<IosIconTemplate> iosIcons = <IosIconTemplate>[
  IosIconTemplate(name: 'Icon-App-20x20@1x', size: 20),
  IosIconTemplate(name: 'Icon-App-20x20@2x', size: 40),
  IosIconTemplate(name: 'Icon-App-20x20@3x', size: 60),
  IosIconTemplate(name: 'Icon-App-29x29@1x', size: 29),
  IosIconTemplate(name: 'Icon-App-29x29@2x', size: 58),
  IosIconTemplate(name: 'Icon-App-29x29@3x', size: 87),
  IosIconTemplate(name: 'Icon-App-40x40@1x', size: 40),
  IosIconTemplate(name: 'Icon-App-40x40@2x', size: 80),
  IosIconTemplate(name: 'Icon-App-40x40@3x', size: 120),
  IosIconTemplate(name: 'Icon-App-60x60@2x', size: 120),
  IosIconTemplate(name: 'Icon-App-60x60@3x', size: 180),
  IosIconTemplate(name: 'Icon-App-76x76@1x', size: 76),
  IosIconTemplate(name: 'Icon-App-76x76@2x', size: 152),
  IosIconTemplate(name: 'Icon-App-83.5x83.5@2x', size: 167),
  IosIconTemplate(name: 'Icon-App-1024x1024@1x', size: 1024),
];

void createDefaultIcons(String icon) {}
