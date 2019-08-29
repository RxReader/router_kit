part of 'zip_file.dart';

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}

class LocalFile extends ZipField {
  LocalFile({
    @required int signature,
    @required this.versionNeededToExtract,
    @required this.generalPurposeBitFlag,
    @required this.compressionMethod,
    @required this.lastModFileTime,
    @required this.lastModFileDate,
    @required this.crc32,
    @required this.compressedSize,
    @required this.uncompressedSize,
    @required this.fileName,
    @required this.fileDataOffset,
    @required this.file,
    @required this.password,
  }) : super(signature: signature);

  static const int headerSignature = 0x04034b50;

  final int versionNeededToExtract;
  final int generalPurposeBitFlag;
  final int compressionMethod;
  final int lastModFileTime;
  final int lastModFileDate;
  final int crc32;
  final int compressedSize;
  final int uncompressedSize;
  final String fileName;
  final int fileDataOffset;
  final File file;
  final String password;
}

class CentralDirectoryFileHeader extends ZipField {
  CentralDirectoryFileHeader({
    @required int signature,
    @required this.versionMadeBy,
    @required this.versionNeededToExtract,
    @required this.generalPurposeBitFlag,
    @required this.compressionMethod,
    @required this.lastModFileTime,
    @required this.lastModFileDate,
    @required this.crc32,
    @required this.compressedSize,
    @required this.uncompressedSize,
    @required this.diskNumberStart,
    @required this.internalFileAttributes,
    @required this.externalFileAttributes,
    @required this.relativeOffsetOfLocalHeader,
    @required this.fileName,
  }) : super(signature: signature);

  static const int headerSignature = 0x02014b50;

  final int versionMadeBy;
  final int versionNeededToExtract;
  final int generalPurposeBitFlag;
  final int compressionMethod;
  final int lastModFileTime;
  final int lastModFileDate;
  final int crc32;
  final int compressedSize;
  final int uncompressedSize;
  final int diskNumberStart;
  final int internalFileAttributes;
  final int externalFileAttributes;
  final int relativeOffsetOfLocalHeader;
  final String fileName;

  @override
  String toString() {
    return 'CentralDirectoryFileHeader{signature: $signature, versionMadeBy: $versionMadeBy, versionNeededToExtract: $versionNeededToExtract, generalPurposeBitFlag: $generalPurposeBitFlag, compressionMethod: $compressionMethod, lastModFileTime: $lastModFileTime, lastModFileDate: $lastModFileDate, crc32: $crc32, compressedSize: $compressedSize, uncompressedSize: $uncompressedSize, diskNumberStart: $diskNumberStart, internalFileAttributes: $internalFileAttributes, externalFileAttributes: $externalFileAttributes, relativeOffsetOfLocalHeader: $relativeOffsetOfLocalHeader, fileName: $fileName}';
  }
}

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
  }) : super(signature: signature);

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

  @override
  String toString() {
    return 'EndOfCentralDirectoryRecord{signature: $signature, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, startOffset: $centralDirectoryOffset}';
  }
}
