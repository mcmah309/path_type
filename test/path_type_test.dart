// ignore_for_file: pattern_never_matches_value_type, unused_local_variable

import 'package:path_type/path_type.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("Can import", () {
    Path("");
    UnixPath("");
    WindowsPath("");
  });
}
