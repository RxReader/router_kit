part of 'zip_file.dart';

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
  int numberOfDisk = reader.readUint16(Endian.little);
  int numberOfDiskWithCentralDirectory = reader.readUint16(Endian.little);
  int totalEntriesOfDisk = reader.readUint16(Endian.little);
  int totalEntriesInCentralDirectory = reader.readUint16(Endian.little);
  int centralDirectorySize = reader.readUint32(Endian.little);
  int centralDirectoryOffset = reader.readUint32(Endian.little);
  int fileCommentLength = reader.readUint16(Endian.little);
  reader.skip(fileCommentLength); // fileComment
  return EndOfCentralDirectoryRecord(
    signature: signature,
    numberOfDisk: numberOfDisk,
    numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
    totalEntriesOfDisk: totalEntriesOfDisk,
    totalEntriesInCentralDirectory: totalEntriesInCentralDirectory,
    centralDirectorySize: centralDirectorySize,
    centralDirectoryOffset: centralDirectoryOffset,
  );
}

Zip64EndOfCentralDirectoryLocator _parseZip64EndOfCentralDirectoryLocator(
    FileReader reader, int zip64EOCDLocatorOffset) {
  reader.seek(zip64EOCDLocatorOffset);
  int signature = reader.readUint32(Endian.little);
  if (signature != Zip64EndOfCentralDirectoryLocator.headerSignature) {
    return null;
  }
  int numberOfDiskWithCentralDirectory = reader.readUint32(Endian.little);
  int relativeOffset = reader.readUint64(Endian.little);
  int totalDisks = reader.readUint32(Endian.little);
  return Zip64EndOfCentralDirectoryLocator(
    signature: signature,
    numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
    relativeOffset: relativeOffset,
    totalDisks: totalDisks,
  );
}

Zip64EndOfCentralDirectoryRecord _parseZip64EndOfCentralDirectoryRecord(
    FileReader reader, int zip64EOCDRecordOffset) {
  reader.seek(zip64EOCDRecordOffset);
  int signature = reader.readUint32(Endian.little);
  if (signature != Zip64EndOfCentralDirectoryRecord.headerSignature) {
    return null;
  }
  int sizeOfEndOfCentralDirectoryRecord = reader.readUint64(Endian.little);
  int versionMadeBy = reader.readUint16(Endian.little);
  int versionNeededToExtract = reader.readUint16(Endian.little);
  int numberOfDisk = reader.readUint32(Endian.little);
  int numberOfDiskWithCentralDirectory = reader.readUint32(Endian.little);
  int totalEntriesOfDisk = reader.readUint64(Endian.little);
  int totalEntriesInCentralDirectory = reader.readUint64(Endian.little);
  int centralDirectorySize = reader.readUint64(Endian.little);
  int centralDirectoryOffset = reader.readUint64(Endian.little);
  // reader.skip(extensibleDataSectorLength);// zip64 extensible data sector
  return Zip64EndOfCentralDirectoryRecord(
    signature: signature,
    sizeOfEndOfCentralDirectoryRecord: sizeOfEndOfCentralDirectoryRecord,
    versionMadeBy: versionMadeBy,
    versionNeededToExtract: versionNeededToExtract,
    numberOfDisk: numberOfDisk,
    numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
    totalEntriesOfDisk: totalEntriesOfDisk,
    totalEntriesInCentralDirectory: totalEntriesInCentralDirectory,
    centralDirectorySize: centralDirectorySize,
    centralDirectoryOffset: centralDirectoryOffset,
  );
}

List<CentralDirectoryFileHeader> _parseCentralDirectory(FileReader reader,
    Encoding charset, int centralDirectoryOffset, int centralDirectorySize) {
  List<CentralDirectoryFileHeader> fileHeaders = <CentralDirectoryFileHeader>[];
  reader.seek(centralDirectoryOffset);
  while (reader.offset() < centralDirectoryOffset + centralDirectorySize) {
    int signature = reader.readUint32(Endian.little);
    switch (signature) {
      case CentralDirectoryFileHeader.headerSignature:
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
        int relativeOffsetOfLocalHeader = reader.readUint32(Endian.little);
        String fileName = reader.readString(fileNameLength, charset);
//          extra field (variable size)
        int offset = reader.offset();
        while (reader.offset() < offset + extraFieldLength) {
          int headerID = reader.readUint16(Endian.little);
          int dataSize = reader.readUint16(Endian.little);
          if (headerID == 0x0001) {
            uncompressedSize = reader.readUint64(Endian.little);
            compressedSize = reader.readUint64(Endian.little);
            relativeOffsetOfLocalHeader = reader.readUint64(Endian.little);
            diskNumberStart = reader.readUint32(Endian.little);
            break;
          } else {
            reader.skip(dataSize);
          }
        }
        reader.seek(offset + extraFieldLength);
        reader.skip(fileCommentLength); // fileComment
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
          relativeOffsetOfLocalHeader: relativeOffsetOfLocalHeader,
          fileName: fileName,
        );
        fileHeaders.add(fileHeader);
        break;
      case 0x05054b50:
        // Digital signature
        int sizeOfData = reader.readUint16(Endian.little);
        reader.skip(sizeOfData);
        break;
    }
  }
  return fileHeaders;
}

LocalFile _parseLocalFile(File file, String password, Encoding charset,
    FileReader reader, CentralDirectoryFileHeader fileHeader) {
  reader.seek(fileHeader.relativeOffsetOfLocalHeader);
  int signature = reader.readUint32(Endian.little);
  if (signature != LocalFile.headerSignature) {
    throw ZipException('Invalid Zip Signature');
  }
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
  String fileName = reader.readString(fileNameLength, charset);
  reader.skip(extraFieldLength);
  int fileDataOffset = reader.offset();
  reader.skip(compressedSize);
  if (generalPurposeBitFlag & 0x08 != 0) {
    int sigOrCrc = reader.readUint32(Endian.little);
    if (sigOrCrc == 0x08074b50) {
      crc32 = reader.readUint32(Endian.little);
    } else {
      crc32 = sigOrCrc;
    }
    compressedSize = reader.readUint32(Endian.little);
    uncompressedSize = reader.readUint32(Endian.little);
  }
  return LocalFile(
    signature: signature,
    versionNeededToExtract: versionNeededToExtract,
    generalPurposeBitFlag: generalPurposeBitFlag,
    compressionMethod: compressionMethod,
    lastModFileTime: lastModFileTime,
    lastModFileDate: lastModFileDate,
    crc32: crc32,
    compressedSize: compressedSize,
    uncompressedSize: uncompressedSize,
    fileName: fileName,
    fileDataOffset: fileDataOffset,
    file: file,
    password: password,
  );
}
