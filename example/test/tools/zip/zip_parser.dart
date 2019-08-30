part of 'zip_file.dart';

bool _isEncrypted(int bitFlag) {
  return (bitFlag & 0x0001) == 0x0001;
}

bool _isDataDescriptorExists(int bitFlag) {
  return (bitFlag & 0x0008) == 0x0008;
}

bool _isFileNameUTF8Encoded(int bitFlag) {
  return (bitFlag & 0x0800) == 0x0800;
}

int _checkLength(FileReader reader) {
  // Error out early if the file is too short or non-existent.
  int length = reader.length();
  if (length < EndOfCentralDirectoryRecord.eocdLength) {
    throw ZipException('File too short to be a zip file: $length');
  }
  return length;
}

int _checkEOCDOffset(FileReader reader, int length) {
  // The directory and archive contents are written to the end of the zip
  // file.  We need to search from the end to find these structures,
  // starting with the 'End of central directory' record (EOCD).
  int eocdSearchLength =
      math.min(length, EndOfCentralDirectoryRecord.eocdSearchLengthMax);
  int eocdOffset;
  for (int i = EndOfCentralDirectoryRecord.eocdLength;
      i <= eocdSearchLength;
      i++) {
    int offset = length - i;
    reader.seek(offset);
    if (reader.readUint32(Endian.little) ==
        EndOfCentralDirectoryRecord.headerSignature) {
      eocdOffset = offset;
      break;
    }
  }
  if (eocdOffset == null) {
    throw ZipException('Could not find End of Central Directory Record');
  }
  return eocdOffset;
}

EndOfCentralDirectoryRecord _parseEndOfCentralDirectoryRecord(
    FileReader reader, int eocdOffset) {
  reader.seek(eocdOffset);
  int signature = reader.readUint32(Endian.little);
  int numberOfThisDisk = reader.readUint16(Endian.little);
  int numberOfThisDiskStartOfCentralDirectory =
      reader.readUint16(Endian.little);
  int totalNumberOfEntriesInCentralDirectoryOnThisDisk =
      reader.readUint16(Endian.little);
  int totalNumberOfEntriesInCentralDirectory = reader.readUint16(Endian.little);
  int sizeOfCentralDirectory = reader.readUint32(Endian.little);
  int offsetOfStartOfCentralDirectory = reader.readUint32(Endian.little);
  int commentLength = reader.readUint16(Endian.little);
  String comment =
      commentLength > 0 ? reader.readString(commentLength, utf8) : null;
  return EndOfCentralDirectoryRecord(
    signature: signature,
    numberOfThisDisk: numberOfThisDisk,
    numberOfThisDiskStartOfCentralDirectory:
        numberOfThisDiskStartOfCentralDirectory,
    totalNumberOfEntriesInCentralDirectoryOnThisDisk:
        totalNumberOfEntriesInCentralDirectoryOnThisDisk,
    totalNumberOfEntriesInCentralDirectory:
        totalNumberOfEntriesInCentralDirectory,
    sizeOfCentralDirectory: sizeOfCentralDirectory,
    offsetOfStartOfCentralDirectory: offsetOfStartOfCentralDirectory,
    comment: comment,
  );
}

Zip64EndOfCentralDirectoryLocator _parseZip64EndOfCentralDirectoryLocator(
    FileReader reader, int zip64eocdLocatorOffset) {
  reader.seek(zip64eocdLocatorOffset);
  int signature = reader.readUint32(Endian.little);
  if (signature != Zip64EndOfCentralDirectoryLocator.headerSignature) {
    return null;
  }
  int numberOfDiskStartOfZip64EndOfCentralDirectoryRecord =
      reader.readUint32(Endian.little);
  int offsetZip64EndOfCentralDirectoryRecord = reader.readUint64(Endian.little);
  int totalNumberOfDisks = reader.readUint32(Endian.little);
  return Zip64EndOfCentralDirectoryLocator(
    signature: signature,
    numberOfDiskStartOfZip64EndOfCentralDirectoryRecord:
        numberOfDiskStartOfZip64EndOfCentralDirectoryRecord,
    offsetZip64EndOfCentralDirectoryRecord:
        offsetZip64EndOfCentralDirectoryRecord,
    totalNumberOfDisks: totalNumberOfDisks,
  );
}

