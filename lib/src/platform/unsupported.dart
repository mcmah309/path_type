import 'package:rust_core/result.dart';

import '../io_error.dart';

bool isIoSupported() => false;

class ReadDir {}

class Metadata {}

Metadata metadata(String path) =>
    throw UnsupportedError("'metadata' is not supported on on this platform.");

bool exists(String path) =>
    throw UnsupportedError("'exists' is not supported on on this platform.");

bool isDir(String path) => throw UnsupportedError("'isDir' is not supported on on this platform.");

bool isFile(String path) =>
    throw UnsupportedError("'isFile' is not supported on on this platform.");

bool isSymlink(String path) =>
    throw UnsupportedError("'isSymlink' is not supported on on this platform.");

Result<ReadDir, IoError> readDir(String path) =>
    throw UnsupportedError("'readDir' is not supported on on this platform.");

Result<String, IoError> readLink(String path) =>
    throw UnimplementedError("'readLink' is not supported on on this platform.");

Result<Metadata, IoError> symlinkMetadata(String path) =>
    throw UnimplementedError("'symlinkMetadata' is not supported on on this platform.");
