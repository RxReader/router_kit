import 'package:args/args.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;
import 'android.dart' as android;
import 'ios.dart' as ios;

void main(List<String> args) {
//  print('args: $args');

  ArgParser parser = ArgParser();
  parser.addOption('platform');
  parser.addOption('icon');

  ArgResults results = parser.parse(args);
  String platform = results['platform'];
  String icon = results['icon'];

  switch (platform) {
    case 'android':
      android.createDefaultIcons(icon);
      break;
    case 'ios':
      ios.createDefaultIcons(icon);
      break;
    default:
      throw UnsupportedError('Unsupported Platform: $platform');
  }
}
