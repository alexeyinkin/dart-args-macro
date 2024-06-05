import 'package:test/test.dart';
import 'package:test_util/test_util.dart';

const _executable = 'lib/main.dart';
const _experiments = ['macros'];
const _workingDirectory = 'example';

final _helpOutput = '''
The command description.

Usage: executable_name [arguments]
    --required-string (mandatory)   ⎵
-h, --help                           Print this usage information.
'''
    .replaceAll('⎵', ' ');

const _arguments = {
  'required-string': '--required-string=abc',
};

const _usageExitCode = 64;

void main() {
  test('The example works', () async {
    await dartPubGet(workingDirectory: _workingDirectory);
    final result = await dartRun(
      [_executable, ..._arguments.values],
      experiments: _experiments,
      workingDirectory: _workingDirectory,
    );

    expect(result.stdout, '''
requiredString: abc (String)
''');
  });

  test('Shows usage on help', () async {
    final options = ['-h', '--help'];

    await dartPubGet(workingDirectory: _workingDirectory);

    for (final option in options) {
      final result = await dartRun(
        [_executable, option],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
      );

      expect(result.stdout, _helpOutput, reason: option);
    }
  });

  test('Breaks on missing any required argument', () async {
    final requiredArguments = [
      'required-string',
    ];

    await dartPubGet(workingDirectory: _workingDirectory);

    for (final name in requiredArguments) {
      final arguments = {..._arguments};
      arguments.remove(name);

      final result = await dartRun(
        [_executable, ...arguments.values],
        experiments: _experiments,
        workingDirectory: _workingDirectory,
        expectedExitCode: _usageExitCode,
      );

      expect(result.stderr, 'Option "$name" is mandatory.\n\n$_helpOutput');
    }
  });
}
