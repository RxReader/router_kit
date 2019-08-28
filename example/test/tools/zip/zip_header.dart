// VI. General Format of a .ZIP file
//---------------------------------
//
//  Files stored in arbitrary order.  Large .ZIP files can span multiple
//  diskette media or be split into user-defined segment sizes.
//
//  Overall .ZIP file format:
//
//    [local file header 1]
//    [file data 1]
//    [data descriptor 1]
//    .
//    .
//    .
//    [local file header n]
//    [file data n]
//    [data descriptor n]
//    [archive decryption header] (EFS)
//    [archive extra data record] (EFS)
//    [central directory]
//    [zip64 end of central directory record]
//    [zip64 end of central directory locator]
//    [end of central directory record]
//
//
//  A.  Local file header:
//
//        local file header signature     4 bytes  (0x04034b50)
//        version needed to extract       2 bytes
//        general purpose bit flag        2 bytes
//        compression method              2 bytes
//        last mod file time              2 bytes
//        last mod file date              2 bytes
//        crc-32                          4 bytes
//        compressed size                 4 bytes
//        uncompressed size               4 bytes
//        file name length                2 bytes
//        extra field length              2 bytes
//
//        file name (variable size)
//        extra field (variable size)
//
//  B.  File data
//
//      Immediately following the local header for a file
//      is the compressed or stored data for the file.
//      The series of [local file header][file data][data
//      descriptor] repeats for each file in the .ZIP archive.
//
//  C.  Data descriptor:
//
//        crc-32                          4 bytes
//        compressed size                 4 bytes
//        uncompressed size               4 bytes
//
//      This descriptor exists only if bit 3 of the general
//      purpose bit flag is set (see below).  It is byte aligned
//      and immediately follows the last byte of compressed data.
//      This descriptor is used only when it was not possible to
//      seek in the output .ZIP file, e.g., when the output .ZIP file
//      was standard output or a non seekable device.  For Zip64 format
//      archives, the compressed and uncompressed sizes are 8 bytes each.
//
//  D.  Archive decryption header:  (EFS)
//
//      The Archive Decryption Header is introduced in version 6.2
//      of the ZIP format specification.  This record exists in support
//      of the Central Directory Encryption Feature implemented as part of
//      the Strong Encryption Specification as described in this document.
//      When the Central Directory Structure is encrypted, this decryption
//      header will precede the encrypted data segment.  The encrypted
//      data segment will consist of the Archive extra data record (if
//      present) and the encrypted Central Directory Structure data.
//      The format of this data record is identical to the Decryption
//      header record preceding compressed file data.  If the central
//      directory structure is encrypted, the location of the start of
//      this data record is determined using the Start of Central Directory
//      field in the Zip64 End of Central Directory record.  Refer to the
//      section on the Strong Encryption Specification for information
//      on the fields used in the Archive Decryption Header record.
//
//
//  E.  Archive extra data record: (EFS)
//
//        archive extra data signature    4 bytes  (0x08064b50)
//        extra field length              4 bytes
//        extra field data                (variable size)
//
//      The Archive Extra Data Record is introduced in version 6.2
//      of the ZIP format specification.  This record exists in support
//      of the Central Directory Encryption Feature implemented as part of
//      the Strong Encryption Specification as described in this document.
//      When present, this record immediately precedes the central
//      directory data structure.  The size of this data record will be
//      included in the Size of the Central Directory field in the
//      End of Central Directory record.  If the central directory structure
//      is compressed, but not encrypted, the location of the start of
//      this data record is determined using the Start of Central Directory
//      field in the Zip64 End of Central Directory record.
//
//
//  F.  Central directory structure:
//
//      [file header 1]
//      .
//      .
//      .
//      [file header n]
//      [digital signature]
//
//      File header:
//
//        central file header signature   4 bytes  (0x02014b50)
//        version made by                 2 bytes
//        version needed to extract       2 bytes
//        general purpose bit flag        2 bytes
//        compression method              2 bytes
//        last mod file time              2 bytes
//        last mod file date              2 bytes
//        crc-32                          4 bytes
//        compressed size                 4 bytes
//        uncompressed size               4 bytes
//        file name length                2 bytes
//        extra field length              2 bytes
//        file comment length             2 bytes
//        disk number start               2 bytes
//        internal file attributes        2 bytes
//        external file attributes        4 bytes
//        relative offset of local header 4 bytes
//
//        file name (variable size)
//        extra field (variable size)
//        file comment (variable size)
//
//      Digital signature:
//
//        header signature                4 bytes  (0x05054b50)
//        size of data                    2 bytes
//        signature data (variable size)
//
//      With the introduction of the Central Directory Encryption
//      feature in version 6.2 of this specification, the Central
//      Directory Structure may be stored both compressed and encrypted.
//      Although not required, it is assumed when encrypting the
//      Central Directory Structure, that it will be compressed
//      for greater storage efficiency.  Information on the
//      Central Directory Encryption feature can be found in the section
//      describing the Strong Encryption Specification. The Digital
//      Signature record will be neither compressed nor encrypted.
//
//  G.  Zip64 end of central directory record
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
//
//        The above record structure defines Version 1 of the
//        Zip64 end of central directory record. Version 1 was
//        implemented in versions of this specification preceding
//        6.2 in support of the ZIP64(tm) large file feature. The
//        introduction of the Central Directory Encryption feature
//        implemented in version 6.2 as part of the Strong Encryption
//        Specification defines Version 2 of this record structure.
//        Refer to the section describing the Strong Encryption
//        Specification for details on the version 2 format for
//        this record.
//
//
//  H.  Zip64 end of central directory locator
//
//        zip64 end of central dir locator
//        signature                       4 bytes  (0x07064b50)
//        number of the disk with the
//        start of the zip64 end of
//        central directory               4 bytes
//        relative offset of the zip64
//        end of central directory record 8 bytes
//        total number of disks           4 bytes
//
//  I.  End of central directory record:
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

