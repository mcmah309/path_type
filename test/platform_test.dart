// ignore_for_file: pattern_never_matches_value_type, unused_local_variable

import 'package:path_type/posix.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("readLinkSync", () {
    if (Path.isIoSupported()) {
      expect(
        Path("test/fixtures/file_symlink").readLinkSync().unwrap(),
        endsWith("test/fixtures/file"),
      );
    } else {
      expect(
        () => Path("test/fixtures/file_symlink").readLinkSync(),
        throwsA(isA<UnsupportedError>()),
      );
    }
  });

  test("readLink", () async {
    if (Path.isIoSupported()) {
      expect(
        (await Path("test/fixtures/file_symlink").readLink()).unwrap(),
        endsWith("test/fixtures/file"),
      );
    } else {
      expect(
        () async => await Path("test/fixtures/file_symlink").readLink(),
        throwsA(isA<UnsupportedError>()),
      );
    }
  });

  test("metadata", () {
    if (Path.isIoSupported()) {
      final metadata = Path("test/fixtures/file").metadata();
      // Dev Note: uncommenting below will cause a compilation error when the target is web.
      // DateTime accessed = metadata.accessed;
      // DateTime changed = metadata.changed;
      // int mode = metadata.mode;
      // FileSystemEntityType type = metadata.type;
    } else {
      expect(
        () => Path("test/fixtures/file").metadata(),
        throwsA(isA<UnsupportedError>()),
      );
    }
  });
}
