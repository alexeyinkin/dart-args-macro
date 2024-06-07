import 'package:test/test.dart';
import 'package:test_util/test_util.dart';

const _executable = 'lib/main.dart';
const _experiments = ['macros'];
const _workingDirectory = 'example';

final _helpOutput = '''
The command description.

Usage: executable_name [arguments]
    --required-string (mandatory)   ⎵
    --optional-string               ⎵
    --string-with-default            (defaults to "My default string.")
    --required-int (mandatory)      ⎵
    --optional-int                  ⎵
    --int-with-default               (defaults to "7")
    --required-double (mandatory)   ⎵
    --optional-double               ⎵
    --double-with-default            (defaults to "7.77")
    --required-enum (mandatory)      [apple, banana, mango, orange]
    --optional-enum                  [apple, banana, mango, orange]
    --enum-with-default              [apple, banana, mango (default), orange]
-h, --help                           Print this usage information.
'''
    .replaceAll('⎵', ' ');

const _requiredString = 'required-string';
const _optionalString = 'optional-string';
const _stringWithDefault = 'string-with-default';

const _requiredInt = 'required-int';
const _optionalInt = 'optional-int';
const _intWithDefault = 'int-with-default';

const _requiredDouble = 'required-double';
const _optionalDouble = 'optional-double';
const _doubleWithDefault = 'double-with-default';

const _requiredEnum = 'required-enum';
const _optionalEnum = 'optional-enum';
const _enumWithDefault = 'enum-with-default';

const _arguments = {
  //
  _requiredString: '--$_requiredString=abc',
  _optionalString: '--$_optionalString=def',
  _stringWithDefault: '--$_stringWithDefault=ghi',

  _requiredInt: '--$_requiredInt=123',
  _optionalInt: '--$_optionalInt=456',
  _intWithDefault: '--$_intWithDefault=789',

  _requiredDouble: '--$_requiredDouble=3.1415926535',
  _optionalDouble: '--$_optionalDouble=2.718281828',
  _doubleWithDefault: '--$_doubleWithDefault=1.61803398875',

  _requiredEnum: '--$_requiredEnum=apple',
  _optionalEnum: '--$_optionalEnum=banana',
  _enumWithDefault: '--$_enumWithDefault=orange',
};

const _usageExitCode = 64;
const _compileErrorExitCode = 254;

