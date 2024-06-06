import 'package:test/test.dart';
import 'package:test_util/test_util.dart';

const _executable = 'lib/main.dart';
const _experiments = ['macros'];
const _workingDirectory = 'example';

final _helpOutput = '''
The command description.

Usage: executable_name [arguments]
    --required-string (mandatory)   ⎵
    --required-int (mandatory)      ⎵
    --required-double (mandatory)   ⎵
    --required-enum (mandatory)      [apple, banana, orange]
-h, --help                           Print this usage information.
'''
    .replaceAll('⎵', ' ');

const _arguments = {
  'required-string': '--required-string=abc',
  'required-int': '--required-int=123',
  'required-double': '--required-double=3.1415926535',
  'required-enum': '--required-enum=apple',
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
requiredInt: 123 (int)
requiredDouble: 3.1415926535 (double)
requiredEnum: Fruit.apple (Fruit)
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
    const option = 'required-string';

    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(option);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(result.stderr, 'Option "$option" is mandatory.\n\n$_helpOutput');
    });
  });

  group('int', () {
    const option = 'required-int';

    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(option);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(result.stderr, 'Option "$option" is mandatory.\n\n$_helpOutput');
    });

    test('parse error', () async {
      const values = ['', 'abc', '3.1415926535'];

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
    });
  });

  group('double', () {
    const option = 'required-double';

    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(option);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(result.stderr, 'Option "$option" is mandatory.\n\n$_helpOutput');
    });

    test('parse error', () async {
      const values = ['', 'abc'];

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
    const option = 'required-enum';

    test('missing required', () async {
      final arguments = {..._arguments};
      arguments.remove(option);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(result.stderr, 'Option "$option" is mandatory.\n\n$_helpOutput');
    });

    test('parse error', () async {
      const values = ['', 'abc'];

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
    });
  });
}
