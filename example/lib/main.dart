import 'package:args_macro/args_macro.dart';

@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
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

  stdout.write(args.toDebugString());
}
