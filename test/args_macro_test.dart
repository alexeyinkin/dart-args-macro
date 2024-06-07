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
    --required-int (mandatory)      ⎵
    --optional-int                  ⎵
    --required-double (mandatory)   ⎵
    --optional-double               ⎵
    --required-enum (mandatory)      [apple, banana, orange]
    --optional-enum                  [apple, banana, orange]
-h, --help                           Print this usage information.
'''
    .replaceAll('⎵', ' ');

const _requiredString = 'required-string';
const _optionalString = 'optional-string';
const _requiredInt = 'required-int';
const _optionalInt = 'optional-int';
const _requiredDouble = 'required-double';
const _optionalDouble = 'optional-double';
const _requiredEnum = 'required-enum';
const _optionalEnum = 'optional-enum';

const _arguments = {
  _requiredString: '--$_requiredString=abc',
  _optionalString: '--$_optionalString=def',
  _requiredInt: '--$_requiredInt=123',
  _optionalInt: '--$_optionalInt=456',
  _requiredDouble: '--$_requiredDouble=3.1415926535',
  _optionalDouble: '--$_optionalDouble=2.718281828',
  _requiredEnum: '--$_requiredEnum=apple',
  _optionalEnum: '--$_optionalEnum=banana',
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
requiredInt: 123 (int)
optionalInt: 456 (int)
requiredDouble: 3.1415926535 (double)
optionalDouble: 2.718281828 (double)
requiredEnum: Fruit.apple (Fruit)
optionalEnum: Fruit.banana (Fruit)
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

    test('parse error for required and optional', () async {
      const options = [_requiredInt, _optionalInt];
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

    test('parse error for required and optional', () async {
      const options = [_requiredDouble, _optionalDouble];
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

  group('bool', () {
    test('cannot be nullable', () async {
      final result = await dartRun(
        ['lib/error_bool_nullable.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
      );

      expect(result.stderr, contains('Boolean cannot be nullable.'));
    });

    test('cannot be non-nullable required without default', () async {
      final result = await dartRun(
        ['lib/error_bool_nonnullable_required_without_default.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
      );

      expect(result.stderr, contains('Boolean must have a default value.'));
    });
  });

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

    test('parse error for required and optional', () async {
      const options = [_requiredEnum, _optionalEnum];
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
