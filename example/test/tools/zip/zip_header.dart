part of 'zip_file.dart';

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}

///   G.  Zip64 end of central directory record
///
///        zip64 end of central dir
///        signature                       4 bytes  (0x06064b50)
///        size of zip64 end of central
///        directory record                8 bytes
///        version made by                 2 bytes
///        version needed to extract       2 bytes
///        number of this disk             4 bytes
///        number of the disk with the
///        start of the central directory  4 bytes
///        total number of entries in the
///        central directory on this disk  8 bytes
///        total number of entries in the
///        central directory               8 bytes
///        size of the central directory   8 bytes
///        offset of start of central
///        directory with respect to
///        the starting disk number        8 bytes
///        zip64 extensible data sector    (variable size)
class Zip64EOCDRecord extends ZipField {}

///   H.  Zip64 end of central directory locator
///
///        zip64 end of central dir locator
///        signature                       4 bytes  (0x07064b50)
///        number of the disk with the
///        start of the zip64 end of
///        central directory               4 bytes
///        relative offset of the zip64
///        end of central directory record 8 bytes
///        total number of disks           4 bytes
class Zip64EOCDLocator extends ZipField {
  Zip64EOCDLocator({
    @required int signature,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.relativeOffset,
    @required this.totalDisks,
  }) : super(signature: signature);

  static const int zip64EOCDLocatorSignature = 0x07064b50;
  static const int zip64EOCDLocatorLength = 20;

  final int numberOfDiskWithCentralDirectory;
  final int relativeOffset;
  final int totalDisks;

  @override
  String toString() {
    return 'Zip64EOCDLocator{signature: $signature, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, relativeOffset: $relativeOffset, totalDisks: $totalDisks}';
  }


}

///   I.  End of central directory record:
///
///        end of central dir signature    4 bytes  (0x06054b50)
///        number of this disk             2 bytes
///        number of the disk with the
///        start of the central directory  2 bytes
///        total number of entries in the
///        central directory on this disk  2 bytes
///        total number of entries in
///        the central directory           2 bytes
///        size of the central directory   4 bytes
///        offset of start of central
///        directory with respect to
///        the starting disk number        4 bytes
///        .ZIP file comment length        2 bytes
///        .ZIP file comment       (variable size)
class EOCDRecord extends ZipField {
  EOCDRecord({
    @required int signature,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.startOffset,
    @required this.commentLength,
  }) : super(signature: signature);

  static const int eocdRecordSignature = 0x06054b50;
  static const int eocdRecordLength = 22;
  static const int eocdRecordCommentLengthMax =
      65535; // longest possible in ushort
  static const int eocdRecordSearchLengthMax =
      eocdRecordLength + eocdRecordCommentLengthMax;

  final int numberOfDisk;
  final int numberOfDiskWithCentralDirectory;
  final int totalEntriesOfDisk;
  final int totalEntriesInCentralDirectory;
  final int centralDirectorySize;
  final int startOffset;
  final int commentLength;

  @override
  String toString() {
    return 'EOCDRecord{signature: $signature, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, startOffset: $startOffset, commentLength: $commentLength}';
  }


}