Zip64EndOfCentralDirectoryRecord _parseZip64EndOfCentralDirectoryRecord(
    FileReader reader, int zip64EOCDRecordOffset) {
  reader.seek(zip64EOCDRecordOffset);
  int signature = reader.readUint32(Endian.little);
  if (signature != Zip64EndOfCentralDirectoryRecord.headerSignature) {
    throw ZipException(
        "Invalid signature for zip64 end of central directory record");
  }
  int sizeOfZip64EndCentralDirectoryRecord = reader.readUint64(Endian.little);
  int versionMadeBy = reader.readUint16(Endian.little);
  int versionNeededToExtract = reader.readUint16(Endian.little);
  int numberOfThisDisk = reader.readUint32(Endian.little);
  int numberOfThisDiskStartOfCentralDirectory =
      reader.readUint32(Endian.little);
  int totalNumberOfEntriesInCentralDirectoryOnThisDisk =
      reader.readUint64(Endian.little);
  int totalNumberOfEntriesInCentralDirectory = reader.readUint64(Endian.little);
  int sizeOfCentralDirectory = reader.readUint64(Endian.little);
  int offsetStartCentralDirectoryWRTStartDiskNumber =
      reader.readUint64(Endian.little);
  int extensibleDataSectorLength = sizeOfZip64EndCentralDirectoryRecord - 44;
  reader.skip(extensibleDataSectorLength); // zip64 extensible data sector
  return Zip64EndOfCentralDirectoryRecord(
    signature: signature,
    sizeOfZip64EndCentralDirectoryRecord: sizeOfZip64EndCentralDirectoryRecord,
    versionMadeBy: versionMadeBy,
    versionNeededToExtract: versionNeededToExtract,
    numberOfThisDisk: numberOfThisDisk,
    numberOfThisDiskStartOfCentralDirectory:
        numberOfThisDiskStartOfCentralDirectory,
    totalNumberOfEntriesInCentralDirectoryOnThisDisk:
        totalNumberOfEntriesInCentralDirectoryOnThisDisk,
    totalNumberOfEntriesInCentralDirectory:
        totalNumberOfEntriesInCentralDirectory,
    sizeOfCentralDirectory: sizeOfCentralDirectory,
    offsetStartCentralDirectoryWRTStartDiskNumber:
        offsetStartCentralDirectoryWRTStartDiskNumber,
  );
}

CentralDirectory _parseCentralDirectory(FileReader reader, Encoding charset,
    int offsetCentralDirectory, int numberOfEntriesInCentralDirectory) {
  reader.seek(offsetCentralDirectory);
  List<CentralDirectoryFileHeader> fileHeaders = <CentralDirectoryFileHeader>[];
  for (int i = 0; i < numberOfEntriesInCentralDirectory; i++) {
    int signature = reader.readUint32(Endian.little);
    if (signature != CentralDirectoryFileHeader.headerSignature) {
      throw ZipException(
          'Expected central directory entry not found (#${i + 1})');
    }
    int versionMadeBy = reader.readUint16(Endian.little);
    int versionNeededToExtract = reader.readUint16(Endian.little);
    int generalPurposeBitFlag = reader.readUint16(Endian.little);
    int compressionMethod = reader.readUint16(Endian.little);
    int lastModFileTime = reader.readUint16(Endian.little);
    int lastModFileDate = reader.readUint16(Endian.little);
    int crc32 = reader.readUint32(Endian.little);
    int compressedSize = reader.readUint32(Endian.little);
    int uncompressedSize = reader.readUint32(Endian.little);
    int fileNameLength = reader.readUint16(Endian.little);
    int extraFieldLength = reader.readUint16(Endian.little);
    int fileCommentLength = reader.readUint16(Endian.little);
    int diskNumberStart = reader.readUint16(Endian.little);
    int internalFileAttributes = reader.readUint16(Endian.little);
    int externalFileAttributes = reader.readUint32(Endian.little);
    int offsetOfLocalHeader = reader.readUint32(Endian.little);
    String fileName = reader.readString(fileNameLength,
        _isFileNameUTF8Encoded(generalPurposeBitFlag) ? utf8 : charset);
    if (fileName.contains(':\\')) {
      fileName = fileName.substring(fileName.indexOf(':\\') + 2);
    }
    List<ExtraField> extraFields = <ExtraField>[];
    // extra field (variable size)
    Zip64ExtendedInfo zip64extendedInfo;
    AesExtraDataRecord aesExtraDataRecord;
    int offset = reader.offset();
    while (reader.offset() < offset + extraFieldLength) {
      int headerID = reader.readUint16(Endian.little);
      int dataSize = reader.readUint16(Endian.little);
      switch (headerID) {
        case 0x0001:
          int uncompressedSize = reader.readUint64(Endian.little);
          int compressedSize = reader.readUint64(Endian.little);
          int offsetOfLocalHeader = reader.readUint64(Endian.little);
          int diskNumberStart = reader.readUint32(Endian.little);
          zip64extendedInfo = Zip64ExtendedInfo(
            signature: signature,
            headerID: headerID,
            dataSize: dataSize,
            uncompressedSize: uncompressedSize,
            compressedSize: compressedSize,
            offsetOfLocalHeader: offsetOfLocalHeader,
            diskNumberStart: diskNumberStart,
          );
          extraFields.add(zip64extendedInfo);
          break;
        case 0x9901:
          // 摘自：zip4j
          int offsetMark = reader.offset();
          int aesVersion = reader.readUint16(Endian.little);
          String vendorID = reader.readString(2);
          int aesKeyStrength = reader.readUint8();
          int compressionMethod = reader.readUint16(Endian.little);
          aesExtraDataRecord = AesExtraDataRecord(
            signature: signature,
            headerID: headerID,
            dataSize: dataSize,
            aesVersion: aesVersion,
            vendorID: vendorID,
            aesKeyStrength: aesKeyStrength,
            compressionMethod: compressionMethod,
          );
          extraFields.add(aesExtraDataRecord);
          reader.seek(offsetMark);
          reader.skip(dataSize);
          break;
        default:
          List<int> extraData = reader.read(dataSize);
          extraFields.add(GeneralExtraField(
            signature: signature,
            headerID: headerID,
            dataSize: dataSize,
            extraData: extraData,
          ));
          break;
      }
    }
    String fileComment = fileCommentLength > 0
        ? reader.readString(fileCommentLength,
            _isFileNameUTF8Encoded(generalPurposeBitFlag) ? utf8 : charset)
        : null;
    CentralDirectoryFileHeader fileHeader = CentralDirectoryFileHeader(
      signature: signature,
      versionMadeBy: versionMadeBy,
      versionNeededToExtract: versionNeededToExtract,
      generalPurposeBitFlag: generalPurposeBitFlag,
      compressionMethod: compressionMethod,
      lastModFileTime: lastModFileTime,
      lastModFileDate: lastModFileDate,
      crc32: crc32,
      compressedSize: compressedSize,
      uncompressedSize: uncompressedSize,
      diskNumberStart: diskNumberStart,
      internalFileAttributes: internalFileAttributes,
      externalFileAttributes: externalFileAttributes,
      offsetOfLocalHeader: offsetOfLocalHeader,
      fileName: fileName,
      extraFields: extraFields,
      zip64extendedInfo: zip64extendedInfo,
      aesExtraDataRecord: aesExtraDataRecord,
      fileComment: fileComment,
    );
    fileHeaders.add(fileHeader);
  }
  int signature = reader.readUint32(Endian.little);
  int sizeOfData = reader.readUint16(Endian.little);
  List<int> signatureData = reader.read(sizeOfData);
  CentralDirectoryDigitalSignature digitalSignature =
      CentralDirectoryDigitalSignature(
    signature: signature,
    sizeOfData: sizeOfData,
    signatureData: signatureData,
  );
  return CentralDirectory(
    fileHeaders: fileHeaders,
    digitalSignature: digitalSignature,
  );
}

