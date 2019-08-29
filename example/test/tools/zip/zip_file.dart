import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../io/file_reader.dart';

part 'zip_exception.dart';

part 'zip_header.dart';

/// 不支持分卷压缩
/// https://pkware.cachefly.net/webdocs/APPNOTE/APPNOTE-6.2.0.txt
class ZipFile {
  ZipFile(
    File file, [
    Encoding charset = utf8,
  ])  : _file = file,
        _charset = charset {
    int numberThisDisk;
    int numberOfDiskWithCentralDirectory;
    int totalEntriesOfDisk;
    int totalEntriesInCentralDirectory;
    int centralDirectorySize;
    int centralDirectoryOffset;
    FileReader reader;
    try {
      reader = FileReader(file.openSync());
      int length = _checkLength(reader);
      int eocdOffset = _checkEOCDOffset(reader, length);
      EndOfCentralDirectoryRecord eocd =
          _parseEndOfCentralDirectoryRecord(reader, eocdOffset);
      numberThisDisk = eocd.numberOfDisk;
      numberOfDiskWithCentralDirectory = eocd.numberOfDiskWithCentralDirectory;
      totalEntriesOfDisk = eocd.totalEntriesOfDisk;
      totalEntriesInCentralDirectory = eocd.totalEntriesInCentralDirectory;
      centralDirectorySize = eocd.centralDirectorySize;
      centralDirectoryOffset = eocd.centralDirectoryOffset;
      int zip64EOCDLocatorOffset =
          eocdOffset - Zip64EndOfCentralDirectoryLocator.locatorLength;
      if (zip64EOCDLocatorOffset > 0) {
        Zip64EndOfCentralDirectoryLocator zip64EOCDLocator =
            _parseZip64EndOfCentralDirectoryLocator(
                reader, zip64EOCDLocatorOffset);
        if (zip64EOCDLocator != null) {
          Zip64EndOfCentralDirectoryRecord zip64EOCDRecord =
              _parseZip64EndOfCentralDirectoryRecord(
                  reader, zip64EOCDLocator.relativeOffset);
          if (zip64EOCDRecord != null) {
            numberThisDisk = zip64EOCDRecord.numberOfDisk;
            numberOfDiskWithCentralDirectory =
                zip64EOCDRecord.numberOfDiskWithCentralDirectory;
            totalEntriesOfDisk = zip64EOCDRecord.totalEntriesOfDisk;
            totalEntriesInCentralDirectory =
                zip64EOCDRecord.totalEntriesInCentralDirectory;
            centralDirectorySize = zip64EOCDRecord.centralDirectorySize;
            centralDirectoryOffset = zip64EOCDRecord.centralDirectoryOffset;
          }
        }
      }
      List<CentralDirectoryFileHeader> centralDirectoryFileHeaders =
          _parseCentralDirectory(
              reader, centralDirectoryOffset, centralDirectorySize);
      for (CentralDirectoryFileHeader centralDirectoryFileHeader in centralDirectoryFileHeaders) {

      }
    } finally {
      reader?.close();
    }
  }

  final File _file;
  final Encoding _charset;

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

  List<CentralDirectoryFileHeader> _parseCentralDirectory(
      FileReader reader, int centralDirectoryOffset, int centralDirectorySize) {
    List<CentralDirectoryFileHeader> fileHeaders =
        <CentralDirectoryFileHeader>[];
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
          String fileName = reader.readString(fileNameLength, _charset);
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
}
