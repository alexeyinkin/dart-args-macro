[![Pub Package](https://img.shields.io/pub/v/args_macro.svg)](https://pub.dev/packages/args_macro)
[![GitHub](https://img.shields.io/github/license/alexeyinkin/dart-args-macro)](https://github.com/alexeyinkin/dart-args-macro/blob/main/LICENSE)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/alexeyinkin/dart-args-macro?style=flat-square)](https://www.codefactor.io/repository/github/alexeyinkin/dart-args-macro)
[![Support Chat](https://img.shields.io/badge/support%20chat-telegram-brightgreen)](https://ainkin.com/chat)

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

  final List<String> stringList;
  List<String> stringListWithDefault = ['Huey', 'Dewey', 'Louie'];

  final List<int> intList;
  List<int> intListWithDefault = [1, 2];

  final List<double> doubleList;
  List<double> doubleListWithDefault = [1, 2.0];

  final List<Fruit> enumList;
  List<Fruit> enumListWithDefault = [Fruit.apple, Fruit.banana];
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

A boolean field produces a flag.
A boolean field must have an initializer because it cannot be required
since missing a flag just means the opposite of its presence.
For the same reason, a boolean field can't be nullable.

Most of the times you want a boolean with the default of `false`
so that adding a flag turns it to true.

A field with the default of `true` produces a flag to negate it,
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

#### List, Set

A `List` and `Set` field produce options that can be passed multiple times in the command line.
Each time adds an item to the collection.

A default value can be used if the option was passed zero times.

Use `Set` if you don't care about the order of the values and want them deduplicated.
Otherwise, use `List`.

The collections support `String`, `int`, `double`, and `enum`.

```dart
@Args()
class MyArgs {
  final List<String> stringList;
  List<String> stringListWithDefault = ['Huey', 'Dewey', 'Louie'];

  final List<int> intList;
  List<int> intListWithDefault = [1, 2];

  final List<double> doubleList;
  List<double> doubleListWithDefault = [1, 2.0];

  final List<Fruit> enumList;
  List<Fruit> enumListWithDefault = [Fruit.apple, Fruit.banana];

  final Set<String> stringSet;
  Set<String> stringSetWithDefault = {'Huey', 'Dewey', 'Louie'};

  final Set<int> intSet;
  Set<int> intSetWithDefault = {3, 4};

  final Set<double> doubleSet;
  Set<double> doubleSetWithDefault = {3, 4.0};

  final Set<Fruit> enumSet;
  Set<Fruit> enumSetWithDefault = {Fruit.orange, Fruit.banana};
}

enum Fruit { apple, banana, mango, orange }
```

## Help

The parser automatically adds `--help` option.
It prints the usage and terminates the program (`parse()` method never returns).

### Help messages for arguments

To add a help message for an option, define a static variable by prepending an underscore
and appending `Help` to the field name:

```dart
@Args()
class MyArgs {
  final String requiredString;
  static const _requiredStringHelp = 'Help for the required string.';
  // ...
}
```

### Executable Name and Description

To prepend the help text with the description and an example of the command,
pass the following parameters to the macro:

```dart
@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
class MyArgs { /* ... */ }
```

### Help Example

This is the output of the full-fledged
[example file](example/lib/main.dart):

```none
The command description.

Usage: executable_name [arguments]
    --required-string (mandatory)    Help for the required string.
    --optional-string                
    --string-with-default            (defaults to "My default string.")
    --required-int (mandatory)       
    --optional-int                   Help for the optional int.
    --int-with-default               (defaults to "7")
    --required-double (mandatory)    Help for the required double.
    --optional-double                
    --double-with-default            (defaults to "7.77")
    --bool-with-default-false        Help for the flag.
    --no-bool-with-default-true      
    --required-enum (mandatory)      [apple, banana, mango, orange]
    --optional-enum                  Help for the optional Enum.
                                     [apple, banana, mango, orange]
    --enum-with-default              [apple, banana, mango (default), orange]
    --string-list                    
    --string-list-with-default       Help for String[] with default.
                                     (defaults to "Huey", "Dewey", "Louie")
    --int-list                       Help for int[].
    --int-list-with-default          (defaults to "1", "2")
    --double-list                    Help for double[].
    --double-list-with-default       (defaults to "1.0", "2.0")
    --enum-list                      Help for Enum[].
                                     [apple, banana, mango, orange]
    --enum-list-with-default         [apple (default), banana (default), mango, orange]
    --string-set                     Help for String{}.
    --string-set-with-default        (defaults to "Huey", "Dewey", "Louie")
    --int-set                        Help for int{}.
    --int-set-with-default           (defaults to "3", "4")
    --double-set                     Help for double{}.
    --double-set-with-default        (defaults to "3.0", "4.0")
    --enum-set                       Help for Enum{}.
                                     [apple, banana, mango, orange]
    --enum-set-with-default          [apple, banana (default), mango, orange (default)]
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

## Roadmap

The following improvements are blocked because the Macro API does not allow them at this point:

- [Help for a field from the doc comment](https://github.com/alexeyinkin/dart-args-macro/issues/2)
- [Real enum introspection](https://github.com/alexeyinkin/dart-args-macro/issues/3)
- [Allow final for fields with an initializer](https://github.com/alexeyinkin/dart-args-macro/issues/4)
