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
    --bool-with-default-false       ⎵
    --no-bool-with-default-true     ⎵
    --required-enum (mandatory)      [apple, banana, mango, orange]
    --optional-enum                  [apple, banana, mango, orange]
    --enum-with-default              [apple, banana, mango (default), orange]
    --string-list                   ⎵
    --string-list-with-default       (defaults to "Huey", "Dewey", "Louie")
    --int-list                      ⎵
    --int-list-with-default          (defaults to "1", "2")
    --string-set                    ⎵
    --string-set-with-default        (defaults to "Huey", "Dewey", "Louie")
    --int-set                       ⎵
    --int-set-with-default           (defaults to "3", "4")
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

const _boolWithDefaultFalse = 'bool-with-default-false';
const _noBoolWithDefaultTrue = 'no-bool-with-default-true';

const _requiredEnum = 'required-enum';
const _optionalEnum = 'optional-enum';
const _enumWithDefault = 'enum-with-default';

const _stringList = 'string-list';
const _stringListWithDefault = 'string-list-with-default';

const _intList = 'int-list';
const _intListWithDefault = 'int-list-with-default';

const _stringSet = 'string-set';
const _stringSetWithDefault = 'string-set-with-default';

const _intSet = 'int-set';
const _intSetWithDefault = 'int-set-with-default';

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

  _boolWithDefaultFalse: '--bool-with-default-false',
  _noBoolWithDefaultTrue: '--no-bool-with-default-true',

  _requiredEnum: '--$_requiredEnum=apple',
  _optionalEnum: '--$_optionalEnum=banana',
  _enumWithDefault: '--$_enumWithDefault=orange',

  '$_stringList-1': '--$_stringList=abc',
  '$_stringList-2': '--$_stringList=def',
  '$_stringList-3': '--$_stringList=def',

  '$_stringListWithDefault-1': '--$_stringListWithDefault=ghi',
  '$_stringListWithDefault-2': '--$_stringListWithDefault=jkl',
  '$_stringListWithDefault-3': '--$_stringListWithDefault=jkl',

  '$_intList-1': '--$_intList=-1',
  '$_intList-2': '--$_intList=-2',
  '$_intList-3': '--$_intList=-2',

  '$_intListWithDefault-1': '--$_intListWithDefault=6',
  '$_intListWithDefault-2': '--$_intListWithDefault=7',
  '$_intListWithDefault-3': '--$_intListWithDefault=7',

  '$_stringSet-1': '--$_stringSet=abc',
  '$_stringSet-2': '--$_stringSet=def',
  '$_stringSet-3': '--$_stringSet=def',

  '$_stringSetWithDefault-1': '--$_stringSetWithDefault=ghi',
  '$_stringSetWithDefault-2': '--$_stringSetWithDefault=jkl',
  '$_stringSetWithDefault-3': '--$_stringSetWithDefault=jkl',

  '$_intSet-1': '--$_intSet=-3',
  '$_intSet-2': '--$_intSet=-4',
  '$_intSet-3': '--$_intSet=-4',

  '$_intSetWithDefault-1': '--$_intSetWithDefault=8',
  '$_intSetWithDefault-2': '--$_intSetWithDefault=8',
  '$_intSetWithDefault-3': '--$_intSetWithDefault=9',
};

const _usageExitCode = 64;
const _compileErrorExitCode = 254;