void main() {
  setUp(() async {
    await dartPubGet(workingDirectory: _workingDirectory);
  });

  test('The example works', () async {
    final result = await dartRun(
      [_executable, ..._arguments.values],
      experiments: _experiments,
      workingDirectory: _workingDirectory,
    );

    expect(result.stdout, '''
requiredString: abc (String)
optionalString: def (String)
stringWithDefault: ghi (String)
requiredInt: 123 (int)
optionalInt: 456 (int)
intWithDefault: 789 (int)
requiredDouble: 3.1415926535 (double)
optionalDouble: 2.718281828 (double)
doubleWithDefault: 1.61803398875 (double)
requiredEnum: Fruit.apple (Fruit)
optionalEnum: Fruit.banana (Fruit)
enumWithDefault: Fruit.orange (Fruit)
''');
  });

  test('Shows usage on help', () async {
    final options = ['-h', '--help'];

    for (final option in options) {
      final result = await dartRun(
        [_executable, option],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, _helpOutput, reason: option);
    }
  });

  group('String', () {
    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(_requiredString);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(
        result.stderr,
        'Option "$_requiredString" is mandatory.\n\n$_helpOutput',
      );
    });

    test('skip optional -> null', () async {
      final arguments = {..._arguments};
      arguments.remove(_optionalString);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('optionalString: null (String)'));
    });

    test('skip with initializer -> default', () async {
      final arguments = {..._arguments};
      arguments.remove(_stringWithDefault);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(
        result.stdout,
        contains('stringWithDefault: My default string. (String)'),
      );
    });
  });

  group('int', () {
    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(_requiredInt);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(
        result.stderr,
        'Option "$_requiredInt" is mandatory.\n\n$_helpOutput',
      );
    });

    test('skip optional -> null', () async {
      final arguments = {..._arguments};
      arguments.remove(_optionalInt);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('optionalInt: null (int)'));
    });

    test('skip with initializer -> default', () async {
      final arguments = {..._arguments};
      arguments.remove(_intWithDefault);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('intWithDefault: 7 (int)'));
    });

    test('parse error for required, optional, and with default', () async {
      const options = [_requiredInt, _optionalInt, _intWithDefault];
      const values = ['', 'abc', '3.1415926535'];

      for (final option in options) {
        for (final value in values) {
          final arguments = {..._arguments, option: '--$option=$value'};

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
            expectedExitCode: _usageExitCode,
          );

          expect(
            result.stderr,
            'Cannot parse the value of "$option" into int, '
            '"$value" given.\n\n$_helpOutput',
          );
        }
      }
    });
  });

  group('double', () {
    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(_requiredDouble);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(
        result.stderr,
        'Option "$_requiredDouble" is mandatory.\n\n$_helpOutput',
      );
    });

    test('skip optional -> null', () async {
      final arguments = {..._arguments};
      arguments.remove(_optionalDouble);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('optionalDouble: null (double)'));
    });

    test('skip with initializer -> default', () async {
      final arguments = {..._arguments};
      arguments.remove(_doubleWithDefault);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('doubleWithDefault: 7.77 (double)'));
    });

    test('parse error for required, optional, and with default', () async {
      const options = [_requiredDouble, _optionalDouble, _doubleWithDefault];
      const values = ['', 'abc'];

      for (final option in options) {
        for (final value in values) {
          final arguments = {..._arguments, option: '--$option=$value'};

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
            expectedExitCode: _usageExitCode,
          );

          expect(
            result.stderr,
            'Cannot parse the value of "$option" into double, '
            '"$value" given.\n\n$_helpOutput',
          );
        }
      }
    });
  });

  // group('bool', () {
  //   test('cannot be nullable', () async {
  //     final result = await dartRun(
  //       ['lib/error_bool_nullable.dart'],
  //       experiments: _experiments,
  //       workingDirectory: _workingDirectory,
  //       expectedExitCode: _compileErrorExitCode,
  //     );
  //
  //     expect(result.stderr, contains('Boolean cannot be nullable.'));
  //   });
  //
  //   test('cannot be non-nullable required without default', () async {
  //     final result = await dartRun(
  //       ['lib/error_bool_nonnullable_required_without_default.dart'],
  //       experiments: _experiments,
  //       workingDirectory: _workingDirectory,
  //       expectedExitCode: _compileErrorExitCode,
  //     );
  //
  //     expect(result.stderr, contains('Boolean must have a default value.'));
  //   });
  // });

  group('enum', () {
    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(_requiredEnum);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(
        result.stderr,
        'Option "$_requiredEnum" is mandatory.\n\n$_helpOutput',
      );
    });

    test('skip optional -> null', () async {
      final arguments = {..._arguments};
      arguments.remove(_optionalEnum);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('optionalEnum: null (Fruit)'));
    });

    test('skip with initializer -> default', () async {
      final arguments = {..._arguments};
      arguments.remove(_enumWithDefault);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('enumWithDefault: Fruit.mango (Fruit)'));
    });

    test('parse error for required, optional, and with default', () async {
      const options = [_requiredEnum, _optionalEnum, _enumWithDefault];
      const values = ['', 'abc'];

      for (final option in options) {
        for (final value in values) {
          final arguments = {..._arguments, option: '--$option=$value'};

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
            expectedExitCode: _usageExitCode,
          );

          expect(
            result.stderr,
            '"$value" is not an allowed value for option "$option".'
            '\n\n$_helpOutput',
          );
        }
      }
    });
  });
}
