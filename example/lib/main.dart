import 'dart:io'; // ignore: unused_import
import 'package:args/args.dart'; // ignore: unused_import
// import 'macros.dart';
import 'package:args_macro/args_macro.dart';

@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
class MyArgs {
  final String requiredString;
  // final String? optionalString;
  // final String stringWithDefault = 'Default';

  final int requiredInt;
  // final int? optionalInt;
  // final int intWithDefault = 7;

  final double requiredDouble;
  // final bool requiredBool;
  // final bool? optionalBool;
  // final bool boolWithDefaultFalse = false;
  // final bool boolWithDefaultTrue = true;
}

void main(List<String> argv) {
  final parser = MyArgsParser();
  final args = parser.parse(argv);

  stdout.write(args.toDebugString());
}
