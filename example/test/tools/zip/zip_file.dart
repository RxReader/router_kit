import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../io/file_reader.dart';

part 'zip_exception.dart';

part 'zip_header.dart';

part 'zip_parser.dart';

/// 不支持分卷压缩
/// https://pkware.cachefly.net/webdocs/APPNOTE/APPNOTE-6.2.0.txt
class ZipFile {
  ZipFile(
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
      int centralDirectorySize =
          _endOfCentralDirectoryRecord.centralDirectorySize;
      int centralDirectoryOffset =
          _endOfCentralDirectoryRecord.centralDirectoryOffset;
      final int zip64EOCDLocatorOffset =
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
            centralDirectorySize = zip64EOCDRecord.centralDirectorySize;
            centralDirectoryOffset = zip64EOCDRecord.centralDirectoryOffset;
          }
        }
      }
      List<CentralDirectoryFileHeader> centralDirectoryFileHeaders =
          _parseCentralDirectory(
              reader, charset, centralDirectoryOffset, centralDirectorySize);
      _localFiles = centralDirectoryFileHeaders.map(_parseLocalFile);
    } finally {
      reader?.close();
    }
  }

  List<LocalFile> _localFiles;
  List<CentralDirectoryFileHeader> _centralDirectoryFileHeaders;
  EndOfCentralDirectoryRecord _endOfCentralDirectoryRecord;

  List<LocalFile> get localFiles => _localFiles;

  List<CentralDirectoryFileHeader> get centralDirectoryFileHeaders =>
      _centralDirectoryFileHeaders;

  EndOfCentralDirectoryRecord get endOfCentralDirectoryRecord =>
      _endOfCentralDirectoryRecord;
}
