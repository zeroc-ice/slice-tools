# icefmt

`icefmt` formats Slice files that use the original Slice syntax (`.ice` files). It supports the Slice syntax of
Ice 3.8 and Ice 3.7, including local Slice. It has one style, with nothing to configure.

## Usage

```
icefmt [options] paths...
```

- `--check` writes nothing: it lists the files that formatting would change, and exits with status `1` if there is any.
- `-h`, `--help` shows the usage.
- `-v`, `--version` shows the version.

`icefmt` rewrites each file in place. Given a directory, it formats all the `.ice` files in that directory,
recursively. It skips the files and directories whose name starts with a dot, and `node_modules` directories, where
npm installs the Slice files of the Ice for JavaScript package.

To leave a file out, put the comment `// icefmt: ignore-file` in it.

`icefmt` has no option to exclude a directory: pass it the files to format instead. For example, this command checks
all the `.ice` files tracked by Git except the ones in `test/errors`:

```
git ls-files -z '*.ice' ':!:test/errors' | xargs -0 icefmt --check
```

To leave part of a file as written, put one of these comments on a line of its own:

- `// icefmt: ignore`, before a definition, leaves that definition as written.
- `// icefmt: off`, before a definition, leaves it and the definitions after it as written, up to the one that
  `// icefmt: on` precedes, or to the end of their module, class, or other body.

The text left as written takes the indentation of the code around it, and its lines keep their indentation relative to
the first one.

`icefmt` formats a file as written, without running the preprocessor. A file that is valid Slice only after
preprocessing has a syntax error for `icefmt`: for example, a file where a macro expands to metadata, or where an
`#ifdef` and its `#else` each start the same definition. `icefmt` reports a syntax error as `file:line: message` and
leaves the file unchanged.

## Style

`icefmt` indents with 4 spaces and breaks lines to fit in 120 columns where it can. Braces go on their own line,
except for an empty `{}` and a definition written on one line that still fits. `icefmt` keeps the text of comments and
preprocessor directives, and the blank lines between definitions, at most one in a row. The files in
[tests/formatted](tests/formatted) show the style in full.

## Building

Building `icefmt` requires CMake 3.24 or later and a C++20 compiler.

```
cmake -S icefmt -B icefmt/build -DCMAKE_BUILD_TYPE=Release
cmake --build icefmt/build --config Release
```

The executable is `icefmt/build/icefmt`, or `icefmt\build\Release\icefmt.exe` with Visual Studio.

## Testing

```
ctest --test-dir icefmt/build --build-config Release --output-on-failure
```