typedef E = ExpectedError;

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
boolWithDefaultFalse: true (bool)
boolWithDefaultTrue: false (bool)
requiredEnum: Fruit.apple (Fruit)
optionalEnum: Fruit.banana (Fruit)
enumWithDefault: Fruit.orange (Fruit)
stringList: [abc, def, def] (List)
stringListWithDefault: [ghi, jkl, jkl] (List)
intList: [-1, -2, -2] (List)
intListWithDefault: [6, 7, 7] (List)
stringSet: {abc, def} (Set)
stringSetWithDefault: {ghi, jkl} (Set)
intSet: {-3, -4} (Set)
intSetWithDefault: {8, 9} (Set)
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

  group('bool', () {
    test('skip -> default', () async {
      final arguments = {..._arguments};
      arguments.remove(_boolWithDefaultFalse);
      arguments.remove(_noBoolWithDefaultTrue);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, contains('boolWithDefaultFalse: false (bool)'));
      expect(result.stdout, contains('boolWithDefaultTrue: true (bool)'));
    });

    test('error_bool', () async {
      await dartRun(
        ['lib/error_bool.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
        expectedErrors: const [
          ExpectedFileErrors('lib/error_bool.dart', [
            E('Boolean cannot be nullable.', [10, 12, 13]),
            E('Boolean must have a default value.', [8, 10]),
            E(
              'A field with an initializer cannot be final '
              'because it needs to be overwritten when parsing the argument.',
              [13],
            ),
          ]),
        ],
      );
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

  group('Enum', () {
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

  group('Iterable', () {
    group('int', () {
      group('List', () {
        test('skip -> empty', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intList-1');
          arguments.remove('$_intList-2');
          arguments.remove('$_intList-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('intList: [] (List)'));
        });

        test('skip with initializer -> default', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intListWithDefault-1');
          arguments.remove('$_intListWithDefault-2');
          arguments.remove('$_intListWithDefault-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(
            result.stdout,
            contains('intListWithDefault: [1, 2] (List)'),
          );
        });

        test('1', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intList-1');
          arguments.remove('$_intList-2');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('intList: [-2] (List)'));
        });
      });

      group('Set', () {
        test('skip -> empty', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intSet-1');
          arguments.remove('$_intSet-2');
          arguments.remove('$_intSet-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('intSet: {} (Set)'));
        });

        test('skip with initializer -> default', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intSetWithDefault-1');
          arguments.remove('$_intSetWithDefault-2');
          arguments.remove('$_intSetWithDefault-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(
            result.stdout,
            contains('intSetWithDefault: {3, 4} (Set)'),
          );
        });

        test('1', () async {
          final arguments = {..._arguments};
          arguments.remove('$_intSet-1');
          arguments.remove('$_intSet-2');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('intSet: {-4} (Set)'));
        });
      });

      test('parse error', () async {
        const options = [
          _intList,
          _intListWithDefault,
          _intSet,
          _intSetWithDefault,
        ];
        const values = ['', 'abc', '3.1415926535'];

        for (final option in options) {
          for (final value in values) {
            final arguments = {
              ..._arguments,
              '$option-1': '--$option=1',
              '$option-2': '--$option=$value',
              '$option-3': '--$option=3',
            };

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

    group('String', () {
      group('List', () {
        test('skip -> empty', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringList-1');
          arguments.remove('$_stringList-2');
          arguments.remove('$_stringList-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('stringList: [] (List)'));
        });

        test('skip with initializer -> default', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringListWithDefault-1');
          arguments.remove('$_stringListWithDefault-2');
          arguments.remove('$_stringListWithDefault-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(
            result.stdout,
            contains('stringListWithDefault: [Huey, Dewey, Louie] (List)'),
          );
        });

        test('1', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringList-1');
          arguments.remove('$_stringList-2');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('stringList: [def] (List)'));
        });
      });

      group('Set', () {
        test('skip -> empty', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringSet-1');
          arguments.remove('$_stringSet-2');
          arguments.remove('$_stringSet-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('stringSet: {} (Set)'));
        });

        test('skip with initializer -> default', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringSetWithDefault-1');
          arguments.remove('$_stringSetWithDefault-2');
          arguments.remove('$_stringSetWithDefault-3');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(
            result.stdout,
            contains('stringSetWithDefault: {Huey, Dewey, Louie} (Set)'),
          );
        });

        test('1', () async {
          final arguments = {..._arguments};
          arguments.remove('$_stringSet-1');
          arguments.remove('$_stringSet-2');

          final result = await dartRun(
            [_executable, ...arguments.values],
            experiments: _experiments,
            workingDirectory: _workingDirectory,
          );

          expect(result.stdout, contains('stringSet: {def} (Set)'));
        });
      });
    });

    group('Generic', () {
      test('error_iterable_nullable', () async {
        await dartRun(
          ['lib/error_iterable_nullable.dart'],
          experiments: _experiments,
          workingDirectory: _workingDirectory,
          expectedExitCode: _compileErrorExitCode,
          expectedErrors: const [
            ExpectedFileErrors('lib/error_iterable_nullable.dart', [
              E(
                'A List cannot be nullable because it is just empty '
                'when no options with this name are passed.',
                [7],
              ),
              E(
                'A Set cannot be nullable because it is just empty '
                'when no options with this name are passed.',
                [8],
              ),
            ]),
          ],
        );
      });
    });
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

  group('General errors.', () {
    test('error_types', () async {
      await dartRun(
        ['lib/error_types.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
        expectedErrors: const [
          ExpectedFileErrors('lib/error_types.dart', [
            E(
              'The only allowed types are: String, int, double, bool, Enum, '
              'List<String>, List<int>, List<double>, List<bool>, List<Enum>, '
              'Set<String>, Set<int>, Set<double>, Set<bool>, Set<Enum>.',
              [14, 17, 18, 20],
            ),
            E('Expected 0 type arguments.', [17]),
            E('Cannot resolve type.', [17]),
            E(
              'A List requires a type parameter: '
              'List<String>, List<int>, List<double>, '
              'List<bool>, List<Enum>.',
              [15, 16],
            ),
            E(
              'A Set requires a type parameter: '
              'Set<String>, Set<int>, Set<double>, '
              'Set<bool>, Set<Enum>.',
              [19],
            ),
          ]),
        ],
      );
    });

    test('error_final_with_default', () async {
      await dartRun(
        ['lib/error_final_with_default.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
        expectedErrors: const [
          ExpectedFileErrors('lib/error_final_with_default.dart', [
            E(
              'A field with an initializer cannot be final '
              'because it needs to be overwritten when parsing the argument.',
              [6, 7, 8, 9, 10, 11, 12],
            ),
          ]),
        ],
      );
    });

    test('error_nullable_with_default', () async {
      await dartRun(
        ['lib/error_nullable_with_default.dart'],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _compileErrorExitCode,
        expectedErrors: const [
          ExpectedFileErrors('lib/error_nullable_with_default.dart', [
            E(
              'A field with an initializer must be non-nullable '
              'because nullability and the default value '
              'are mutually exclusive ways to handle a missing value.',
              [10, 11, 12, 15],
            ),
            E('Boolean cannot be nullable.', [9]),
            E(
              'A List cannot be nullable because it is just empty '
              'when no options with this name are passed.',
              [13],
            ),
            E(
              'A Set cannot be nullable because it is just empty '
              'when no options with this name are passed.',
              [14],
            ),
          ]),
        ],
      );
    });
  });
}
