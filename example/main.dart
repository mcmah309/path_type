import 'package:path_type/posix.dart';
import 'package:rust_core/option.dart';

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

  path = Path('/foo/bar/baz.txt');

  if (path.existsSync()) {
    var metadata = path.metadataSync();
    print('File size: ${metadata.size}');
    print('Last modified: ${metadata.modified}');
  } else {
    print('Path does not exist.');
  }

  path = Path('/foo/bar/baz.txt');

  for (var ancestor in path.ancestors()) {
    print(ancestor);
    // Output:
    // /foo/bar/baz.txt
    // /foo/bar
    // /foo
    // /
  }

  path = Path('/foo/bar/baz.txt');
  var components = path.components().toList();

  for (var component in components) {
    print(component); // Output: /, foo, bar, baz.txt
  }

  Path path1 = Path('/foo/bar');
  Path path2 = 'bar'.asPath();
  Path path3 = './baz.txt' as Path;

  path = path1.join(path2).join(path3);
  print(path); // Output: /foo/bar/bar/./baz.txt
}
