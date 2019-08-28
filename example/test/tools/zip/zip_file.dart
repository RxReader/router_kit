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
  ])  : _reader = FileReader(file.openSync()),
        _charset = charset {
    int length = _checkLength();
    int eocdRecordOffset = _checkEOCDRecord(length);
    EOCDRecord eocdRecord = _parseEOCDRecord(eocdRecordOffset);
//    print(eocdRecord);
    int zip64EOCDLocatorOffset = eocdRecordOffset - Zip64EOCDLocator.zip64EOCDLocatorLength;
    if (zip64EOCDLocatorOffset > 0) {
      Zip64EOCDLocator zip64eocdLocator = _parseZip64EOCDLocator(
          zip64EOCDLocatorOffset);
      if (zip64eocdLocator != null) {
//        print(zip64eocdLocator);

      }
    }
  }

  final FileReader _reader;
  final Encoding _charset;

  int _checkLength() {
    // Error out early if the file is too short or non-existent.
    int length = _reader.length();
    if (length < EOCDRecord.eocdRecordLength) {
      throw ZipException('File too short to be a zip file: $length');
    }
    return length;
  }

  int _checkEOCDRecord(int length) {
    // The directory and archive contents are written to the end of the zip
    // file.  We need to search from the end to find these structures,
    // starting with the 'End of central directory' record (EOCD).
    int eocdSearchLength =
        math.min(length, EOCDRecord.eocdRecordSearchLengthMax);
    int eocdRecordOffset;
    for (int i = EOCDRecord.eocdRecordLength; i <= eocdSearchLength; i++) {
      int offset = length - i;
      _reader.seek(offset);
      if (_reader.readUint32(Endian.little) == EOCDRecord.eocdRecordSignature) {
        eocdRecordOffset = offset;
        break;
      }
    }
    if (eocdRecordOffset == null) {
      throw ZipException('Could not find End of Central Directory Record');
    }
    return eocdRecordOffset;
  }

  EOCDRecord _parseEOCDRecord(int eocdRecordOffset) {
    _reader.seek(eocdRecordOffset);
    int signature = _reader.readUint32(Endian.little);
    int numberOfDisk = _reader.readUint16(Endian.little);
    int numberOfDiskWithCentralDirectory = _reader.readUint16(Endian.little);
    int totalEntriesOfDisk = _reader.readUint16(Endian.little);
    int totalEntriesInCentralDirectory = _reader.readUint16(Endian.little);
    int centralDirectorySize = _reader.readUint32(Endian.little);
    int startOffset = _reader.readUint32(Endian.little);
    int commentLength = _reader.readUint16(Endian.little);
    return EOCDRecord(
      signature: signature,
      numberOfDisk: numberOfDisk,
      numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
      totalEntriesOfDisk: totalEntriesOfDisk,
      totalEntriesInCentralDirectory: totalEntriesInCentralDirectory,
      centralDirectorySize: centralDirectorySize,
      startOffset: startOffset,
      commentLength: commentLength,
    );
  }

  Zip64EOCDLocator _parseZip64EOCDLocator(int zip64EOCDLocatorOffset) {
    _reader.seek(zip64EOCDLocatorOffset);
    int signature = _reader.readUint32(Endian.little);
    if (signature != Zip64EOCDLocator.zip64EOCDLocatorSignature) {
      return null;
    }
    int numberOfDiskWithCentralDirectory = _reader.readUint32(Endian.little);
    int relativeOffset = _reader.readUint64(Endian.little);
    int totalDisks = _reader.readUint32(Endian.little);
    return Zip64EOCDLocator(
      signature: signature,
      numberOfDiskWithCentralDirectory: numberOfDiskWithCentralDirectory,
      relativeOffset: relativeOffset,
      totalDisks: totalDisks,
    );
  }
}
