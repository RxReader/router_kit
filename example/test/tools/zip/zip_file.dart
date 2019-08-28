import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../io/file_reader.dart';

part 'zip_exception.dart';

part 'zip_header.dart';

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
      int eocdRecordOffset = _checkEOCDRecord(reader, length);
      EOCDRecord eocdRecord = _parseEOCDRecord(reader, eocdRecordOffset);
      numberThisDisk = eocdRecord.numberOfDisk;
      numberOfDiskWithCentralDirectory = eocdRecord.numberOfDiskWithCentralDirectory;
      totalEntriesOfDisk = eocdRecord.totalEntriesOfDisk;
      totalEntriesInCentralDirectory = eocdRecord.totalEntriesInCentralDirectory;
      centralDirectorySize = eocdRecord.centralDirectorySize;
      centralDirectoryOffset = eocdRecord.centralDirectoryOffset;
      int zip64EOCDLocatorOffset =
          eocdRecordOffset - Zip64EOCDLocator.zip64EOCDLocatorLength;
      if (zip64EOCDLocatorOffset > 0) {
        Zip64EOCDLocator zip64eocdLocator =
            _parseZip64EOCDLocator(reader, zip64EOCDLocatorOffset);
        if (zip64eocdLocator != null) {
          Zip64EOCDRecord zip64eocdRecord =
              _parseZip64EOCDRecord(reader, zip64eocdLocator.relativeOffset);
          if (zip64eocdRecord != null) {
            numberThisDisk = zip64eocdRecord.numberOfDisk;
            numberOfDiskWithCentralDirectory = zip64eocdRecord.numberOfDiskWithCentralDirectory;
            totalEntriesOfDisk = zip64eocdRecord.totalEntriesOfDisk;
            totalEntriesInCentralDirectory = zip64eocdRecord.totalEntriesInCentralDirectory;
            centralDirectorySize = zip64eocdRecord.centralDirectorySize;
            centralDirectoryOffset = zip64eocdRecord.centralDirectoryOffset;
          }
        }
      }
//      reader.seek(centralDirectoryOffset);
//      while (reader.offset() < centralDirectorySize) {
//
//      }
      print('$length - ${centralDirectoryOffset + centralDirectorySize}');
      print('$numberThisDisk -$numberOfDiskWithCentralDirectory - $totalEntriesOfDisk - $totalEntriesInCentralDirectory - $centralDirectorySize - $centralDirectoryOffset');

    } finally {
      reader?.close();
    }
  }

  final File _file;
  final Encoding _charset;

  int _checkLength(FileReader reader) {
    // Error out early if the file is too short or non-existent.
    int length = reader.length();
    if (length < EOCDRecord.eocdRecordLength) {
      throw ZipException('File too short to be a zip file: $length');
    }
    return length;
  }

  int _checkEOCDRecord(FileReader reader, int length) {
    // The directory and archive contents are written to the end of the zip
    // file.  We need to search from the end to find these structures,
    // starting with the 'End of central directory' record (EOCD).
    int eocdSearchLength =
        math.min(length, EOCDRecord.eocdRecordSearchLengthMax);
    int eocdRecordOffset;
    for (int i = EOCDRecord.eocdRecordLength; i <= eocdSearchLength; i++) {
      int offset = length - i;
      reader.seek(offset);
      if (reader.readUint32(Endian.little) == EOCDRecord.eocdRecordSignature) {
        eocdRecordOffset = offset;
        break;
      }
    }
    if (eocdRecordOffset == null) {
      throw ZipException('Could not find End of Central Directory Record');
    }
    return eocdRecordOffset;
  }

  EOCDRecord _parseEOCDRecord(FileReader reader, int eocdRecordOffset) {
    reader.seek(eocdRecordOffset);
    int signature = reader.readUint32(Endian.little);
    int numberOfDisk = reader.readUint16(Endian.little);
    int numberOfDiskWithCentralDirectory = reader.readUint16(Endian.little);
    int totalEntriesOfDisk = reader.readUint16(Endian.little);
    int totalEntriesInCentralDirectory = reader.readUint16(Endian.little);
    int centralDirectorySize = reader.readUint32(Endian.little);
    int centralDirectoryOffset = reader.readUint32(Endian.little);
    int commentLength = reader.readUint16(Endian.little);
    return EOCDRecord(
      signature: signature,
      numberOfDisk: numberOfDisk,
      numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
      totalEntriesOfDisk: totalEntriesOfDisk,
      totalEntriesInCentralDirectory: totalEntriesInCentralDirectory,
      centralDirectorySize: centralDirectorySize,
      centralDirectoryOffset: centralDirectoryOffset,
      commentLength: commentLength,
    );
  }

  Zip64EOCDLocator _parseZip64EOCDLocator(
      FileReader reader, int zip64EOCDLocatorOffset) {
    reader.seek(zip64EOCDLocatorOffset);
    int signature = reader.readUint32(Endian.little);
    if (signature != Zip64EOCDLocator.zip64EOCDLocatorSignature) {
      return null;
    }
    int numberOfDiskWithCentralDirectory = reader.readUint32(Endian.little);
    int relativeOffset = reader.readUint64(Endian.little);
    int totalDisks = reader.readUint32(Endian.little);
    return Zip64EOCDLocator(
      signature: signature,
      numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
      relativeOffset: relativeOffset,
      totalDisks: totalDisks,
    );
  }

  Zip64EOCDRecord _parseZip64EOCDRecord(
      FileReader reader, int zip64EOCDRecordOffset) {
    reader.seek(zip64EOCDRecordOffset);
    int signature = reader.readUint32(Endian.little);
    if (signature != Zip64EOCDRecord.zip64EOCDRecordSignature) {
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
    return Zip64EOCDRecord(
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
}