part of 'zip_file.dart';

abstract class ZipField {
  ZipField({
    @required this.signature,
  });

  final int signature;
}


class CentralFileHeader extends ZipField {

}

class DigitalSignature extends ZipField {

}

class Zip64EOCDRecord extends ZipField {
  Zip64EOCDRecord({
    @required int signature,
    @required this.sizeOfEndOfCentralDirectoryRecord,
    @required this.versionMadeBy,
    @required this.versionNeededToExtract,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.centralDirectoryOffset,
  });

  static const int zip64EOCDRecordSignature = 0x06064b50;

  final int sizeOfEndOfCentralDirectoryRecord;
  final int versionMadeBy;
  final int versionNeededToExtract;
  final int numberOfDisk;
  final int numberOfDiskWithCentralDirectory;
  final int totalEntriesOfDisk;
  final int totalEntriesInCentralDirectory;
  final int centralDirectorySize;
  final int centralDirectoryOffset;

  @override
  String toString() {
    return 'Zip64EOCDRecord{signature: $signature, sizeOfEndOfCentralDirectoryRecord: $sizeOfEndOfCentralDirectoryRecord, versionMadeBy: $versionMadeBy, versionNeededToExtract: $versionNeededToExtract, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, centralDirectoryOffset: $centralDirectoryOffset}';
  }
}

class Zip64EOCDLocator extends ZipField {
  Zip64EOCDLocator({
    @required int signature,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.relativeOffset,
    @required this.totalDisks,
  }) : super(signature: signature);

  static const int zip64EOCDLocatorSignature = 0x07064b50;
  static const int zip64EOCDLocatorLength = 20;

  final int numberOfDiskWithCentralDirectory;
  final int relativeOffset;
  final int totalDisks;

  @override
  String toString() {
    return 'Zip64EOCDLocator{signature: $signature, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, relativeOffset: $relativeOffset, totalDisks: $totalDisks}';
  }
}

class EOCDRecord extends ZipField {
  EOCDRecord({
    @required int signature,
    @required this.numberOfDisk,
    @required this.numberOfDiskWithCentralDirectory,
    @required this.totalEntriesOfDisk,
    @required this.totalEntriesInCentralDirectory,
    @required this.centralDirectorySize,
    @required this.centralDirectoryOffset,
    @required this.commentLength,
  }) : super(signature: signature);

  static const int eocdRecordSignature = 0x06054b50;
  static const int eocdRecordLength = 22;
  static const int eocdRecordCommentLengthMax =
      65535; // longest possible in ushort
  static const int eocdRecordSearchLengthMax =
      eocdRecordLength + eocdRecordCommentLengthMax;

  final int numberOfDisk;
  final int numberOfDiskWithCentralDirectory;
  final int totalEntriesOfDisk;
  final int totalEntriesInCentralDirectory;
  final int centralDirectorySize;
  final int centralDirectoryOffset;
  final int commentLength;

  @override
  String toString() {
    return 'EOCDRecord{signature: $signature, numberOfDisk: $numberOfDisk, numberOfDiskWithCentralDirectory: $numberOfDiskWithCentralDirectory, totalEntriesOfDisk: $totalEntriesOfDisk, totalEntriesInCentralDirectory: $totalEntriesInCentralDirectory, centralDirectorySize: $centralDirectorySize, startOffset: $centralDirectoryOffset, commentLength: $commentLength}';
  }
}
