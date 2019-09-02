part of 'zip_file.dart';

class CompressionMethod {
  CompressionMethod._();

  static const int store = 0;
  static const int deflate = 8;
  static const int aesInternalOnly = 99;
}

class AesKeyStrength {
  AesKeyStrength._();

  static const int keyStrength128 = 1;
  static const int keyStrength192 = 2;
  static const int keyStrength256 = 3;
}

abstract class ExtraField {
  ExtraField({
    @required this.headerID,
    @required this.dataSize,
  });

  final int headerID;
  final int dataSize;
}

class GeneralExtraField extends ExtraField {
  GeneralExtraField({
    @required int headerID,
    @required int dataSize,
    @required this.extraData,
  }) : super(headerID: headerID, dataSize: dataSize);

  List<int> extraData;
}

class Zip64ExtendedInfo extends ExtraField {
  Zip64ExtendedInfo({
    @required int headerID,
    @required int dataSize,
    @required this.uncompressedSize,
    @required this.compressedSize,
    @required this.offsetOfLocalHeader,
    @required this.diskNumberStart,
  }) : super(headerID: headerID, dataSize: dataSize);

  static const int headerSignature = 0x0001;

  final int uncompressedSize;
  final int compressedSize;
  final int offsetOfLocalHeader;
  final int diskNumberStart;
}

class AesExtraDataRecord extends ExtraField {
  AesExtraDataRecord({
    @required int headerID,
    @required int dataSize,
    @required this.aesVersion,
    @required this.vendorID,
    @required this.aesKeyStrength,
    @required this.compressionMethod,
  }) : super(headerID: headerID, dataSize: dataSize);

  static const int headerSignature = 0x9901;

  final int aesVersion;
  final String vendorID;
  final int aesKeyStrength;
  final int compressionMethod;
}

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}

class LocalFileHeader extends ZipField {
  LocalFileHeader({
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
    @required this.extraFields,
    @required this.zip64extendedInfo,
    @required this.aesExtraDataRecord,
  }) : super(signature: signature);

  static const int headerSignature = 0x04034b50;

  final int versionNeededToExtract;
  final int generalPurposeBitFlag;
  final int compressionMethod;
  final List<int> lastModFileTime;
  final List<int> lastModFileDate;
  final int crc32;
  final int compressedSize;
  final int uncompressedSize;
  final String fileName;
  final List<ExtraField> extraFields;
  final Zip64ExtendedInfo zip64extendedInfo;
  final AesExtraDataRecord aesExtraDataRecord;

  bool get isEncrypted => _isEncrypted(generalPurposeBitFlag);

  bool get isDataDescriptorExists =>
      _isDataDescriptorExists(generalPurposeBitFlag);

  bool get isStrongEncryption => _isStrongEncryption(generalPurposeBitFlag);

  bool get isFileNameUTF8Encoded =>
      _isFileNameUTF8Encoded(generalPurposeBitFlag);

  bool get isDirectory => fileName.endsWith('/') || fileName.endsWith('\\');
}

class DataDescriptor extends ZipField {
  DataDescriptor({
    @required int signature,
    @required this.crc,
    @required this.compressedSize,
    @required this.uncompressedSize,
  }) : super(signature: signature);

  static const int extraDataRecord = 0x08074b50;

  final int crc;
  final int compressedSize;
  final int uncompressedSize;
}

class CentralDirectory {
  CentralDirectory({
    @required this.fileHeaders,
    @required this.digitalSignature,
  });

