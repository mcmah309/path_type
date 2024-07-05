import 'dart:io' as io;

import 'package:rust_core/result.dart';

import '../io_error.dart';

bool isIoSupported() => true;

/// An iterator over the entries within a directory.
typedef ReadDir = List<io.FileSystemEntity>;

typedef Metadata = io.FileStat;

Future<Metadata> metadata(String path) => io.FileStat.stat(path);
Metadata metadataSync(String path) => io.FileStat.statSync(path);

Future<bool> exists(String path) async =>
    await io.FileSystemEntity.type(path, followLinks: true) !=
    io.FileSystemEntityType.notFound;
bool existsSync(String path) =>
    io.FileSystemEntity.typeSync(path, followLinks: true) !=
    io.FileSystemEntityType.notFound;

Future<bool> isDir(String path) => io.FileSystemEntity.isDirectory(path);
bool isDirSync(String path) => io.FileSystemEntity.isDirectorySync(path);

Future<bool> isFile(String path) => io.FileSystemEntity.isFile(path);
bool isFileSync(String path) => io.FileSystemEntity.isFileSync(path);

Future<bool> isSymlink(String path) => io.FileSystemEntity.isLink(path);
bool isSymlinkSync(String path) => io.FileSystemEntity.isLinkSync(path);

Future<Result<ReadDir, IoError>> readDir(String path) async {
  if (!await isDir(path)) {
    return Err(IoErrorNotADirectory(path));
  }
  try {
    final dir = io.Directory(path);
    final listResult = await dir.list().toList();

    return Ok(listResult);
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Result<ReadDir, IoError> readDirSync(String path) {
  if (!isDirSync(path)) {
    return Err(IoErrorNotADirectory(path));
  }
  try {
    final dir = io.Directory(path);
    return Ok(dir.listSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Future<Result<String, IoError>> readLink(String path) async {
  if (!await isSymlink(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    final link = io.Link(path);
    final resolvedLinkResult = await link.resolveSymbolicLinks();

    return Ok(resolvedLinkResult);
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Result<String, IoError> readLinkSync(String path) {
  if (!isSymlinkSync(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    final link = io.Link(path);
    return Ok(link.resolveSymbolicLinksSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Result<Metadata, IoError> symlinkMetadataSync(String path) {
  if (!isSymlinkSync(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    return Ok(io.Link(path).statSync());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}

Future<Result<Metadata, IoError>> symlinkMetadata(String path) async {
  if (!await isSymlink(path)) {
    return Err(IoErrorNotALink(path));
  }
  try {
    return Ok(await io.Link(path).stat());
  } catch (e) {
    return Err(IoErrorUnknown(path, e));
  }
}
