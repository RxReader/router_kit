import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
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
  ])  : _file = file,
        _password = password,
        _charset = charset {
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
      _centralDirectory = _parseCentralDirectory(reader, charset,
          offsetOfStartOfCentralDirectory, numberOfEntriesInCentralDirectory);
    } finally {
      reader?.close();
    }
  }

  final File _file;
  final String _password;
  final Encoding _charset;

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

  bool get isEncrypted {
    for (CentralDirectoryFileHeader fileHeader
        in _centralDirectory.fileHeaders) {
      if (fileHeader.isEncrypted) {
        return true;
      }
    }
    return false;
  }

  Future<void> extractAll(String destinationPath) async {
    for (CentralDirectoryFileHeader fileHeader
        in _centralDirectory.fileHeaders) {
      await extractFile(fileHeader, destinationPath);
    }
  }

  Future<void> extractFile(
      CentralDirectoryFileHeader fileHeader, String destinationPath) async {
    FileReader reader;
    try {
      File unzipFile = _file;
      if (isSplitArchive) {
        String extensionSubString = ".z0";
        if (fileHeader.diskNumberStart >= 9) {
          extensionSubString = ".z";
        }
        unzipFile = File('${_file.path.substring(0, _file.path.lastIndexOf('.'))}$extensionSubString${fileHeader.diskNumberStart + 1}');
      }
      reader = FileReader(unzipFile.openSync());
      LocalFile localFile = _parseLocalFile(reader, _charset, fileHeader);
      reader.seek(localFile.fileDataOffset);
      if (fileHeader.isDirectory) {
        Directory destDir = Directory(path.join(destinationPath, localFile.localFileHeader.fileName));
        if (!destDir.existsSync()) {
          destDir.createSync(recursive: true);
        }
      } else {
        File destFile = File(path.join(destinationPath, localFile.localFileHeader.fileName));
        destFile.createSync(recursive: true);
        Stream<List<int>> stream = _file.openRead(localFile.fileDataOffset, fileHeader.compressedSize);
        if (fileHeader.isEncrypted) {
          if (fileHeader.aesExtraDataRecord != null) {

          } else {

          }
        }
        if (fileHeader.compressionMethod == CompressionMethod.deflate) {
          stream.transform(ZLibCodec(raw: true).decoder);
        }
        IOSink sink = destFile.openWrite();
        await sink.addStream(stream);
        await sink.flush();
        await sink.close();
        DateTime lastModFileTime = _parseDosTime(fileHeader.lastModFileDate, fileHeader.lastModFileTime);
        destFile.setLastModifiedSync(lastModFileTime);
        destFile.setLastAccessedSync(lastModFileTime);
      }
    } finally {
      reader?.close();
    }
  }

  static Future<ZipFile> open(
    File file, [
    String password,
    Encoding charset = utf8, // 默认 'cp437'，但是 Dart 暂不支持 'cp437'
  ]) async {
    return ZipFile._open(file, password, charset);
  }
}