//LocalFile _parseLocalFile(File file, String password, Encoding charset,
//    FileReader reader, CentralDirectoryFileHeader fileHeader) {
//  reader.seek(fileHeader.relativeOffsetOfLocalHeader);
//  int signature = reader.readUint32(Endian.little);
//  if (signature != LocalFile.headerSignature) {
//    throw ZipException('Invalid Zip Signature');
//  }
//  int versionNeededToExtract = reader.readUint16(Endian.little);
//  int generalPurposeBitFlag = reader.readUint16(Endian.little);
//  int compressionMethod = reader.readUint16(Endian.little);
//  int lastModFileTime = reader.readUint16(Endian.little);
//  int lastModFileDate = reader.readUint16(Endian.little);
//  int crc32 = reader.readUint32(Endian.little);
//  int compressedSize = reader.readUint32(Endian.little);
//  int uncompressedSize = reader.readUint32(Endian.little);
//  int fileNameLength = reader.readUint16(Endian.little);
//  int extraFieldLength = reader.readUint16(Endian.little);
//  String fileName = reader.readString(fileNameLength, _utf8Encoded(generalPurposeBitFlag) ? utf8 : charset);
//  reader.skip(extraFieldLength);
//  int fileDataOffset = reader.offset();
//  reader.skip(compressedSize);
//  if (generalPurposeBitFlag & 0x0008 != 0x0008) {
//    int sigOrCrc = reader.readUint32(Endian.little);
//    if (sigOrCrc == 0x08074b50) {
//      crc32 = reader.readUint32(Endian.little);
//    } else {
//      crc32 = sigOrCrc;
//    }
//    compressedSize = reader.readUint32(Endian.little);
//    uncompressedSize = reader.readUint32(Endian.little);
//  }
//  return LocalFile(
//    signature: signature,
//    versionNeededToExtract: versionNeededToExtract,
//    generalPurposeBitFlag: generalPurposeBitFlag,
//    compressionMethod: compressionMethod,
//    lastModFileTime: lastModFileTime,
//    lastModFileDate: lastModFileDate,
//    crc32: crc32,
//    compressedSize: compressedSize,
//    uncompressedSize: uncompressedSize,
//    fileName: fileName,
//    fileDataOffset: fileDataOffset,
//    file: file,
//    password: password,
//  );
//}
