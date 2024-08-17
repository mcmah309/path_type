# Path Type
[![Pub Version](https://img.shields.io/pub/v/path_type.svg)](https://pub.dev/packages/path_type)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/path_type/latest/)
[![License: Apache 2.0](https://img.shields.io/github/license/mcmah309/path_type)](https://opensource.org/license/apache-2-0)
[![Build Status](https://github.com/mcmah309/path_type/actions/workflows/ci.yml/badge.svg)](https://github.com/mcmah309/path_type/actions)

Path Type introduces a robust Path type, `Path`, supporting POSIX and Windows file systems. Instead of using `String`, use `Path` to handle file paths in a type-safe manner. `Path` can be used easily in place or with the [path](https://pub.dev/packages/path) package. `Path` is also zero runtime cost as it is implemented as an extension type of `String`.

## Usage
import
```dart
import 'package:path_type/posix.dart'; // or
import 'package:path_type/windows.dart'; // or
import 'package:path_type/platform.dart'; // or, uses posix unless on windows
```

Create a path and perform basic operations:

```dart
import 'package:path_type/posix.dart';

void main() {
  var path = Path('/foo/bar/baz.txt');

  print('File name: ${path.fileName()}'); // Output: baz.txt
  print('Extension: ${path.extension()}'); // Output: txt
  print('Is absolute: ${path.isAbsolute()}'); // Output: true

  var parent = path.parent();
  if (parent.isSome()) {
    print('Parent: ${parent.unwrap()}'); // Output: /foo/bar
  }

  var newPath = path.withExtension('md');
  print('New path with extension: $newPath'); // Output: /foo/bar/baz.md
}
```

Get the components of a path:
```dart
void main() {
  var path = Path('/foo/bar/baz.txt');
  var components = path.components().toList();

  for (var component in components) {
    print(component); // Output: /, foo, bar, baz.txt
  }
}
```

Retrieve all ancestors of a path:
```dart
void main() {
  var path = Path('/foo/bar/baz.txt');

  for (var ancestor in path.ancestors()) {
    print(ancestor);
    // Output:
    // /foo/bar/baz.txt
    // /foo/bar
    // /foo
    // /
  }
}
```
Check if a path exists and get metadata:

```dart
void main() {
  var path = Path('/foo/bar/baz.txt');

  if (path.existsSync()) {
    var metadata = path.metadataSync();
    print('File size: ${metadata.size}');
    print('Last modified: ${metadata.modified}');
  } else {
    print('Path does not exist.');
  }
}
```

For more operations see the [documentation](https://pub.dev/documentation/path_type/latest/posix/Path-extension-type.html)