import 'dart:io' as io;
import 'package:rust_core/result.dart';

import '../io_error.dart';

bool isIoSupported() => true;

/// An iterator over the entries within a directory.
typedef ReadDir = List<io.FileSystemEntity>;

typedef Metadata = io.FileStat;

Metadata metadata(String path) => io.FileStat.statSync(path);

bool exists(String path) =>
    io.FileSystemEntity.typeSync(path, followLinks: true) != io.FileSystemEntityType.notFound;

bool isDir(String path) => io.FileSystemEntity.isDirectorySync(path);

bool isFile(String path) => io.FileSystemEntity.isFileSync(path);

bool isSymlink(String path) => io.FileSystemEntity.isLinkSync(path);

Result<ReadDir, IoError> readDir(String path) {
  if (!isDir(path)) {
    return Err(IoErrorNotADirectory(path));
  }
  try {
    final dir = io.Directory(path);
    return Ok(dir.listSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Result<String, IoError> readLink(String path) {
  if (!isSymlink(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    final link = io.Link(path);
    return Ok(link.resolveSymbolicLinksSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Result<Metadata, IoError> symlinkMetadata(String path) {
  if (!isSymlink(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    return Ok(io.Link(path).statSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}
