Generates a parser for command-line arguments based on your data class,
wraps the standard [args](https://pub.dev/packages/args) package.

# Usage

```dart
import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  final String requiredString;
  final String? optionalString;

  final int requiredInt;
  final int? optionalInt;

  final double requiredDouble;
  final double? optionalDouble;

  final Fruit requiredEnum;
  final Fruit? optionalEnum;
}

enum Fruit {
  apple,
  banana,
  orange,
}

void main(List<String> argv) {
  final parser = MyArgsParser(); // Generated class.
  final MyArgs args = parser.parse(argv);
  // ...
}
```

This will create an instance of `MyArgs` class filled with parsed data.

## Supported Types

Supported types:
- `String`
- `int`
- `double`
- `enum`

Non-nullable fields create mandatory options. Nullable fields create optional options.

## Help

The parser automatically adds `--help` option.
It prints the usage and terminates the program (`parse()` method never returns).

```
    --required-string (mandatory)
    --optional-string
    --required-int (mandatory)
    --optional-int
    --required-double (mandatory)
    --optional-double
    --required-enum (mandatory)      [apple, banana, orange]
    --optional-enum                  [apple, banana, orange]
-h, --help                           Print this usage information.
```

## Error Handling

Unless `--help` is passed, all data is validated according to your data class structure.
On any error, `parse()` method prints the first error occurred and the usage to `stderr`
and terminates the program with the exit code 64.

To ignore all errors but still have the parser populated with the options
derived from your data class (and skip the automatic handling of `--help`),
use the standard [`ArgParser`](https://pub.dev/documentation/args/latest/args/ArgParser-class.html) instance
which this generated parser wraps.
It will return the regular [`ArgResults`](https://pub.dev/documentation/args/latest/args/ArgResults-class.html)
without any error handling:

```dart
void main(List<String> argv) {
  final result = MyArgsParser().parser.parse(argv);
  print(result.option('required-string'));
}
```


# Status

The macros feature is experimental in Dart.
Things are expected to break.
Do not use this package in production code.

For instance, the support for enum in macros is currently very poor.
This package uses workarounds and handles them as classes.
This is expected to break at some point when the macros API starts returning enum-related objects
instead of class-related ones.
