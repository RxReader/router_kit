part of 'zip_file.dart';

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}


class CentralFileHeader extends ZipField {

}

class DigitalSignature extends ZipField {

}

class Zip64EOCDRecord extends ZipField {
  Zip64EOCDRecord({
    @required int signature,
    @required this.sizeOfEndOfCentralDirectoryRecord,
    @required this.versionMadeBy,
    @required this.versionNeededToExtract,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.centralDirectoryOffset,
  });

  static const int zip64EOCDRecordSignature = 0x06064b50;

  final int sizeOfEndOfCentralDirectoryRecord;
  final int versionMadeBy;
  final int versionNeededToExtract;
  final int numberOfDisk;
  final int numberOfDiskWithCentralDirectory;
  final int totalEntriesOfDisk;
  final int totalEntriesInCentralDirectory;
  final int centralDirectorySize;
  final int centralDirectoryOffset;

  @override
  String toString() {
    return 'Zip64EOCDRecord{signature: $signature, sizeOfEndOfCentralDirectoryRecord: $sizeOfEndOfCentralDirectoryRecord, versionMadeBy: $versionMadeBy, versionNeededToExtract: $versionNeededToExtract, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, centralDirectoryOffset: $centralDirectoryOffset}';
  }
}

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

class EOCDRecord extends ZipField {
  EOCDRecord({
    @required int signature,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.centralDirectoryOffset,
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
  final int centralDirectoryOffset;
  final int commentLength;

  @override
  String toString() {
    return 'EOCDRecord{signature: $signature, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, startOffset: $centralDirectoryOffset, commentLength: $commentLength}';
  }
}