  final List<CentralDirectoryFileHeader> fileHeaders;
  final CentralDirectoryDigitalSignature digitalSignature;
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
    @required this.offsetOfLocalHeader,
    @required this.fileName,
    @required this.extraFields,
    @required this.zip64extendedInfo,
    @required this.aesExtraDataRecord,
    @required this.fileComment,
  }) : super(signature: signature);

  static const int headerSignature = 0x02014b50;

  final int versionMadeBy;
  final int versionNeededToExtract;
  final int generalPurposeBitFlag;
  final int compressionMethod;
  final List<int> lastModFileTime;
  final List<int> lastModFileDate;
  final int crc32;
  final int compressedSize;
  final int uncompressedSize;
  final int diskNumberStart;
  final int internalFileAttributes;
  final int externalFileAttributes;
  final int offsetOfLocalHeader;
  final String fileName;
  final List<ExtraField> extraFields;
  final Zip64ExtendedInfo zip64extendedInfo;
  final AesExtraDataRecord aesExtraDataRecord;
  final String fileComment;

  bool get isEncrypted => _isEncrypted(generalPurposeBitFlag);

  bool get isDataDescriptorExists =>
      _isDataDescriptorExists(generalPurposeBitFlag);

  bool get isStrongEncryption => _isStrongEncryption(generalPurposeBitFlag);

  bool get isFileNameUTF8Encoded =>
      _isFileNameUTF8Encoded(generalPurposeBitFlag);

  bool get isDirectory => fileName.endsWith('/') || fileName.endsWith('\\');
}

class CentralDirectoryDigitalSignature extends ZipField {
  CentralDirectoryDigitalSignature({
    @required int signature,
    @required this.sizeOfData,
    @required this.signatureData,
  }) : super(signature: signature);

  final int sizeOfData;
  final List<int> signatureData;
}

class Zip64EndOfCentralDirectoryRecord extends ZipField {
  Zip64EndOfCentralDirectoryRecord({
    @required int signature,
    @required this.sizeOfZip64EndCentralDirectoryRecord,
    @required this.versionMadeBy,
    @required this.versionNeededToExtract,
    @required this.numberOfThisDisk,
    @required this.numberOfThisDiskStartOfCentralDirectory,
    @required this.totalNumberOfEntriesInCentralDirectoryOnThisDisk,
    @required this.totalNumberOfEntriesInCentralDirectory,
    @required this.sizeOfCentralDirectory,
    @required this.offsetStartCentralDirectoryWRTStartDiskNumber,
  }) : super(signature: signature);

  static const int headerSignature = 0x06064b50;

  final int sizeOfZip64EndCentralDirectoryRecord;
  final int versionMadeBy;
  final int versionNeededToExtract;
  final int numberOfThisDisk;
  final int numberOfThisDiskStartOfCentralDirectory;
  final int totalNumberOfEntriesInCentralDirectoryOnThisDisk;
  final int totalNumberOfEntriesInCentralDirectory;
  final int sizeOfCentralDirectory;
  final int offsetStartCentralDirectoryWRTStartDiskNumber;
}

class Zip64EndOfCentralDirectoryLocator extends ZipField {
  Zip64EndOfCentralDirectoryLocator({
    @required int signature,
    @required this.numberOfDiskStartOfZip64EndOfCentralDirectoryRecord,
    @required this.offsetZip64EndOfCentralDirectoryRecord,
    @required this.totalNumberOfDisks,
  }) : super(signature: signature);

  static const int headerSignature = 0x07064b50;
  static const int locatorLength = 20;

  final int numberOfDiskStartOfZip64EndOfCentralDirectoryRecord;
  final int offsetZip64EndOfCentralDirectoryRecord;
  final int totalNumberOfDisks;
}

class EndOfCentralDirectoryRecord extends ZipField {
  EndOfCentralDirectoryRecord({
    @required int signature,
    @required this.numberOfThisDisk,
    @required this.numberOfThisDiskStartOfCentralDirectory,
    @required this.totalNumberOfEntriesInCentralDirectoryOnThisDisk,
    @required this.totalNumberOfEntriesInCentralDirectory,
    @required this.sizeOfCentralDirectory,
    @required this.offsetOfStartOfCentralDirectory,
    @required this.comment,
  }) : super(signature: signature);

  static const int headerSignature = 0x06054b50;
  static const int eocdLength = 22;
  static const int eocdCommentLengthMax = 65535; // longest possible in ushort
  static const int eocdSearchLengthMax = eocdLength + eocdCommentLengthMax;

  final int numberOfThisDisk;
  final int numberOfThisDiskStartOfCentralDirectory;
  final int totalNumberOfEntriesInCentralDirectoryOnThisDisk;
  final int totalNumberOfEntriesInCentralDirectory;
  final int sizeOfCentralDirectory;
  final int offsetOfStartOfCentralDirectory;
  final String comment;
}
