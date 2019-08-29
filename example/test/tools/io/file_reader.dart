import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

class FileReader {
  FileReader(RandomAccessFile raf) : _raf = raf;

  final RandomAccessFile _raf;

  int offset() => _raf.positionSync();

  bool isEOF() => _raf.positionSync() >= _raf.lengthSync();

  void seek(int offset) => _raf.setPositionSync(offset);

  void skip(int n) => _raf.setPositionSync(_raf.positionSync() + n);

  List<int> read(int bytes) {
    return _raf.readSync(bytes);
  }

  int readUint8() {
    List<int> bytes = _raf.readSync(1);
    return ByteData.view(Uint8List.fromList(bytes).buffer).getUint8(0);
  }

  int readUint16([Endian endian = Endian.big]) {
    List<int> bytes = _raf.readSync(2);
    return ByteData.view(Uint8List.fromList(bytes).buffer).getUint16(0, endian);
  }

  int readUint32([Endian endian = Endian.big]) {
    List<int> bytes = _raf.readSync(4);
    return ByteData.view(Uint8List.fromList(bytes).buffer).getUint32(0, endian);
  }

  int readUint64([Endian endian = Endian.big]) {
    List<int> bytes = _raf.readSync(8);
    return ByteData.view(Uint8List.fromList(bytes).buffer).getUint64(0, endian);
  }

  String readString(int length, [Encoding charset = utf8]) {
    List<int> bytes = _raf.readSync(length);
    return charset.decode(bytes);
  }

  int length() => _raf.lengthSync();

  void close() => _raf.closeSync();
}
