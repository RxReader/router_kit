part of 'zip_file.dart';

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}

class LocalFileHeader {}

class CentralDirectory {
  CentralDirectory({
    this.fileHeaders,
    this.digitalSignature,
  });

  final List<CentralDirectoryFileHeader> fileHeaders;
  final CentralDirectoryDigitalSignature digitalSignature;
}

class CentralDirectoryFileHeader extends ZipField {}

class CentralDirectoryDigitalSignature extends ZipField {}

class Zip64EndOfCentralDirectoryRecord extends ZipField {
  Zip64EndOfCentralDirectoryRecord({
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

  static const int headerSignature = 0x06064b50;

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
    return 'Zip64EndOfCentralDirectoryRecord{signature: $signature, sizeOfEndOfCentralDirectoryRecord: $sizeOfEndOfCentralDirectoryRecord, versionMadeBy: $versionMadeBy, versionNeededToExtract: $versionNeededToExtract, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, centralDirectoryOffset: $centralDirectoryOffset}';
  }
}

class Zip64EndOfCentralDirectoryLocator extends ZipField {
  Zip64EndOfCentralDirectoryLocator({
    @required int signature,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.relativeOffset,
    @required this.totalDisks,
  }) : super(signature: signature);

  static const int headerSignature = 0x07064b50;
  static const int locatorLength = 20;

  final int numberOfDiskWithCentralDirectory;
  final int relativeOffset;
  final int totalDisks;

  @override
  String toString() {
    return 'Zip64EndOfCentralDirectoryLocator{signature: $signature, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, relativeOffset: $relativeOffset, totalDisks: $totalDisks}';
  }
}

class EndOfCentralDirectoryRecord extends ZipField {
  EndOfCentralDirectoryRecord({
    @required int signature,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.centralDirectoryOffset,
    @required this.commentLength,
  }) : super(signature: signature);

  static const int headerSignature = 0x06054b50;
  static const int eocdLength = 22;
  static const int eocdCommentLengthMax = 65535; // longest possible in ushort
  static const int eocdSearchLengthMax = eocdLength + eocdCommentLengthMax;

  final int numberOfDisk;
  final int numberOfDiskWithCentralDirectory;
  final int totalEntriesOfDisk;
  final int totalEntriesInCentralDirectory;
  final int centralDirectorySize;
  final int centralDirectoryOffset;
  final int commentLength;

  @override
  String toString() {
    return 'EndOfCentralDirectoryRecord{signature: $signature, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, startOffset: $centralDirectoryOffset, commentLength: $commentLength}';
  }
}
