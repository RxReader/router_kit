import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../io/file_reader.dart';

part 'zip_exception.dart';

part 'zip_header.dart';

part 'zip_parser.dart';

/// https://pkware.cachefly.net/webdocs/APPNOTE/APPNOTE-6.2.0.txt
class ZipFile {
  ZipFile._open(
    File file, [
    String password,
    Encoding charset = utf8,
  ]) {
    FileReader reader;
    try {
      reader = FileReader(file.openSync());
      final int length = _checkLength(reader);
      final int eocdOffset = _checkEOCDOffset(reader, length);
      _endOfCentralDirectoryRecord =
          _parseEndOfCentralDirectoryRecord(reader, eocdOffset);
      // If file is Zip64 format, Zip64 headers have to be read before reading central directory
      final int zip64eocdLocatorOffset =
          eocdOffset - Zip64EndOfCentralDirectoryLocator.locatorLength;
      if (zip64eocdLocatorOffset > 0) {
        _zip64endOfCentralDirectoryLocator =
            _parseZip64EndOfCentralDirectoryLocator(
                reader, zip64eocdLocatorOffset);
        if (_zip64endOfCentralDirectoryLocator != null) {
          _zip64endOfCentralDirectoryRecord =
              _parseZip64EndOfCentralDirectoryRecord(
                  reader,
                  _zip64endOfCentralDirectoryLocator
                      .offsetZip64EndOfCentralDirectoryRecord);
        }
      }
      int offsetOfStartOfCentralDirectory = isZip64Format
          ? _zip64endOfCentralDirectoryRecord
              .offsetStartCentralDirectoryWRTStartDiskNumber
          : _endOfCentralDirectoryRecord.offsetOfStartOfCentralDirectory;
      int numberOfEntriesInCentralDirectory = isZip64Format
          ? _zip64endOfCentralDirectoryRecord
              .totalNumberOfEntriesInCentralDirectory
          : _endOfCentralDirectoryRecord.totalNumberOfEntriesInCentralDirectory;
      _centralDirectory =
          _parseCentralDirectory(
              reader, charset, offsetOfStartOfCentralDirectory, numberOfEntriesInCentralDirectory);
//      _localFiles = centralDirectoryFileHeaders
//          .map((CentralDirectoryFileHeader fileHeader) =>
//              _parseLocalFile(file, password, charset, reader, fileHeader))
//          .toList();
    } finally {
      reader?.close();
    }
  }

  CentralDirectory _centralDirectory;
  Zip64EndOfCentralDirectoryRecord _zip64endOfCentralDirectoryRecord;
  Zip64EndOfCentralDirectoryLocator _zip64endOfCentralDirectoryLocator;
  EndOfCentralDirectoryRecord _endOfCentralDirectoryRecord;

  bool get isSplitArchive {
    if (isZip64Format) {
      return _zip64endOfCentralDirectoryRecord != null &&
          _zip64endOfCentralDirectoryRecord.numberOfThisDisk > 0;
    }
    return _endOfCentralDirectoryRecord.numberOfThisDisk > 0;
  }

  bool get isZip64Format => _zip64endOfCentralDirectoryLocator != null;

  Future<void> extractAll() async {}

  Future<void> extractFile() async {}

  static Future<ZipFile> open(
    File file, [
    String password,
    Encoding charset = utf8, // 默认 'cp437'，但是 Dart 暂不支持 'cp437'
  ]) async {
    return ZipFile._open(file, password, charset);
  }
}
