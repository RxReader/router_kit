import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'dart:typed_data';

import '../io/file_reader.dart';

/// https://pkware.cachefly.net/webdocs/APPNOTE/APPNOTE-6.2.0.txt
class ZipFile {
  ZipFile(
    File file, [
    Encoding charset = utf8,
  ])  : _reader = FileReader(file.openSync()),
        _charset = charset {
    int length = _checkLength();
    int eocdOffset = _checkEOCD(length);
    _parseEOCD(eocdOffset);
    _parseZip64(eocdOffset);
  }

//  static const int locSig = 0x04034b50;
//  static const int extSig = 0x08074b50;
//  static const int cenSig = 0x02014b50;

  static const int eocdSignature = 0x06054b50;
  static const int eocdLength = 22;
  static const int eocdCommentLengthMax = 65535; // longest possible in ushort
  static const int eocdSearchLengthMax = eocdLength + eocdCommentLengthMax;

  final FileReader _reader;
  final Encoding _charset;

  int _checkLength() {
    // Error out early if the file is too short or non-existent.
    int length = _reader.length();
    if (length < eocdLength) {
      throw ZipException('File too short to be a zip file: $length');
    }
    return length;
  }

  int _checkEOCD(int length) {
    // The directory and archive contents are written to the end of the zip
    // file.  We need to search from the end to find these structures,
    // starting with the 'End of central directory' record (EOCD).
    int eocdSearchLength = math.min(length, eocdSearchLengthMax);
    int eocdOffset;
    for (int i = eocdLength; i <= eocdSearchLength; i++) {
      int offset = length - i;
      _reader.seek(offset);
      if (_reader.readUint32(Endian.little) == eocdSignature) {
        eocdOffset = offset;
        break;
      }
    }
    if (eocdOffset == null) {
      throw ZipException('Could not find End of Central Directory Record');
    }
    return eocdOffset;
  }

  void _parseEOCD(int eocdOffset) {
    //   I.  End of central directory record:
    //
    //        end of central dir signature    4 bytes  (0x06054b50)
    //        number of this disk             2 bytes
    //        number of the disk with the
    //        start of the central directory  2 bytes
    //        total number of entries in the
    //        central directory on this disk  2 bytes
    //        total number of entries in
    //        the central directory           2 bytes
    //        size of the central directory   4 bytes
    //        offset of start of central
    //        directory with respect to
    //        the starting disk number        4 bytes
    //        .ZIP file comment length        2 bytes
    //        .ZIP file comment       (variable size)
    _reader.seek(eocdOffset);
    _reader.readUint32(Endian.little); // signature
    _reader.readUint16(Endian.little); // numberOfThisDisk
    _reader.readUint16(Endian.little); // diskWithTheStartOfTheCentralDirectory
    int totalCentralDirectoryEntriesOnThisDisk =
        _reader.readUint16(Endian.little);
    _reader.readUint16(Endian.little); // totalCentralDirectoryEntries
    int centralDirectorySize = _reader.readUint32(Endian.little);
    int centralDirectoryOffset = _reader.readUint32(Endian.little);
    int commentLength = _reader.readUint16(Endian.little);
    String comment;
    if (commentLength > 0) {
      comment = _reader.readString(commentLength, _charset);
    }
  }

  void _parseZip64(int eocdOffset) {
    //   H.  Zip64 end of central directory locator
    //
    //        zip64 end of central dir locator
    //        signature                       4 bytes  (0x07064b50)
    //        number of the disk with the
    //        start of the zip64 end of
    //        central directory               4 bytes
    //        relative offset of the zip64
    //        end of central directory record 8 bytes
    //        total number of disks           4 bytes
    _reader.seek(eocdOffset - 20);

    //   G.  Zip64 end of central directory record
    //
    //        zip64 end of central dir
    //        signature                       4 bytes  (0x06064b50)
    //        size of zip64 end of central
    //        directory record                8 bytes
    //        version made by                 2 bytes
    //        version needed to extract       2 bytes
    //        number of this disk             4 bytes
    //        number of the disk with the
    //        start of the central directory  4 bytes
    //        total number of entries in the
    //        central directory on this disk  8 bytes
    //        total number of entries in the
    //        central directory               8 bytes
    //        size of the central directory   8 bytes
    //        offset of start of central
    //        directory with respect to
    //        the starting disk number        8 bytes
    //        zip64 extensible data sector    (variable size)
    _reader.seek(0);
  }
}

class ZipException implements IOException {
  const ZipException(this.message);

  final String message;

  @override
  String toString() {
    return 'ZipException: $message';
  }
}
