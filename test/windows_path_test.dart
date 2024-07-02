import 'package:rust_core/option.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:path_type/windows.dart';

void main() {
  test("filePrefix", () {
    expect(Path("foo.rs").filePrefix().unwrap(), "foo");
    expect(Path("foo\\").filePrefix().unwrap(), "foo");
    expect(Path(".foo").filePrefix().unwrap(), ".foo");
    expect(Path(".foo.rs").filePrefix().unwrap(), "foo");
    expect(Path("foo").filePrefix().unwrap(), "foo");
    expect(Path("foo.tar.gz").filePrefix().unwrap(), "foo");
    expect(Path("temp\\foo.tar.gz").filePrefix().unwrap(), "foo");
    expect(Path("C:\\foo\\.tmp.bar.tar").filePrefix().unwrap(), "tmp");
    expect(Path("").filePrefix().isNone(), true);

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .filePrefix()
            .unwrap(),
        "The Annual Report on the Health of the Parish of St");
  });

  test("fileStem", () {
    expect(Path("foo.rs").fileStem().unwrap(), "foo");
    expect(Path("foo\\").fileStem().unwrap(), "foo");
    expect(Path(".foo").fileStem().unwrap(), ".foo");
    expect(Path(".foo.rs").fileStem().unwrap(), ".foo");
    expect(Path("foo").fileStem().unwrap(), "foo");
    expect(Path("foo.tar.gz").fileStem().unwrap(), "foo.tar");
    expect(Path("temp\\foo.tar.gz").fileStem().unwrap(), "foo.tar");
    expect(Path("").fileStem().isNone(), true);

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .fileStem()
            .unwrap(),
        "The Annual Report on the Health of the Parish of St");
  });

  test("parent", () {
    expect(Path("temp\\foo.rs").parent().unwrap(), Path("temp"));
    expect(Path("foo\\").parent().unwrap(), Path(""));
    expect(Path("C:\\foo\\").parent().unwrap(), Path("C:"));
    expect(Path(".foo").parent().unwrap(), Path(""));
    expect(Path(".foo.rs").parent().unwrap(), Path(""));
    expect(Path("foo").parent().unwrap(), Path(""));
    expect(Path("foo.tar.gz").parent().unwrap(), Path(""));
    expect(Path("temp\\foo.tar.gz").parent().unwrap(), Path("temp"));
    expect(Path("temp1\\temp2\\foo.tar.gz").parent().unwrap(),
        Path("temp1\\temp2"));
    expect(Path("temp1\\temp2\\\\foo.tar.gz").parent().unwrap(),
        Path("temp1\\temp2"));
    expect(Path("").parent().isNone(), true);

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .parent()
            .unwrap(),
        Path("\\Downloads"));
  });

  test("ancestors", () {
    var ancestors = Path("C:\\foo\\bar").ancestors().iterator;
    ancestors.moveNext();
    expect(ancestors.current, Path("C:\\foo\\bar"));
    ancestors.moveNext();
    expect(ancestors.current, Path("C:\\foo"));
    ancestors.moveNext();
    expect(ancestors.current, Path("C:"));
    expect(ancestors.moveNext(), false);

    // Relative paths should work similarly but without drive letters
    ancestors = Path("..\\foo\\bar").ancestors().iterator;
    ancestors.moveNext();
    expect(ancestors.current, Path("..\\foo\\bar"));
    ancestors.moveNext();
    expect(ancestors.current, Path("..\\foo"));
    ancestors.moveNext();
    expect(ancestors.current, Path(".."));
    ancestors.moveNext();
    expect(ancestors.current, Path(""));
    expect(ancestors.moveNext(), false);

    ancestors = Path("foo\\bar").ancestors().iterator;
    ancestors.moveNext();
    expect(ancestors.current, Path("foo\\bar"));
    ancestors.moveNext();
    expect(ancestors.current, Path("foo"));
    ancestors.moveNext();
    expect(ancestors.current, Path(""));
    expect(ancestors.moveNext(), false);

    ancestors = Path("foo\\..").ancestors().iterator;
    ancestors.moveNext();
    expect(ancestors.current, Path("foo\\.."));
    ancestors.moveNext();
    expect(ancestors.current, Path("foo"));

    ancestors = Path(
            "\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
        .ancestors()
        .iterator;
    ancestors.moveNext();
    expect(
        ancestors.current,
        Path(
            "\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874"));
    ancestors.moveNext();
    expect(ancestors.current, Path("\\Downloads"));
    ancestors.moveNext();
    expect(ancestors.current, Path("\\"));
  });

  test("withExtension", () {
    expect(Path("foo").withExtension("rs"), Path("foo.rs"));
    expect(Path("foo.rs").withExtension("rs"), Path("foo.rs"));
    expect(Path("foo.tar.gz").withExtension("rs"), Path("foo.tar.rs"));
    expect(Path("foo.tar.gz").withExtension(""), Path("foo.tar"));
    expect(Path("foo.tar.gz").withExtension("tar.gz"), Path("foo.tar.tar.gz"));
    expect(Path("C:\\tmp\\foo.tar.gz").withExtension("tar.gz"),
        Path("C:\\tmp\\foo.tar.tar.gz"));
    expect(Path("tmp\\foo").withExtension("tar.gz"), Path("tmp\\foo.tar.gz"));
    expect(Path("tmp\\.foo.tar").withExtension("tar.gz"),
        Path("tmp\\.foo.tar.gz"));

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .withExtension(""),
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St"));
  });

  test("withFileName", () {
    expect(Path("foo").withFileName("bar"), Path("bar"));
    expect(Path("foo.rs").withFileName("bar"), Path("bar"));
    expect(Path("foo.tar.gz").withFileName("bar"), Path("bar"));
    expect(
        Path("C:\\tmp\\foo.tar.gz").withFileName("bar"), Path("C:\\tmp\\bar"));
    expect(Path("tmp\\foo").withFileName("bar"), Path("tmp\\bar"));
    expect(Path("C:\\var").withFileName("bar"), Path("C:\\bar"));

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .withFileName("dave"),
        Path("\\Downloads\\dave"));
  });

  test("extension", () {
    expect(Path("foo").extension(), "");
    expect(Path("foo.rs").extension(), "rs");
    expect(Path("foo.tar.gz").extension(), "gz");
    expect(Path("\\tmp\\foo.tar.gz").extension(), "gz");
    expect(Path("tmp\\foo").extension(), "");
    expect(Path(".foo").extension(), "");
    expect(Path("\\var").extension(), "");
    expect(Path("\\var..d").extension(), "d");
    expect(Path("\\..d").extension(), "d");

    expect(
        Path("\\Downloads\\The Annual Report on the Health of the Parish of St. Mary Abbotts, Kensington, during the year 1874")
            .extension(),
        " Mary Abbotts, Kensington, during the year 1874");
  });
}
