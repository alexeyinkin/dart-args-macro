import 'package:args_macro/args_macro.dart';

@Args(
  description: 'The command description.',
  executableName: 'executable_name',
)
class MyArgs {
  final String requiredString;
  static const _requiredStringHelp = 'Help for the required string.';
  final String? optionalString;
  String stringWithDefault = 'My default string.';

  final int requiredInt;
  final int? optionalInt;
  // ignore: prefer_const_declarations
  static final String _optionalIntHelp = 'Help for the optional int.';
  int intWithDefault = 7;

  final double requiredDouble;
  static const _requiredDoubleHelp = 'Help for the required double.';
  final double? optionalDouble;
  double doubleWithDefault = 7.77;

  bool boolWithDefaultFalse = false;
  static const _boolWithDefaultFalseHelp = 'Help for the flag.';
  bool boolWithDefaultTrue = true;

  final Fruit requiredEnum;
  final Fruit? optionalEnum;
  static const _optionalEnumHelp = 'Help for the optional Enum.';
  Fruit enumWithDefault = Fruit.mango;

  final List<String> stringList;
  List<String> stringListWithDefault = ['Huey', 'Dewey', 'Louie'];
  static const _stringListWithDefaultHelp = 'Help for String[] with default.';

  final List<int> intList;
  static const _intListHelp = 'Help for int[].';
  List<int> intListWithDefault = [1, 2];

  final List<double> doubleList;
  static const _doubleListHelp = 'Help for double[].';
  List<double> doubleListWithDefault = [1, 2.0];

  final Set<String> stringSet;
  static const _stringSetHelp = 'Help for String{}.';
  Set<String> stringSetWithDefault = {'Huey', 'Dewey', 'Louie'};

  final Set<int> intSet;
  static const _intSetHelp = 'Help for int{}.';
  Set<int> intSetWithDefault = {3, 4};

  final Set<double> doubleSet;
  static const _doubleSetHelp = 'Help for double{}.';
  Set<double> doubleSetWithDefault = {3, 4.0};
}

enum Fruit { apple, banana, mango, orange }

void main(List<String> argv) {
  final parser = MyArgsParser(); // Generated class.
  final MyArgs args = parser.parse(argv);

  stdout.write(args.toDebugString());
}
