library path;

export 'src/posix_path.dart'
    if (Platform.isWindows) 'src/windows_path.dart';
export 'src/io_error.dart';
