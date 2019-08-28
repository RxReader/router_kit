part of 'zip_file.dart';

class ZipException implements IOException {
  const ZipException(this.message);

  final String message;

  @override
  String toString() {
    return 'ZipException: $message';
  }
}
