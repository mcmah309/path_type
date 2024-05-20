import 'package:path/path.dart' as p;
import 'package:rust_core/option.dart';
import 'package:rust_core/iter.dart';
import 'package:rust_core/result.dart';
import 'package:universal_io/io.dart' as io;

import 'io_error.dart';
import 'utils.dart';

/// An iterator over the entries within a directory.
typedef ReadDir = List<io.FileSystemEntity>;
typedef Metadata = io.FileStat;
const _pathSeparator = "\\";

/// This type supports a number of operations for inspecting a path, including breaking the path into its components,
/// extracting the file name, determining whether the path is absolute, and so on.
extension type Path._(String path) implements Object {
  static final RegExp regularPathComponent = RegExp(r'^[ .\w-]+$');
  static final RegExp oneOrmoreSlashes = RegExp(r'\\+');
  static final p.Context windows = p.Context(style: p.Style.windows);

  Path(this.path) : assert(_validate(path), "Path must be windows style");

  Iterable<Path> ancestors() sync* {
    yield this;
    Path? current = parent().toNullable();
    while (current != null) {
      yield current;
      current = current.parent().toNullable();
    }
  }

// as_mut_os_str : will not be implemented
// as_os_str : will not be implemented

  Path canonicalize() => Path(windows.canonicalize(path));

  Iterable<Component> components() sync* {
    bool removeLast;
    // trailing slash does not matter
    if (path.endsWith(_pathSeparator)) {
      if (path.length == 1) {
        yield RootDir();
        return;
      }
      removeLast = true;
    } else {
      removeLast = false;
    }
    final splits = path.split(oneOrmoreSlashes);
    if (removeLast) {
      splits.removeLast();
    }

    final iterator = splits.iterator;
    iterator.moveNext();
    var current = iterator.current;
    switch (current) {
      case "":
        yield RootDir();
        break;
      case ".":
        yield CurDir();
        break;
      case "..":
        yield ParentDir();
        break;
      default:
        if (regularPathComponent.hasMatch(current)) {
          yield Normal(current);
        } else {
          yield Prefix(current);
        }
    }
    while (iterator.moveNext()) {
      current = iterator.current;
      switch (current) {
        case ".":
          yield CurDir();
          break;
        case "..":
          yield ParentDir();
          break;
        default:
          yield Normal(current);
      }
    }
  }

  /// String representation of the path
  String display() => toString();

  /// Determines whether other is a suffix of this.
  bool endsWith(Path other) => path.endsWith(other.path);

  /// Determines whether other is a suffix of this.
  bool exists() =>
      io.FileSystemEntity.typeSync(path, followLinks: true) !=
      io.FileSystemEntityType.notFound;

  /// Extracts the extension (without the leading dot) of self.file_name, if possible.
  String extension() => windows.extension(path);

  /// Returns the final component of the Path, if there is one.
  String fileName() => windows.basename(path);

  /// Extracts the portion of the file name before the first "." -
  ///
  /// None, if there is no file name;
  /// The entire file name if there is no embedded .;
  /// The portion of the file name before the first non-beginning .;
  /// The entire file name if the file name begins with . and has no other .s within;
  /// The portion of the file name before the second . if the file name begins with .
  Option<String> filePrefix() {
    final value = windows.basename(path);
    if (value.isEmpty) {
      return None;
    }
    if (!value.contains(".")) {
      return Some(value);
    }
    if (value.startsWith(".")) {
      final splits = value.split(".");
      if (splits.length == 2) {
        return Some(value);
      } else {
        assert(splits.length > 2);
        return Some(splits[1]);
      }
    }
    return Some(value.split(".").first);
  }

  /// Extracts the portion of the file name before the last "." -
  ///
  /// None, if there is no file name;
  /// The entire file name if there is no embedded .;
  /// The entire file name if the file name begins with . and has no other .s within;
  /// Otherwise, the portion of the file name before the final .
  Option<String> fileStem() {
    final fileStem = windows.basenameWithoutExtension(path);
    if (fileStem.isEmpty) {
      return None;
    }
    return Some(fileStem);
  }

  /// Returns true if the Path has a root.
  bool hasRoot() => windows.rootPrefix(path) == _pathSeparator;

  // into_path_buf : will not be implemented

  /// Returns true if the Path is absolute, i.e., if it is independent of the current directory.
  bool isAbsolute() => windows.isAbsolute(path);

  /// Returns true if the path exists on disk and is pointing at a directory. Does not follow links.
  bool isDir() => io.FileSystemEntity.isDirectorySync(path);

  /// Returns true if the path exists on disk and is pointing at a regular file. Does not follow links.
  bool isFile() => io.FileSystemEntity.isFileSync(path);

  /// Returns true if the Path is relative, i.e., not absolute.
  bool isRelative() => windows.isRelative(path);

  /// Returns true if the path exists on disk and is pointing at a symlink. Does not follow links.
  bool isSymlink() => io.FileSystemEntity.isLinkSync(path);

  /// Produces an iterator over the path’s components viewed as Strings
  RIterator<String> iter() =>
      RIterator.fromIterable(components().map((e) => e.toString()));

  /// Creates an Path with path adjoined to this.
  Path join(Path other) => Path(windows.join(path, other.path));

  /// Queries the file system to get information about a file, directory, etc.
  Metadata metadata() => io.FileStat.statSync(path);

// new : will not be implemented

