/// Path following windows specification on windows, follows posix otherwise
library platform;

export 'src/posix_path.dart'
    if (Platform.isWindows) 'src/windows_path.dart';
export 'src/io_error.dart';
