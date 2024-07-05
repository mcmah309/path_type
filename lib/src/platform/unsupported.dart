import 'package:rust_core/result.dart';

import '../io_error.dart';

bool isIoSupported() => false;

class ReadDir {}

class Metadata {}

Future<Metadata> metadata(String path) =>
    throw UnsupportedError("'metadata' is not supported on on this platform.");
Metadata metadataSync(String path) => throw UnsupportedError(
    "'metadataSync' is not supported on on this platform.");

Future<bool> exists(String path) =>
    throw UnsupportedError("'exists' is not supported on on this platform.");
bool existsSync(String path) => throw UnsupportedError(
    "'existsSync' is not supported on on this platform.");

Future<bool> isDir(String path) =>
    throw UnsupportedError("'isDir' is not supported on on this platform.");
bool isDirSync(String path) =>
    throw UnsupportedError("'isDirSync' is not supported on on this platform.");

Future<bool> isFile(String path) =>
    throw UnsupportedError("'isFile' is not supported on on this platform.");
bool isFileSync(String path) => throw UnsupportedError(
    "'isFileSync' is not supported on on this platform.");

Future<bool> isSymlink(String path) =>
    throw UnsupportedError("'isSymlink' is not supported on on this platform.");
bool isSymlinkSync(String path) => throw UnsupportedError(
    "'isSymlinkSync' is not supported on on this platform.");

Future<Result<ReadDir, IoError>> readDir(String path) =>
    throw UnsupportedError("'readDir' is not supported on on this platform.");
Result<ReadDir, IoError> readDirSync(String path) => throw UnsupportedError(
    "'readDirSync' is not supported on on this platform.");

Future<Result<String, IoError>> readLink(String path) =>
    throw UnimplementedError(
        "'readLink' is not supported on on this platform.");
Result<String, IoError> readLinkSync(String path) => throw UnimplementedError(
    "'readLinkSync' is not supported on on this platform.");

Future<Result<Metadata, IoError>> symlinkMetadata(String path) =>
    throw UnimplementedError(
        "'symlinkMetadata' is not supported on on this platform.");
Result<Metadata, IoError> symlinkMetadataSync(String path) =>
    throw UnimplementedError(
        "'symlinkMetadataSync' is not supported on on this platform.");
