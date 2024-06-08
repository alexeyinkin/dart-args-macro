Generates a parser for command-line arguments based on your data class,
wraps the standard [args](https://pub.dev/packages/args) package.

# Usage

```dart
import 'package:args_macro/args_macro.dart';

@Args()
class MyArgs {
  final String requiredString;
  final String? optionalString;
  String stringWithDefault = 'My default string.';

  final int requiredInt;
  final int? optionalInt;
  int intWithDefault = 7;

  final double requiredDouble;
  final double? optionalDouble;
  double doubleWithDefault = 7.77;

  bool boolWithDefaultFalse = false;
  bool boolWithDefaultTrue = true;

  final Fruit requiredEnum;
  final Fruit? optionalEnum;
  Fruit enumWithDefault = Fruit.mango;
}

enum Fruit { apple, banana, mango, orange }

void main(List<String> argv) {
  final parser = MyArgsParser(); // Generated class.
  final MyArgs args = parser.parse(argv);
  // ...
}
```

This will create an instance of `MyArgs` class filled with parsed data.

## Option Types

### Configuration

- A non-nullable field without an initializer creates a mandatory option.
- A nullable field without an initializer creates an optional option that defaults to `null`.
- A field with an initializer creates an optional option with the default value of that initializer. Such a field must not be final or nullable.

### Supported types

#### String

String options are not interpreted in any way.

```dart
@Args()
class MyArgs {
  final String requiredString;
  final String? optionalString;
  String stringWithDefault = 'My default string.';
}
```

#### int

An integer is parsed using `int.parse(String)`.
This means that the value must contain only digits and optionally dash in the beginning, no decimal point.
If it can't be parsed, the call to `MyArgsParser.parse()` shows a message and terminates the program.

```dart
@Args()
class MyArgs {
  final int requiredInt;
  final int? optionalInt;
  int intWithDefault = 7;
}
```

#### double

A double is parsed using `double.parse(String)`.
If it can't be parsed, the call to `MyArgsParser.parse()` shows a message and terminates the program.

```dart
@Args()
class MyArgs {
  final double requiredDouble;
  final double? optionalDouble;
  double doubleWithDefault = 7.77;
}
```

#### bool

Boolean fields produce flags.
Boolean fields must have an initializer because they cannot be required
since missing a flag just means the opposite of its presence.
For the same reason, boolean fields can't be nullable.

Most of the times you want a boolean with the default of `false`
so that adding a flag turns it to true.

An field with the default of `true` produces a flag to negate it,
and `no-` is prepended to the flag name.

```dart
@Args()
class MyArgs {
  bool boolWithDefaultFalse = false; // Use --bool-with-default-false to make it true.
  bool boolWithDefaultTrue = true;   // Use --no-bool-with-default-true to make it false.
}
```

#### enum

An enum is parsed using `MyEnum.values.byName(String)`.
If the value does not match any of the enum constants,
the call to `MyArgsParser.parse()` shows a message and terminates the program.

```dart
@Args()
class MyArgs {
  final Fruit requiredEnum;
  final Fruit? optionalEnum;
  Fruit enumWithDefault = Fruit.mango;
}

enum Fruit { apple, banana, mango, orange }
```


## Help

The parser automatically adds `--help` option.
It prints the usage and terminates the program (`parse()` method never returns).

```none
    --required-string (mandatory)
    --optional-string
    --string-with-default            (defaults to "My default string.")
    --required-int (mandatory)
    --optional-int
    --int-with-default               (defaults to "7")
    --required-double (mandatory)
    --optional-double
    --double-with-default            (defaults to "7.77")
    --bool-with-default-false        
    --no-bool-with-default-true      
    --required-enum (mandatory)      [apple, banana, mango, orange]
    --optional-enum                  [apple, banana, mango, orange]
    --enum-with-default              [apple, banana, mango (default), orange]
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