  /// Returns the Path without its final component, if there is one.
  /// This means it returns Some("") for relative paths with one component.
  /// Returns None if the path terminates in a root or prefix, or if it’s the empty string.
  Option<Path> parent() {
    final comps = components().toList();
    if (comps.length == 1) {
      switch (comps.first) {
        case RootDir():
        case Prefix():
          return None;
        case ParentDir():
        case CurDir():
        case Normal():
          return Some(Path(""));
      }
    }
    if (comps.length > 1) {
      comps.removeLast();
    } else {
      return None;
    }
    return Some(_joinComponents(comps));
  }

  /// Returns an iterator over the entries within a directory.
  Result<ReadDir, IoError> readDir() {
    if (!isDir()) {
      return Err(IoErrorNotADirectory(path));
    }
    try {
      final dir = io.Directory(path);
      return Ok(dir.listSync());
    } catch (e) {
      return Err(IoErrorUnknown(path, e));
    }
  }

  /// Reads a symbolic link, returning the file that the link points to.
  Result<Path, IoError> readLink() {
    if (!isSymlink()) {
      return Err(IoErrorNotALink(path));
    }
    try {
      final link = io.Link(path);
      return Ok(Path(link.resolveSymbolicLinksSync()));
    } catch (e) {
      return Err(IoErrorUnknown(path, e));
    }
  }

  /// Determines whether other is a prefix of this.
  bool startsWith(Path other) => path.startsWith(other.path);

  /// Returns a path that, when joined onto base, yields this. Returns None if [prefix] is not a subpath of base.
  Option<Path> stripPrefix(Path prefix) {
    if (!startsWith(prefix)) {
      return None;
    }
    final newPath = path.substring(prefix.path.length);
    return Some(Path(newPath));
  }

  Result<Metadata, IoError> symlinkMetadata() {
    if (!isSymlink()) {
      return Err(IoErrorNotALink(path));
    }
    try {
      return Ok(io.Link(path).statSync());
    } catch (e) {
      return Err(IoErrorUnknown(path, e));
    }
  }

// to_path_buf: Will not implement, implementing a PathBuf does not make sense at the present (equality cannot hold for extension types and a potential PathBuf would likely be `StringBuffer` or `List<String>`).
// to_str: Implemented by type
// to_string_lossy: Will not be implemented
// try_exists: Will not implement

  /// Creates an PathBuf like this but with the given extension.
  Path withExtension(String extension) {
    final stem = fileStem().unwrapOr("");
    final parentOption = parent();
    if (parentOption.isNone()) {
      if (stem.isEmpty) {
        return Path(extension);
      } else {
        if (extension.isEmpty) {
          return Path(stem);
        }
        return Path("$stem.$extension");
      }
    }
    if (stem.isEmpty) {
      return parentOption.unwrap().join(Path(extension));
    }
    if (extension.isEmpty) {
      return parentOption.unwrap().join(Path(stem));
    }
    return parentOption.unwrap().join(Path("$stem.$extension"));
  }

  /// Creates an PathBuf like this but with the given file name.
  Path withFileName(String fileName) {
    final parentOption = parent();
    return switch (parentOption) {
      None => Path(fileName),
      // ignore: pattern_never_matches_value_type
      Some(:final v) => v.join(Path(fileName)),
    };
  }
}

Path _joinComponents(Iterable<Component> components) {
  final buffer = StringBuffer();
  final iterator = components.iterator;
  forEachExceptFirstAndLast(iterator, doFirst: (e) {
    if (e is RootDir) {
      buffer.write(_pathSeparator);
    } else {
      buffer.write(e);
      buffer.write(_pathSeparator);
    }
  }, doRest: (e) {
    buffer.write(e);
    buffer.write(_pathSeparator);
  }, doLast: (e) {
    buffer.write(e);
  }, doIfOnlyOne: (e) {
    buffer.write(e);
  }, doIfEmpty: () {
    return buffer.write("");
  });
  return Path(buffer.toString());
}

//************************************************************************//

// This is likely not complete, but a minimal validation
bool _validate(String path) {
  // "/" is also reserved on windows
  final hasInvalidPathSep = path.contains("/");
  if (hasInvalidPathSep) {
    return false;
  }
  final hasADoubleDotWithoutSlashes = RegExp(r'[^\\]\.\.[^\\]');
  if (hasADoubleDotWithoutSlashes.hasMatch(path)) {
    return false;
  }
  final anInvalidComponentHasBeenIdentified = !path
      .split(_pathSeparator)
      .skip(1)
      .where((e) => e.isNotEmpty)
      .every((e) => Path.regularPathComponent.hasMatch(e));
  if (anInvalidComponentHasBeenIdentified) {
    return false;
  }
  return true;
}

sealed class Component {
  const Component();
}

class Prefix extends Component {
  final String value;
  const Prefix(this.value);

  @override
  bool operator ==(Object other) =>
      other == value || (other is Prefix && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class RootDir extends Component {
  const RootDir();

  @override
  bool operator ==(Object other) => other == _pathSeparator || other is RootDir;

  @override
  int get hashCode => _pathSeparator.hashCode;

  @override
  String toString() => _pathSeparator;
}

class CurDir extends Component {
  const CurDir();

  @override
  bool operator ==(Object other) => other == "." || other is CurDir;

  @override
  int get hashCode => ".".hashCode;

  @override
  String toString() => ".";
}

class ParentDir extends Component {
  const ParentDir();

  @override
  bool operator ==(Object other) => other == ".." || other is ParentDir;

  @override
  int get hashCode => "..".hashCode;

  @override
  String toString() => "..";
}

class Normal extends Component {
  final String value;
  Normal(this.value);

  @override
  bool operator ==(Object other) =>
      other == value || (other is Normal && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
